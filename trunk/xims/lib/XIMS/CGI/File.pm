# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::File;

use strict;
use vars qw( $VERSION @ISA);

use XIMS::CGI;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

sub registerEvents {
    XIMS::Debug( 5, "called");
    return $_[0]->SUPER::registerEvents(
        qw(
           create
           edit
           store
           obj_acllist
           obj_aclgrant
           obj_aclrevoke
           publish
           publish_prompt
           unpublish
           view_data
          )
        );
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    print $self->header( -type => $ctxt->object->data_format->mime_type() );
    print $ctxt->object->body();
    $self->skipSerialization(1);

    return 0;
}


sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # get the parameters
    my $fh = $self->upload( 'file' );

    $ctxt->properties->application->keepsuffix( 1 );

    # set the location parameter, so init_store_object sets the right location
    # do not override existing locations
    # the following code prevents changing location of existing files. this should
    # possible for unpublished files.
    if ( not defined $ctxt->parent() ) {
        $self->param( name => $ctxt->object->location() );
    }
    else {
        $self->param( name => $self->param( 'file' ) );
    }

    return 0 unless $self->init_store_object( $ctxt );

    # if the mimetype provided by the UA is unknown,
    # fall back to 'application/octet-stream'
    if ( length $fh ) {
        my $type = $self->uploadInfo($fh)->{'Content-Type'};
        my $df;
        if ( $df = XIMS::DataFormat->new( mime_type => $type ) ) {
            XIMS::Debug( 6, "xims mime type: ". $df->mime_type() );
            XIMS::Debug( 6, "UA   mime type: ". $type );
        }
        else {
            $df = XIMS::DataFormat->new( mime_type => 'application/octet-stream' );
            XIMS::Debug( 6, "xims mime type: forced to 'application/octet-stream'" );
            XIMS::Debug( 6, "UA   mime type: ". $type );

        }
        $ctxt->object->data_format_id( $df->id() );

        XIMS::Debug(5, "reading from filehandle");
        my ($buffer, $body);
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }

        $ctxt->object->body( $body );
    }

    return 0 unless $self->SUPER::event_store( $ctxt );

}

sub event_view_data {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # this is a special default. this has to be done, because on default the
    # file will be displayed as the content type it actualy is. the view event
    # is a browse interface for the files metadata.

    return $self->SUPER::event_default($ctxt);
}

1;
