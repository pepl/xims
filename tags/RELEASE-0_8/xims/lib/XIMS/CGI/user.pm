# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id $
package XIMS::CGI::user;

use strict;
use vars qw( $VERSION @ISA);

use XIMS::CGI;
use XIMS::User;
use XIMS::Bookmark;

use Digest::MD5 qw( md5_hex );
#use Data::Dumper;

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

    # fill $ctxt->objectlist with the 5 last modified objects readable by the user
    # 'criteria' is a mandatory argument, so we add a dummy criteria here...
    my $object = XIMS::Object->new( User => $ctxt->session->user() );
    my @lmobjects = $object->find_objects_granted( criteria => '1 = 1',
                                                   limit => 5 );
    $ctxt->objectlist( \@lmobjects );

    # fill $ctxt->userobjectlist with the 5 objects most recently created or modified by the user
    my $qbdriver;
    if ( XIMS::DBMS() eq 'DBI' ) {
        $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split(':',$qbdriver))[1];
    }
    else {
        XIMS::Debug( 2, "search not implemented for non DBI DPs" );
        $ctxt->session->error_msg( "Search mechanism has not yet been implemented for non DBI based datastores!" );
        return 0;
    }

    $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();
    eval "require $qbdriver"; #
    if ( $@ ) {
        XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
        $ctxt->session->error_msg( "QueryBuilder-Driver could not be found!" );
        return 0;
    }

    my $qb = $qbdriver->new( { search => "u:".$ctxt->session->user->id(), allowed => q{u:\w\döäüßÖÄÜß} } );
    my $qbr = $qb->build();
    my @lmuobjects = $object->find_objects_granted( criteria => $qbr->{criteria},
                                                    limit => 5,
                                                  );
    $ctxt->userobjectlist( \@lmuobjects );
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

sub event_bookmarks {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'bookmarks' );

    $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );
    $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );

    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

1;
