
=head1 NAME

XIMS::CGI::userprefs

=head1 VERSION

$Id: userprefs.pm 2232 2009-07-27 13:43:44Z haensel $

=head1 SYNOPSIS

    use XIMS::CGI::userprefs;

=head1 DESCRIPTION

XIMS CGI class for managing userprefs

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::userprefs;

use strict;
#use base qw( XIMS::CGI::defaultuserprefs );
use base qw( XIMS::CGI );
use XIMS::Object;
use XIMS::User;
use XIMS::UserPrefs;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision: 2232 $ =~ /\s+(\d+)\s*$/ );

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
	my $user = $ctxt->session->user();
    # sanity check
    return $self->event_access_denied($ctxt) unless $user;

    my $create = $self->param('create');
	
    my $userprefs;
    if ( not $create ) {
       my $id = $ctxt->session->user->id();
        warn("\nnew user prefs with id $id \n");

        $userprefs = XIMS::UserPrefs->new();
        $userprefs->id($user->id());
		$userprefs->profile_type($user->profile_type());
	    $userprefs->skin($user->skin());
	    $userprefs->publish_at_save($user->publish_at_save());
	    $userprefs->containerview_show($user->containerview_show());
#        if ( not $ctxt->session->user->admin() ) {
#            return $self->sendEvent('access_denied')
#              if $userprefs->id() != $ctxt->session->user->id();
#        }
    }
    else {
    	warn("\nnew user prefs\n");
        $userprefs = XIMS::UserPrefs->new();
    }

    $ctxt->object($userprefs);    

    $self->skipSerialization(1);
    return 0;
}

=head2 event_default()

=cut

sub event_default {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    $self->redirToDefault($ctxt);    # redir to default userprefs
    return 1;
}

=head2 event_setdefault()

=cut

sub event_setdefault {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    my $userprefs = $ctxt->object();
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

    my $default_userprefs
        = $user->userprefs( profile_type => 'standard', skin => 'default', publish_at_save => 0, containerview_show => 'title' );
    if ($default_userprefs) {
        #$default_userprefs->stdhome(undef);
        if ( not $default_userprefs->update() ) {
            XIMS::Debug( 3, "could not unset default userprefs" );
            $self->sendError( $ctxt, __ "Could not unset default userprefs!" );
            return 0;
        }
    }

    #$bookmark->stdhome(1);
    $userprefs->update();

    $self->redirect( $self->redirect_path($ctxt) );
    return 0;
}

=head2 event_create()

=cut

sub event_create {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    my $userprefs = $ctxt->object();
    if(not $userprefs){$userprefs = XIMS::UserPrefs->new();}
    my $user     = $ctxt->session->user();
    
    my $id = $self->param('id');

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

    $userprefs->id( $user->id() );

    my $profile_type = $self->param('profile_type');
    my $skin = $self->param('skin');
    my $publish_at_save = 0;
    	if($self->param('publish_at_save') eq 'on'){$publish_at_save = 1;}
    my $containerview_show = $self->param('containerview_show');
#    if ( $stdhome and $stdhome == 1 ) {
#        my $default_bookmark =
#          $user->bookmarks( explicit_only => 1, stdhome => 1 );
#        if ($default_bookmark) {
#            $default_bookmark->stdhome(undef);
#            if ( not $default_bookmark->update() ) {
#                XIMS::Debug( 3, "could not unset default bookmark" );
#                $self->sendError( $ctxt, __"Could not unset default bookmark!" );
#                return 0;
#            }
#        }
#    }

    $userprefs->profile_type($profile_type);
    $userprefs->skin($skin);
    $userprefs->publish_at_save($publish_at_save);
    $userprefs->containerview_show($containerview_show);

#    my $path = $self->param('path');
#    my $object = XIMS::Object->new( path => $path );
#
#    if ( not defined $object ) {
#        XIMS::Debug( 3, "could not find object with path '$path'!" );
#        $self->sendError( $ctxt, 
#                          __x("Could not find object with path '{path}'!",
#                              path => $path
#                          )
#        );
#        return 0;
#    }

    #$userprefs->content_id( $object->id() );
    if($id){
    	warn "\nUpdate user's preferences\n";
    	$userprefs->update();    	
    }
    else{
    	warn "\nCreate new user's preferences\n";
    	$userprefs->create();
    }

    $self->redirect( $self->redirect_path($ctxt) );
    return 0;
}

=head2 event_delete()

=cut

sub event_delete {
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "called" );

    my $userprefs = $ctxt->object();

    if ( not $userprefs->delete() ) {
        XIMS::Debug( 3,
            "could not delete userprefs with id " . $userprefs->id() );
        $self->sendError( $ctxt, __"Could not delete userprefs." );
        return 0;
    }

    $self->redirect( $self->redirect_path($ctxt) );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

=head2 redirect_path()

=cut

sub redirect_path {
    my ( $self, $ctxt, $id ) = @_;

    my $uri   = Apache::URI->parse( $ctxt->apache() );
    my $query = $uri->query();

    # get rid of event identifiers
    $query =~ s/(delete|create|setdefault)=([^(;|&)]+)//g;

    if ( $query =~ /name=([^(;|&)]+)/ ) {
        $uri->path( XIMS::GOXIMS() . '/users' );
        $uri->query("name=$1;prefs=1;$query");
    }
    else {
        $uri->path( XIMS::GOXIMS() . '/user' );
        $uri->query("prefs=1;$query");
    }

    #warn "redirecting to ". $uri->unparse();
    return $uri->unparse();
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2009 The XIMS Project.

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

