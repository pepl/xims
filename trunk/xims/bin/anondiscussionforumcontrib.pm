# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package anondiscussionforumcontrib;

use strict;
use warnings;

use vars qw( $VERSION @ISA );

use XIMS::CGI;

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

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    # not yet reimplemented
    #$ctxt->properties->content->children->level( undef );

    $self->expand_attributes( $ctxt );

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $author = $self->param( 'author' );
    my $email     = $self->param( 'email' );
    my $coauthor  = $self->param( 'coauthor' );
    my $coemail   = $self->param( 'coemail' );

    unless ( $object->location ) {
        my $title  = $self->param( "title" );
        if ( defined $title and length $title ) {
            $self->param( name => md5_hex( $title .  $author . localtime() ) );
        }
        else {
            $self->sendError( $ctxt, "No title set!" );
            return 0;
        }
    }

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $object();

    XIMS::Debug( 6, "author $author" );
    $object->author( $author );

    XIMS::Debug( 6, "email $email" );
    $object->email( $email );

    if ( length $coauthor ) {
        XIMS::Debug( 6, "coauthor $coauthor" );
        $object->setCoAuthor( $coauthor );

        XIMS::Debug( 6, "email $coemail" );
        $object->setCoEmail( $coemail, 1 );
    }

    XIMS::Debug( 6, "ip " . $ENV{REMOTE_ADDR} );
    $object->setSenderIP( $ENV{REMOTE_ADDR} );

    my $body = $self->param( 'body' );
    if ( length $body ) {
        if ( $object->setBody( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "could not form well" );
            $self->sendError( $ctxt, $anondiscussionforumcontrib::MSG[6] );
            return 0;
        }
    }

    if ( not $dp->storeObject( -object => $object ) ) { # create and store
        XIMS::Debug( 2, "sync failure" );
        $self->sendError( $ctxt, $anondiscussionforumcontrib::MSG[3] );
        return 0;
    }

    # only if the storage of the ordinary data works we should
    # proceed.

    XIMS::Debug( 4, "sync ok" );

    # on creation we update the user priv
    if ( $bCreate ) {
        XIMS::Debug( 4, "initializing user privileges" );
        if ( not length $object->getMinorID() ) {
            XIMS::Debug( 2, "creation failed" );
            return 0;
        }
        my $user = $ctxt->{-USER};

        # grant the object to the current user
        $dp->grantUserPrivilege( -minorid   => $object->getMinorID(),
                                 -userid    => $user->getID(),
                                 -grantorid => $user->getID(),
                                 -privmask  => XIMS::Privileges::MODIFY );


        # get the anondiscussionforum-object to copy the grants from
        my $anondiscussionforum;
        my $ancestors = $dp->getAncestor( -object => $object );
        foreach my $opa ( @{$ancestors} ) {
            next unless $dp->getObjectType( -typeid => $opa->getObjectTypeID() )->getType() eq "AnonDiscussionForum";
            $anondiscussionforum = $opa;
        }

        # get the existing grants on the object
        my %objpm = $dp->getObjectPrivilege( -minorid => $anondiscussionforum->getMinorID(), );

        # copy the grants to the new forum contrib
        foreach my $uid ( keys %objpm ) {
            $dp->grantUserPrivilege( -minorid   => $object->getMinorID(),
                                     -userid    => $uid,
                                     -grantorid => $uid,
                                     -privmask  => $objpm{$uid},
                                   )
        }

        # because this is an anonymous forum, grant read AND create to the public-user
        # this is neccessary because the privileges copied from the forum may include VIEW but probably not CREATE
        # the contribs themselves however also need CREATE for replies
        my $role = XIMS::User->new( -ID => XIMS::PUBLICUSERID() );
        $dp->getUser( -user => $role );
        $dp->grantUserPrivilege( -minorid   => $object->getMinorID(),
                                 -userid    => $role->getID(),
                                 -grantorid => $user->getID(),
                                 -privmask  => ( XIMS::Privileges::VIEW | XIMS::Privileges::CREATE ) ); # the public-user should be able to reply
    }

    # store object back into $ctxt for further processing
    $ctxt->{-OBJECT} = $object;

    $self->redirect( $self->getRedirectPath( $ctxt ) );
    return 0;
}

# override SUPER::events
sub event_publish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

1;
