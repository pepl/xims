# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package anondiscussionforum;

use strict;

use vars qw($VERSION @ISA);

use folder;
use XIMS::CGI;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( folder );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getchildren->addinfo( 1 );
    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_default( $ctxt );
}

# override SUPER::events
sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    $ctxt->properties->application->style( 'error' );

    if ( $objprivs & XIMS::Privileges::PUBLISH()
         || $objprivs & XIMS::Privileges::PUBLISH_ALL() ) {

        if ( not $object->publish() ) {
            XIMS::Debug( 2, "publishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Publishing object '" . $object->title() . "' failed." );
            return 0;
        }

        # discussion forums are published through a grant to the public user
        my $boolean = $object->grant_user_privileges (  grantee         => XIMS::PUBLICUSERID(),
                                                        privilege_mask  => ( XIMS::Privileges::VIEW | XIMS::Privileges::CREATE ),
                                                        grantor         => $user->id() );

        if ( $boolean ) {
            XIMS::Debug( 6, "forum " . $object->title() . " published." );
            $ctxt->properties->application->styleprefix( 'anondiscussionforum_publish' );
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message( "Forum '" . $object->title() . "' published." );
        }
        else {
            XIMS::Debug( 2, "could not publish forum " . $object->document_id() );
        }

        # grant privileges to descendants
        my @descendants = $object->descendants();
        return unless scalar @descendants;

        XIMS::Debug( 4, "starting descendant-recursion public user grant" );
        foreach my $descendant ( @descendants ) {
            my $boolean = $descendant->grant_user_privileges ( grantee         => XIMS::PUBLICUSERID(),
                                                               privilege_mask  => ( XIMS::Privileges::VIEW | XIMS::Privileges::CREATE ),
                                                               grantor         => $user->id() );
            unless ( $boolean ) {
                XIMS::Debug( 3, "could not grant to descendant with doc_id " . $descendant->document_id() );
            }
        }
    }
    else {
        XIMS::Debug( 3, "User has no publishing privileges on this object!" );
    }

    return 0;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    $ctxt->properties->application->style( 'error' );

    if ( $objprivs & XIMS::Privileges::PUBLISH()
         || $objprivs & XIMS::Privileges::PUBLISH_ALL() ) {

        if ( not $object->unpublish() ) {
            XIMS::Debug( 2, "unpublishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Unpublishing object '" . $object->title() . "' failed." );
            return 0;
        }

        # revoke the privs
        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $object->id() );

        if ( $privs_object and $privs_object->delete() ) {
            XIMS::Debug( 6, "forum " . $object->title() . " unpublished." );
            $ctxt->properties->application->styleprefix( 'anondiscussionforum_publish' );
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message( "Forum '" . $object->title() . "' unpublished." );
        }
        else {
            XIMS::Debug( 2, "could not unpublish forum " . $object->document_id() );
        }

        # revoke privileges from descendants
        my @descendants = $object->descendants();
        return unless scalar @descendants;

        XIMS::Debug( 4, "starting descendant-recursion public user revoke" );
        foreach my $descendant ( @descendants ) {
            my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $descendant->id() );
            unless ( $privs_object and $privs_object->delete() ) {
                XIMS::Debug( 3, "could not revoke from descendant with doc_id " . $descendant->document_id() );
            }
        }
    }
    else {
        XIMS::Debug( 3, "User has no publishing privileges on this object!" );
    }

    return 0;
}



# END RUNTIME EVENTS
# #############################################################################

1;
