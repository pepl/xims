
=head1 NAME

XIMS::CGI::bookmark -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::bookmark;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::bookmark;

use strict;
use base qw( XIMS::CGI::defaultbookmark );
use XIMS::User;
use XIMS::Bookmark;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

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

=head2 event_init()

=cut

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

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->redirToDefault( $ctxt ); # redir to defaultbookmark
    return 1;
}

=head2 event_setdefault()

=cut

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

=head2 event_create()

=cut

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

    if ( not defined $object ) {
        XIMS::Debug( 3, "could not find object with path '$path'!" );
        $self->sendError( $ctxt, "Could not find object with path '$path'!" );
        return 0;
    }

    $bookmark->content_id( $object->id() );
    $bookmark->create();

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 0;
}

=head2 event_delete()

=cut

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

=head2 redirect_path()

=cut

sub redirect_path {
    my ( $self, $ctxt, $id ) = @_;

    my $uri = Apache::URI->parse( $ctxt->apache() );
    my $query = $uri->query();

    # get rid of event identifiers
    $query =~ s/(delete|create|setdefault)=([^(;|&)]+)//g;

    if ( $query =~ /name=([^(;|&)]+)/ ) {
        $uri->path( XIMS::GOXIMS() . '/users' );
        $uri->query( "name=$1;bookmarks=1;$query" );
    }
    else {
        $uri->path( XIMS::GOXIMS() . '/user' );
        $uri->query( "bookmarks=1;$query" );
    }

    #warn "redirecting to ". $uri->unparse();
    return $uri->unparse();
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

Copyright (c) 2002-2007 The XIMS Project.

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

