# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::NewsItem;

use strict;
use vars qw( $VERSION @ISA );

use XIMS::CGI::Document;
use XIMS::Image;
use XIMS::Portlet;
use XIMS::ObjectType;
use Text::Iconv;

#use Data::Dumper;

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

        if ( defined $img_target ) {
            XIMS::Debug( 4, "Creating Image object for new NewsItem" );
            my $img_obj = XIMS::Image->new( User => $ctxt->session->user() );
            $img_obj->parent_id( $img_target->document_id() );

            # $location will be part of the URI, converting to iso-8859-1 is
            # a first step before clean_location() to ensure browser compatibility
            my $converter = Text::Iconv->new("UTF-8", "ISO-8859-1");
            # will be undef if string can not be converted to iso-8859-1
            $img_obj->location( $converter->convert( $self->param('imagefile') ) );

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

            my $image_title = $self->param('imagetitle');
            if ( defined $image_title and length $image_title and $image_title !~ /^\s+$/ ) {
                if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
                    $image_title = XIMS::decode($image_title);
                }
                $img_obj->title( $image_title );
            }

            my $image_description = $self->param( 'imagedescription' );
            # check if a valid image_description is given
            if ( defined $image_description and (length $image_description and $image_description !~ /^\s+$/ or not length $image_description) ) {
                if ( length $image_description and XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
                    $image_description = XIMS::decode($image_description);
                }
                XIMS::Debug( 6, "image_description, len: " . length($image_description) );
                $img_obj->abstract( $image_description );
            }

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

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_publish( $ctxt );

    $self->publish_portlets( $ctxt );

    return 0;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_unpublish( $ctxt );

    $self->publish_portlets( $ctxt );

    return 0;
}

#
# publish_portlet() publishes all Portlet objects in the ancestrial containers.
# It silently assumes that the main category and portal navigation happens using those
# Portlets. For the LFU-Portal 'iPoint', we are using a structure
# like the following:
#
# PortalFolder
#     |
#     *- CategoryFolder
#                      |
#                      *- NewsItem
#                      *- NewsItem
#                      *- CategoryIndexPortlet
#     *- CategoryFolder
#                      |
#                      *- NewsItem
#                      *- NewsItem
#                      *- CategoryIndexPortlet
#     *- CategoryOverviewPortlet
#     *- MostRecentNewsPerCategoryPortlet
#     *- OverallMostRecentNewsPortlet (Filtering out latest X NewsItems over the Categories
#
# For a generic Portal solution we should think of either moving publish_portlets()
# elsewhere, or automate (Wizard?) the creation of an object hierarchy that will
# work with publish_portlets()
sub publish_portlets {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    require XIMS::Exporter;
    my $exporter = XIMS::Exporter->new( Provider => $ctxt->data_provider,
                                        Basedir  => XIMS::PUBROOT(),
                                        User     => $ctxt->session->user
                                      );

    my $portlet_ot = XIMS::ObjectType->new( name => 'Portlet' );
    foreach my $ancestor ( @{$ctxt->object->ancestors()} ) {
        next if $ancestor->id == 1; # skip /root
        my @portlets = $ancestor->children_granted( object_type_id => $portlet_ot->id() );
        foreach my $portlet ( @portlets ) {
            my $current_user_object_priv = $ctxt->session->user->object_privmask( $portlet );
            next unless $current_user_object_priv & XIMS::Privileges::PUBLISH();
            if ( $exporter->publish( Object => $portlet ) ) {
                XIMS::Debug( 4, "Published Portlet " . $portlet->title() );
            }
            else {
                XIMS::Debug( 2, "Could not publish Portlet " . $portlet->title() );
            }
        }
    }

    return 1;
}

1;
