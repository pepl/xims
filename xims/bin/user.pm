# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id $
package user;

use strict;
use vars qw( $VERSION @ISA);

use XIMS::CGI;
use XIMS::User;

use Digest::MD5 qw( md5_hex );

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::CGI );

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          default
          passwd
          passwd_update
          prefs
          prefs_update
          bookmarks
          bookmarks_update
          )
        );
}

sub event_init {
    my $self = shift;
    my $ctxt = shift;
    $self->SUPER::event_init( $ctxt );

    # sanity check
    return $self->event_access_denied( $ctxt ) unless $ctxt->session->user();

    $ctxt->sax_generator( 'XIMS::SAX::Generator::User' );
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # fill $ctxt->objectlist() with either
    #    the last XX objects updated by $user
    #    the last XX objects updated readable by $user
    #    the objects updated today readable by $user
}

# the 'change password' data entry screen
sub event_passwd {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::CHANGE_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'passwd' );
}
# the 'change password' confirmation and data handling screen
sub event_passwd_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::CHANGE_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    my $user = $ctxt->session->user();

    my $pass = $self->param('password');
    my $pass1 = $self->param('password1');
    my $pass2 = $self->param('password2');

    if ( $user->validate_password( $pass ) ) {
        if ($pass1 eq $pass2 and length ($pass1) > 0) {
            $user->password( Digest::MD5::md5_hex( $pass1 ) );

            if ( $user->update() ) {
                $ctxt->properties->application->style( 'update' );
                $ctxt->session->message( "Password updated successfully." );
            }
            else {
                $self->sendError( $ctxt,"Password update failed. Please check with your system adminstrator.");
            }
        }
        # otherwise, entered passwds were not the same, kick
        # 'em back to the prompt.
        else {
            $ctxt->properties->application->style( 'passwd' );
            $ctxt->session->warning_msg( "Passwords did not match." );
        }
    }
    else {
        $ctxt->properties->application->style( 'passwd' );
        $ctxt->session->warning_msg( "Wrong Password." );
    }
}

# END RUNTIME EVENTS
# #############################################################################
1;
