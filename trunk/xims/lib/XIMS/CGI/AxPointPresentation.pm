
=head1 NAME

XIMS::CGI::AxPointPresentation::Output -- handles XML based PDF Presentations

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::AxPointPresentation::Output;

=head1 DESCRIPTION

This module handles AxPointPresentations, a XML Format used for simple PDF
Presentations.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::AxPointPresentation;

use common::sense;
use parent qw( XIMS::CGI::Document );
use XIMS::DataFormat;
use XML::LibXML::SAX;
use Cwd 'fastcwd';
#use Text::Iconv;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
    $_[0]->SUPER::registerEvents( qw( download_pdf ) );
}

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "create" . $ed );

    return 0;
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return $self->SUPER::event_default( $ctxt );
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );

    return 0;
}

=head2 event_download_pdf()

=cut

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
        $self->sendError( $ctxt, __"Required module not found. You need to have XML::SAX, XML::SAX::Writer, and XML::Handler::AxPoint installed to create a PDF presentation." );
        return 0;
    }

    my $output_handler = XIMS::CGI::AxPointPresentation::Output->new();

    # get the xml document, add an XML declaration
    my $xmlstring = '<?xml version="1.0"?>' . $object->body();

    # chdir, so that relatively linked images will be found
    # for that, the parent dir of the presentation has to be published
    # to avoid that, we would have to check for all dependencies and write
    # them out to a temp-dir, or: work with input callbacks if they would
    # be recognized correctly...
    my $dir = XIMS::PUBROOT() . $object->parent->location_path();
    my $cwd = fastcwd;
    if ( not chdir($dir) ) {
        XIMS::Debug( 2, "Could not chdir to " . $dir );
        $self->sendError( $ctxt, __"The directory where the presentation file resides in, has to be published." );
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
        $self->sendError( $ctxt, __x("Could not create PDF file: \"{err}\" Be aware that every referenced image has to be published before the PDF file can be created!", err => $err ));
        return 0;
    }
    # chdir back to original dir
    chdir $cwd;

    # check for output
    my $output_string = $output_handler->get_output();
    if ( not (defined $output_string and length $output_string) ) {
        XIMS::Debug( 2, "PDF creation has not been succesful." );
        $self->sendError( $ctxt, __"PDF creation has not been succesful." );
        return 0;
    }

    my $mime_type = XIMS::DataFormat->new( suffix => 'pdf' )->mime_type();
    my $filename = $object->location();
    $filename =~ s/\.axp$/.pdf/;

	$self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            '-charset'             => $encoding,
            '-type'                => $mime_type,
            '-Content-disposition' => "attachment; filename=$filename",
        ),
        $output_string;
    );
    $self->skipSerialization(1);

    return 0;
}

package XIMS::CGI::AxPointPresentation::Output;
use XML::SAX::Writer;
use Text::Iconv;
use vars qw(@ISA);
@ISA = ('XML::SAX::Writer::ConsumerInterface');

=head2 new()

=cut

sub new {
    my $self = shift->SUPER::new( {} );
    return $self;
}

=head2 output()

=cut

sub output {
    my $self = shift;
    $$self->{Output} .= shift;
}

=head2 get_output()

=cut

sub get_output {
    my $self = shift;
    return $$self->{Output};
}


1;
__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

