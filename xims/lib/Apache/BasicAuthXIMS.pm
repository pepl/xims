# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package Apache::BasicAuthXIMS;

use strict;

use Apache;
use Apache::Constants qw(:common);

use XIMS;
use XIMS::DataProvider;
use XIMS::Auth;

##
#
# SYNOPSIS
#    handler
#
# PARAMETERS
#    $r: request-object
#
# RETURNVALUES
#    One of 'OK', 'AUTH_REQUIRED, 'SERVER_ERROR'
#
# DESCRIPTION
#    Simple Basic Authentication handler using XIMS::Auth
#    Example Usage:
#
#        <Locationmatch "^/godav*">
#            #RewriteEngine On
#            #RewriteCond %{SERVER_PORT}!443
#            #RewriteRule ^(.*)$ https://host/godav/$1 [R,L]
#            SetHandler perl-script
#            PerlHandler goxims
#
#            # Authentication Realm and Type (only Basic supported)
#            AuthName "XIMS Authentication"
#            AuthType Basic
#            PerlAuthenHandler Apache::BasicAuthXIMS
#            #PerlSetEnv ORACLE_HOME /od4/oracle/product/9.2.0.1.0
#        </Locationmatch>
#
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

