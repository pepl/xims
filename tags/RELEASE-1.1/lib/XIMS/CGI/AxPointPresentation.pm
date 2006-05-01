# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::AxPointPresentation;

use strict;
use base qw( XIMS::CGI::Document );
use XIMS::DataFormat;
use XML::LibXML::SAX;
use Cwd 'fastcwd';
#use Text::Iconv;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub registerEvents {
    $_[0]->SUPER::registerEvents( qw( download_pdf ) );
}

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    $ctxt->properties->application->style( "create" );

    return 0;
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # the request method 'PUT' is only used by BXE to save XML-code
    if ( $self->request_method() eq 'PUT' ) {
        XIMS::Debug( 4, "BXE is putting XML-data for saving." );
        if ( $self->save_PUT_data($ctxt) ) {
            print $self->header(-status => '204');
        }
        else {
            print $self->header();
        }
        $self->skipSerialization(1);
        return 0;
    }
    else {
        if ( $self->user_agent('MSIE') ) {
            $self->param( 'msie', 1 );
        }
        return $self->SUPER::event_default( $ctxt );
    }
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    $ctxt->properties->application->style( "edit" );

    if ( XIMS::XMLEDITOR() eq 'bxe' ) {
        $self->param( "bxepresent", "1" );
    }

    if ( $self->param( "edit" ) eq "bxe" ) {
        $ctxt->properties->application->style( "edit_bxe" );
    }

    return 0;
}

sub event_download_pdf {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $printmode = $self->param('printmode') ? 1 : 0;
    my $gotmodules;
    eval {
        require XML::SAX;
        require XML::SAX::Writer;
        require XML::Handler::AxPoint;
        $gotmodules = 1;
    };

    if ( not $gotmodules ) {
        XIMS::Debug( 2, "Required module not found");
        $self->sendError( $ctxt, "Required module not found. You need to have XML::SAX, XML::SAX::Writer, and XML::Handler::AxPoint installed to create a PDF presentation." );
        return 0;
    }

    my $output_handler = XIMS::CGI::AxPointPresentation::Output->new();
    my $charset = XIMS::DBENCODING() ? XIMS::DBENCODING() : 'UTF-8';

    # get the xml document, add an XML declaration
    my $xmlstring = '<?xml version="1.0" encoding="'.$charset.'"?>' . $object->body();

    # chdir, so that relatively linked images will be found
    # for that, the parent dir of the presentation has to be published
    # to avoid that, we would have to check for all dependencies and write
    # them out to a temp-dir, or: work with input callbacks if they would
    # be recognized correctly...
    my $dir = XIMS::PUBROOT() . $object->parent->location_path();
    my $cwd = fastcwd;
    if ( not chdir($dir) ) {
        XIMS::Debug( 2, "Could not chdir to " . $dir );
        $self->sendError( $ctxt, "The directory where the presentation file resides in, has to be published." );
        return 0;
    }

    # create parser and handler
    my $parser = XML::SAX::ParserFactory->parser(
        Handler =>
            XML::Handler::AxPoint->new(
                Output => $output_handler,
                PrintMode => $printmode,
                #Encoder => Text::Iconv->new('utf-8', 'ISO-8859-1'), # Encoder is currently not supported
                                                                    # but I hope it will be in the future ;-)
            )
    );

    # parse the string
    eval {
        $parser->parse_string( $xmlstring );
    };
    if ( $@ ) {
        my $err = $@;
        ($err) = ( $err =~ /^(.*)!/ );
        XIMS::Debug( 2, "Could not create PDF file: " . $err );
        $self->sendError( $ctxt, "Could not create PDF file: \"$err\" Be aware that every referenced image has to be published before the PDF file can be created!" );
        return 0;
    }
    # chdir back to original dir
    chdir $cwd;

    # check for output
    my $output_string = $output_handler->get_output();
    if ( not (defined $output_string and length $output_string) ) {
        XIMS::Debug( 2, "PDF creation has not been succesful." );
        $self->sendError( $ctxt, "PDF creation has not been succesful." );
        return 0;
    }

    my $mime_type = XIMS::DataFormat->new( suffix => 'pdf' )->mime_type();
    my $filename = $object->location();
    $filename =~ s/\.axp$/.pdf/;

    # print to browser
    print $self->header(-type => $mime_type, '-Content-disposition' => "attachment; filename=$filename" );
    print $output_string;

    $self->skipSerialization(1);
    return 0;
}


package XIMS::CGI::AxPointPresentation::Output;
use XML::SAX::Writer;
use Text::Iconv;
use vars qw(@ISA);
@ISA = ('XML::SAX::Writer::ConsumerInterface');

sub new {
    my $self = shift->SUPER::new( {} );
    return $self;
}

sub output {
    my $self = shift;
    $$self->{Output} .= shift;
}

sub get_output {
    my $self = shift;
    return $$self->{Output};
}


1;