# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id $
package XIMS::CGI::bookmark;

use strict;
use vars qw( $VERSION @ISA);

use XIMS::CGI::defaultbookmark;
use XIMS::User;
use XIMS::Bookmark;

#use Data::Dumper;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::CGI::defaultbookmark );

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          default
          setdefault
          create
          delete
          )
        );
}

sub event_init {
    my $self = shift;
    my $ctxt = shift;

    # sanity check
    return $self->event_access_denied( $ctxt ) unless $ctxt->session->user();

    my $create = $self->param('create');

    my $bookmark;
    if ( not $create ) {
        my $id = $self->param('id');
        $bookmark = XIMS::Bookmark->new( id => $id );
        if ( not $ctxt->session->user->admin() ) {
            return $self->sendEvent( 'access_denied' ) if $bookmark->owner_id() != $ctxt->session->user->id();
        }
    }
    else {
        $bookmark = XIMS::Bookmark->new();
    }

    $ctxt->object( $bookmark ); # hmmm, we do not really need
                                # $ctxt->bookmark() since only do post-event-redirects

    $self->skipSerialization( 1 );
    return 0;
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->redirToDefault( $ctxt ); # redir to defaultbookmark
    return 1;
}

sub event_setdefault {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $bookmark = $ctxt->object();
    my $user = $ctxt->session->user();

    if ( $user->admin() ) {
        my $uname = $self->param('name');
        $user = XIMS::User->new( name => $uname );
        if ( not ($user and $user->id()) ) {
            XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
            $self->sendError( $ctxt, "User '$uname' does not exist." );
            return 0;
        }
    }

    my $default_bookmark = $user->bookmarks( explicit_only => 1, stdhome => 1 );
    if ( $default_bookmark ) {
        $default_bookmark->stdhome( undef );
        if ( not $default_bookmark->update() ) {
            XIMS::Debug( 3, "could not unset default bookmark" );
            $self->sendError( $ctxt, "Could not unset default bookmark!" );
            return 0;
        }
    }

    $bookmark->stdhome( 1 );
    $bookmark->update();

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 0;
}

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $bookmark = $ctxt->object();
    my $user = $ctxt->session->user();

    my $uname = $self->param('name');
    if ( $user->admin() and $uname ) {
        $user = XIMS::User->new( name => $uname );
        if ( not ($user and $user->id()) ) {
            XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
            $self->sendError( $ctxt, "User '$uname' does not exist." );
            return 0;
        }
    }

    $bookmark->owner_id( $user->id() );

    my $stdhome = $self->param('stdhome');
    if ( $stdhome and $stdhome == 1 ) {
        my $default_bookmark = $user->bookmarks( explicit_only => 1, stdhome => 1 );
        if ( $default_bookmark ) {
            $default_bookmark->stdhome( undef );
            if ( not $default_bookmark->update() ) {
                XIMS::Debug( 3, "could not unset default bookmark" );
                $self->sendError( $ctxt, "Could not unset default bookmark!" );
                return 0;
            }
        }
    }

    $bookmark->stdhome( $stdhome );

    my $path = $self->param('path');
    my $object = XIMS::Object->new( path => $path );

    if ( not $object->id() ) {
        XIMS::Debug( 3, "could not find object with path '$path'!" );
        $self->sendError( $ctxt, "Could not find object with path '$path'!" );
        return 0;
    }

    $bookmark->content_id( $object->id() );
    $bookmark->create();

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 0;
}

sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $bookmark = $ctxt->object();

    if ( not $bookmark->delete() ) {
        XIMS::Debug( 3, "could not delete bookmark with id " . $bookmark->id() );
        $self->sendError( $ctxt, "Could not delete bookmark." );
        return 0;
    }

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

sub redirect_path {
    my ( $self, $ctxt, $id ) = @_;

    my $uri = Apache::URI->parse( $ctxt->apache() );
    if ( $uri->query() =~ /name=([^(;|&)]+)/ ) {
        $uri->path( XIMS::Config::goxims() . '/users' );
        $uri->query( "name=$1;bookmarks=1" );
    }
    else {
        $uri->path( XIMS::Config::goxims() . '/user' );
        $uri->query( 'bookmarks=1' );
    }

    #warn "redirecting to ". $uri->unparse();
    return $uri->unparse();
}

1;
