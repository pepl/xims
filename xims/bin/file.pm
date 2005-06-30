# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package file;

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
           del
           del_prompt
           view_data
           obj_acllist
           obj_aclgrant
           obj_aclrevoke
           publish
           publish_prompt
           unpublish
           cancel
          )
        );
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $ctxt->object();

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

    # ad: mimetypes
    #
    # in a longterm: don't rely on the UA, make some internal
    # sanity-test drawbacks are: probably costly, nor bulletproof,
    #
    # i think we need a default-type x-unknown/x-unknown or something
    # similar - saves us from locking out anything unknown. so the
    # lookup would be data_formats -> mime_type aliases if that fails
    # set x-unknown/x-unknown on file upload. maybe do the same in
    # image-create, and set the object-type to 'File' the idea behind
    # that is basically, we do not have to reject a lot and don't make
    # promises to the user on lookup or d/l. anything else is going to
    # be support-hell, IMHO.

    if ( length $fh ) {
        my $type = $self->uploadInfo($fh)->{'Content-Type'};
        # my $type = $self->upload('file')->info("Content-type");

        if ( my $df = XIMS::DataFormat->new( mime_type => $type ) ) {
            XIMS::Debug( 6, "xims mime type: ". $df->mime_type() );
            XIMS::Debug( 6, "UA   mime type: ". $type );
            $ctxt->object->data_format_id( $df->id() );
        }
        else {
            XIMS::Debug( 3, "$type is not a valid mime-type" );
            $self->sendError( $ctxt,
                              "The mimetype of the file you supplied ( " .
                              $type .
                              ") is unsupported and therefore rejected. Sorry." );
            return 0;
        }

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
