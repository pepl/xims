
=head1 NAME

Apache::BasicAuthXIMS -- HTTP basic authentication for XIMS.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    PerlAuthenHandler Apache::BasicAuthXIMS;

See example below.

=head1 DESCRIPTION

A simple HTTP Basic Authentication handler using XIMS::Auth Example.

=head1 SUBROUTINES/METHODS

=cut

package Apache::BasicAuthXIMS;

use strict;

use Apache;
use Apache::Constants qw(:common);

use XIMS;
use XIMS::DataProvider;
use XIMS::Auth;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 handler($r)

=head3 Parameter

    $r: request object.

=head3 Returns

    One of 'OK', 'AUTH_REQUIRED', 'SERVER_ERROR'.

=cut

sub handler {
    my $r = shift;

    return OK unless $r->is_initial_req;

    XIMS::via_proxy_test($r) unless $r->pnotes('PROXY_TEST');
    XIMS::Debug( 5, "called from " . $r->connection->remote_ip() );

    my $dp = XIMS::DATAPROVIDER();
    return SERVER_ERROR unless defined $dp;

    my ( $res, $password ) = $r->get_basic_auth_pw;
    return $res if $res;

    my $username = $r->connection->user;
    if ( $username and length $username and $password and length $password ) {
        my $user
            = XIMS::Auth->new( Username => $username, Password => $password )
            ->authenticate();
        if ( $user and $user->id() ) {

            # Set note for godav
            $r->pnotes( ximsBasicAuthUser => $user );

            # Set notes for goxims
            my $session = XIMS::Session->new();
            $session->user_id( $user->id() );
            $r->pnotes( ximsSession  => $session );
            $r->pnotes( ximsProvider => $user->data_provider() );
            return OK;
        }
        else {
            $r->note_basic_auth_failure;
            XIMS::Debug( 3, "user $username could not be validated" );
            XIMS::Debug( 6,
                      "user coming from "
                    . $r->connection->remote_ip() . " for "
                    . $r->uri );
            return AUTH_REQUIRED;
        }
    }
    else {
        $r->note_basic_auth_failure;
        $r->log_reason( "incomplete or invalid auth credentials", $r->uri );
        return AUTH_REQUIRED;
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>:

(Example taken from F<ximshttpd.conf>)

   <Locationmatch "^/gobaxims*">
       SetHandler perl-script
       PerlHandler goxims
       PerlSetVar ximsgoxims /gobaxims

       # Authentication Realm and Type (only Basic supported)
       AuthName "XIMS Authentication"
       AuthType Basic

       PerlAuthenHandler Apache::BasicAuthXIMS
       #PerlSetEnv ORACLE_HOME path_to_your_oracle_home

       require valid-user
   </Locationmatch>


=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

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

