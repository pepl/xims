
=head1 NAME

XIMS::CGI::user -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::user;

=head1 DESCRIPTION

It is based on XIMS::CGI.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::user;

use strict;
use base qw( XIMS::CGI );
use XIMS::User;
use XIMS::Bookmark;
use Digest::MD5 qw( md5_hex );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents ()
=cut
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

=head2 event_init ()
=cut
sub event_init {
    my $self = shift;
    my $ctxt = shift;
    $self->SUPER::event_init( $ctxt );

    # sanity check
    return $self->event_access_denied( $ctxt ) unless $ctxt->session->user();

    $ctxt->sax_generator( 'XIMS::SAX::Generator::User' );
}

=head2 event_default ()
=cut
sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # to resolve the bookmark paths
    $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );

    # to resolve the role names
    $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );

    # fill $ctxt->objectlist with the 5 last modified objects readable by the user
    # we do not want to see the auto-generated .diff_to_second_last here
    my $object = XIMS::Object->new( User => $ctxt->session->user() );
    my @lmobjects = $object->find_objects_granted( criteria => "title <> '.diff_to_second_last'",
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

    my $search = "u:".$ctxt->session->user->name();

    # Make sure the utf8 flag is turned on, since it may not depending on the DBD driver version
    if ( not XIMS::DBENCODING() ) {
        require Encode;
        Encode::_utf8_on($search);
    }

    my $qb = $qbdriver->new( { search => $search } );
    if ( defined $qb ) {
        my ($critstring, @critvals) = @{$qb->criteria()};
        my @lmuobjects = $object->find_objects_granted( criteria => [ $critstring . " AND title <> '.diff_to_second_last'", @critvals ],
                                                        limit => 5,
                                                      );
        $ctxt->userobjectlist( \@lmuobjects );
    }
    else {
        XIMS::Debug( 3, "QueryBuilder could not find userobjectlist objects" );
    }
}

# the 'change password' data entry screen
=head2 event_passwd ()
=cut
sub event_passwd {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::CHANGE_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'passwd' );
}
# the 'change password' confirmation and data handling screen
=head2 event_passwd_update ()
=cut
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

=head2 event_bookmarks ()
=cut
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

