# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::NewsItem;

use strict;
use vars qw( $VERSION @ISA );

use XIMS::CGI::Document;
use XIMS::Image;
use Data::Dumper;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( XIMS::CGI::Document );

sub event_default {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # replace image id with image path
    $self->resolve_content( $ctxt, [ qw( IMAGE_ID ) ] );

    return $self->SUPER::event_default( $ctxt );
}

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $self->resolve_content( $ctxt, [ qw( IMAGE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_store {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $img_fh = $self->upload( 'imagefile' );


    if ( length $img_fh ) {
        my $target_location = $self->param('imagefolder');
        my $img_target = XIMS::Object->new( path => $target_location );

        if ( defined( $img_target )) {
            XIMS::Debug( 4, "Creating Image object for new NewsItem" );
            my $img_obj = XIMS::Image->new( User => $ctxt->session->user() );
            $img_obj->parent_id( $img_target->document_id() );
            $img_obj->location( $self->param('imagefile') );
            my $type = $self->uploadInfo($img_fh)->{'Content-Type'};
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
            $img_obj->data_format_id( $df->id() );

            XIMS::Debug( 4, "reading from filehandle");
            my ($buffer, $body);
            while ( read($img_fh, $buffer, 1024) ) {
                $body .= $buffer;
            }

            $img_obj->body( $body );
            my $img_created = $ctxt->object->add_image( $img_obj );
            XIMS::Debug( 3, "Image object import failed" ) unless $img_created;

        }
        else {
            XIMS::Debug( 3, "Image upload folder undefined or does not exist, the new Image object was not created" );
        }
    }

    my $location;
    if ( defined $ctxt->object->document_id() ) {
        $location = $ctxt->object->document_id() . '.' . $ctxt->object->data_format->suffix();
        $self->param( 'name', $location );
    }
    else {
        $self->param( 'name', 'dummy.html' ); # provide a dummy location during object creation
    }

    my $rc = $self->SUPER::event_store( $ctxt );
    if ( not $rc ) {
        return 0;
    }
    else {
        if ( $ctxt->object->location() eq 'dummy.html' ) {
            XIMS::Debug( 4, "replacing the dummy location with the document_id" );
            # set the document_id as location
            $location = $ctxt->object->document_id() . '.' . $ctxt->object->data_format->suffix();
            # take the faster shortcut through the data provider
            if ( not $ctxt->data_provider->updateObject( document_id => $ctxt->object->document_id(), location => $location ) ) {
                XIMS::Debug( 2, "setting document_id as location failed" );
                $self->sendError( $ctxt, "Setting location failed." );
                return 0;
            }
            # update the redirect path to the changed location
            $ctxt->object->location( $location );
            $self->redirect( $self->redirect_path( $ctxt ) );
        }
        return 1;
    }
}
1;
