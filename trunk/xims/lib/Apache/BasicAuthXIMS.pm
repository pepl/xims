
=head1 NAME

Apache::BasicAuthXIMS -- A module doing basic authentication for XIMS.

=head1 VERSION

$Id:$

=head1 SYNOPSIS

use Apache::BasicAuthXIMS;

=head1 DESCRIPTION

This module allows the use of HTTP Basic Authentication to restrict access by
looking up users in the given providers.

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



=head2    handler

=head3 Parameter

    $r: request-object

 RETURNVALUES
    One of 'OK', 'AUTH_REQUIRED, 'SERVER_ERROR'

=head3 Description

Simple Basic Authentication handler using XIMS::Auth
Example Usage:

  <Locationmatch "^/godav*">
     #RewriteEngine On
     #RewriteCond %{SERVER_PORT}!443
     #RewriteRule ^(.*)$ https://host/godav/$1 [R,L]
     SetHandler perl-script
     PerlHandler goxims

    # Authentication Realm and Type (only Basic supported)
     AuthName "XIMS Authentication"
     AuthType Basic
     PerlAuthenHandler Apache::BasicAuthXIMS
     #PerlSetEnv ORACLE_HOME /od4/oracle/product/9.2.0.1.0
  </Locationmatch>

=cut

sub handler {
    my $r = shift;

    return OK unless $r->is_initial_req;

    XIMS::Debug( 5, "called from " . $r->connection->remote_ip());

    my $dp = XIMS::DATAPROVIDER();
    return SERVER_ERROR unless defined $dp;

    my ($res, $password) = $r->get_basic_auth_pw;
    return $res if $res;

    my $username = $r->connection->user;
    if ( $username and length $username and $password and length $password ) {
        my $user = XIMS::Auth->new( Username => $username, Password => $password )->authenticate();
        if ( $user and $user->id() ) {
            # Set note for godav
            $r->pnotes( ximsBasicAuthUser => $user );

            # Set notes for goxims
            my $session = XIMS::Session->new();
            $session->user_id( $user->id() );
            $r->pnotes( ximsSession   => $session );
            $r->pnotes( ximsProvider  => $user->data_provider() );
            return OK;
        }
        else {
            $r->note_basic_auth_failure;
            XIMS::Debug( 3, "user $username could not be validated");
            XIMS::Debug( 6, "user coming from " . $r->connection->remote_ip() . " for " . $r->uri );
            return AUTH_REQUIRED;
        }
    }
    else {
        $r->note_basic_auth_failure;
        $r->log_reason( "incomplete or invalid auth credentials", $r->uri);
        return AUTH_REQUIRED;
    }
}

1;


__END__

=head1 CONFIGURATION AND ENVIRONMENT

   httpd_conf, ximshttpd.conf

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2007 The XIMS Project.

See the file "LICENSE" for information and conditions for use,
reproduction, and distribution of this work, and for a DISCLAIMER OF ALL
WARRANTIES.

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

