
=head1 NAME

XIMS::CGI::bookmark

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::bookmark;

=head1 DESCRIPTION

XIMS CGI class for managing bookmarks XIMS::CGI::defaultbookmark

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::bookmark;

use common::sense;
use parent qw( XIMS::CGI::defaultbookmark );
use XIMS::User;
use XIMS::Bookmark;
use Locale::TextDomain ('info.xims');


=head2 registerEvents()

=cut

sub registerEvents {
    my $self = shift;

    XIMS::Debug( 5, "called" );

    return $self->SUPER::registerEvents(
        qw( default
            setdefault
            create
            delete
          )
    );
}

=head2 event_init()

=cut

sub event_init {
    my ( $self, $ctxt ) = @_;

    # sanity check
    return $self->event_access_denied($ctxt) unless $ctxt->session->user();

    my $create = $self->param('create');

    my $bookmark;
    if ( not $create ) {
        my $id = $self->param('id');
        $bookmark = XIMS::Bookmark->new( id => $id );
        if ( not $ctxt->session->user->admin() ) {
            return $self->sendEvent('access_denied')
              if $bookmark->owner_id() != $ctxt->session->user->id();
        }
    }
    else {
        $bookmark = XIMS::Bookmark->new();
    }

    $ctxt->object($bookmark);    # hmmm, we do not really need
                                 # $ctxt->bookmark() since only do
                                 # post-event-redirects

    $self->skipSerialization(1);
    return 0;
}

=head2 event_default()

=cut

sub event_default {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    $self->redirToDefault($ctxt);    # redir to defaultbookmark
    return 1;
}

=head2 event_setdefault()

=cut

sub event_setdefault {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    my $bookmark = $ctxt->object();
    my $user     = $ctxt->session->user();

    if ( $user->admin() ) {
        my $uname = $self->param('name');
        $user = XIMS::User->new( name => $uname );
        if ( not( $user and $user->id() ) ) {
            XIMS::Debug( 3,
                         "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
            $self->sendError( $ctxt,
                __x( "User '{name}' does not exist.", name => $uname ) );
            return 0;
        }
    }

    my $default_bookmark
        = $user->bookmarks( explicit_only => 1, stdhome => 1 );
    if ($default_bookmark) {
        $default_bookmark->stdhome(undef);
        if ( not $default_bookmark->update() ) {
            XIMS::Debug( 3, "could not unset default bookmark" );
            $self->sendError( $ctxt, __ "Could not unset default bookmark!" );
            return 0;
        }
    }

    $bookmark->stdhome(1);
    $bookmark->update();

    $self->redirect( $self->redirect_uri($ctxt) );
    return 0;
}

=head2 event_create()

=cut

sub event_create {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    my $bookmark = $ctxt->object();
    my $user     = $ctxt->session->user();

    my $uname = $self->param('name');
    if ( $user->admin() and $uname ) {
        $user = XIMS::User->new( name => $uname );
        if ( not( $user and $user->id() ) ) {
            XIMS::Debug( 3,
                "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
            $self->sendError( $ctxt, 
                              __x("User '{name}' does not exist.", name=> $uname )
                          );
            return 0;
        }
    }

    $bookmark->owner_id( $user->id() );

    my $stdhome = $self->param('stdhome');
    if ( $stdhome and $stdhome == 1 ) {
        my $default_bookmark =
          $user->bookmarks( explicit_only => 1, stdhome => 1 );
        if ($default_bookmark) {
            $default_bookmark->stdhome(undef);
            if ( not $default_bookmark->update() ) {
                XIMS::Debug( 3, "could not unset default bookmark" );
                $self->sendError( $ctxt, __"Could not unset default bookmark!" );
                return 0;
            }
        }
    }

    $bookmark->stdhome($stdhome);

    my $path = $self->param('path');
    my $object = XIMS::Object->new( path => $path );

    if ( not defined $object ) {
        XIMS::Debug( 3, "could not find object with path '$path'!" );
        $self->sendError( $ctxt, 
                          __x("Could not find object with path '{path}'!",
                              path => $path
                          )
        );
        return 0;
    }

    $bookmark->content_id( $object->id() );
    $bookmark->create();
	
	#if we create from menu: do not redirect to user's bookmarks page
	if($self->param('redir_self')){
		$self->SUPER::redirect( $ctxt );
	}
    else {
    	$self->redirect( $self->redirect_uri($ctxt) );
    }
    return 0;
}

=head2 event_delete()

=cut

sub event_delete {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    my $bookmark = $ctxt->object();

    if ( not $bookmark->delete() ) {
        XIMS::Debug( 3,
            "could not delete bookmark with id " . $bookmark->id() );
        $self->sendError( $ctxt, __"Could not delete bookmark." );
        return 0;
    }

    $self->redirect( $self->redirect_uri($ctxt) );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

=head2 redirect_uri()

=cut

sub redirect_uri {
    my ( $self, $ctxt, $id ) = @_;

    my $uri   = URI->new( $self->url(-absolute => 1, -path => 1, -query => 1) );
    my $query = $uri->query();

    # get rid of event identifiers and old ids
    $query =~ s/(delete|create|setdefault|id)=([^&]+)//g;

    if ( $query =~ /name=([^&]+)/ ) {
        $uri->path( XIMS::GOXIMS() . '/users' );
        $uri->query("name=$1\&bookmarks=1\&$query");
    }
    else {
        $uri->path( XIMS::GOXIMS() . '/user' );
        $uri->query("bookmarks=1\&$query");
    }

    return $uri;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2015 The XIMS Project.

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

