# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package anondiscussionforumcontrib;

use strict;
use warnings;

use vars qw( $VERSION @ISA @MSG );

use XIMS::CGI;
use Text::Iconv;

use Digest::MD5 qw(md5_hex); # for location-setting (do we really need this?)

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::CGI );

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          )
        );
}

# error messages
@MSG = ( "Document body could not be converted to a well balanced string. Please consult the User's Reference for information on well-balanced document bodies." );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    my $object = $ctxt->object();
    my @descendants = $object->descendants_granted();

    $ctxt->objectlist( \@descendants );
    $self->expand_attributes( $ctxt );

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $author    = $self->param( 'author' );
    my $email     = $self->param( 'email' );
    my $coauthor  = $self->param( 'coauthor' );
    my $coemail   = $self->param( 'coemail' );
    my $title     = $self->param( 'title' );

    my $converter;
    if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
        $converter = Text::Iconv->new("UTF-8", XIMS::DBENCODING());
        $author = $converter->convert($author) if defined $author;
        $coauthor = $converter->convert($coauthor) if defined $coauthor;
        $title = $converter->convert($title) if defined $title;
    }

    if ( defined $title and length $title ) {
        $self->param( name =>  md5_hex( $title .  $author . localtime() ) );
    }
    else {
        $self->sendError( $ctxt, "No title set!" );
        return 0;
    }

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    XIMS::Debug( 6, "author $author" );
    $object->author( $author );

    XIMS::Debug( 6, "email $email" );
    $object->email( $email );

    if ( length $coauthor ) {
        XIMS::Debug( 6, "coauthor $coauthor" );
        $object->coauthor( $coauthor );

        XIMS::Debug( 6, "email $coemail" );
        $object->coemail( $coemail, 1 );
    }

    XIMS::Debug( 6, "ip " . $ENV{REMOTE_ADDR} );
    $object->senderip( $ENV{REMOTE_ADDR} );

    my $trytobalance  = $self->param( 'trytobalance' );
    my $body = $self->param( 'body' );

    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = $converter->convert($body);
        }

        my $object = $ctxt->object();
        if ( $trytobalance eq 'true' and $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        elsif ( $object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "could not convert to a well balanced string" );
            $self->sendError( $ctxt, $MSG[0] );
            return 0;
        }
    }

    my $creating;
    my $objtype = $self->param( 'objtype' );

    $creating = 1 if ($self->param( 'parid' ) and $objtype);
    if ( not defined $creating ) {
        XIMS::Debug( 6, "unlocking object" );
        $object->unlock();
        XIMS::Debug( 4, "updating existing object" );
        if ( not $object->update() ) {
            XIMS::Debug( 2, "update failed" );
            $self->sendError( $ctxt, "Update of object failed." );
            return 0;
        }
        $self->redirect( $self->redirect_path( $ctxt ) );
        return 1;
    }
    else {
        XIMS::Debug( 4, "creating new object" );
        if ( not $object->create() ) {
            XIMS::Debug( 2, "create failed" );
            $self->sendError( $ctxt, "Creation of object failed." );
            return 0;
        }

        XIMS::Debug( 4, "copying privileges of parent" );
        my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $ctxt->data_provider->getObjectPriv( content_id => $ctxt->parent->id() );
        foreach my $priv ( @object_privs ) {
            $object->grant_user_privileges(
                                        grantee   => $priv->grantee_id(),
                                        grantor   => $ctxt->session->user(),
                                        privmask  => $priv->privilege_mask(),
                                    )
        }
    }

    XIMS::Debug( 4, "redirecting" );
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

# override SUPER::events
sub event_publish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This object can not be published directly, please publish the related forum." );
    return 0;
}

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This object can not be published directly, please publish the related forum." );
    return 0;
}

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This object can not be published directly, please publish the related forum." );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

# #############################################################################
# HELPERS


# END HELPERS
# #############################################################################
1;
