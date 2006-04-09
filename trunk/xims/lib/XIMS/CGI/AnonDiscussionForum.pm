# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::AnonDiscussionForum;

use strict;
use base qw( XIMS::CGI::Folder );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getchildren->level( 1 );
    $ctxt->properties->content->getchildren->addinfo( 1 );
    $self->expand_attributes( $ctxt );

    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = ( XIMS::Privileges::VIEW | XIMS::Privileges::CREATE );
    $self->publish_gopublic( $ctxt, {PRIVILEGE_MASK => $privmask}  );
    return 0 if $ctxt->properties->application->style() eq 'error';
    
    # grant privileges to descendants
    my @descendants = $ctxt->object->descendants();
    return unless scalar @descendants;

    XIMS::Debug( 4, "starting descendant-recursion public user grant" );
    my $granted = 0;
    foreach my $descendant ( @descendants ) {
        my $boolean = $descendant->grant_user_privileges( grantee         => XIMS::PUBLICUSERID(),
                                                          privilege_mask  => $privmask,
                                                          grantor         => $ctxt->session->user->id() );
        unless ( $boolean ) {
            XIMS::Debug( 3, "could not grant to descendant with doc_id " . $descendant->document_id() );
        }
        else {
            $granted++;
        }
    }
    
    if ( $granted == scalar @descendants ) {
        $ctxt->session->message("Object '" .  $ctxt->object->title() . "' together with $granted related objects published.");
    }
}

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->unpublish_gopublic( $ctxt, @_ );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # revoke privileges from descendants
    my @descendants = $ctxt->object->descendants();
    return unless scalar @descendants;

    XIMS::Debug( 4, "starting descendant-recursion public user revoke" );
    foreach my $descendant ( @descendants ) {
        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $descendant->id() );
        unless ( $privs_object and $privs_object->delete() ) {
            XIMS::Debug( 3, "could not revoke from descendant with doc_id " . $descendant->document_id() );
        }
    }
}



# END RUNTIME EVENTS
# #############################################################################

1;
