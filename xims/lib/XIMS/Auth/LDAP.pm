# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::LDAP;

use strict;
use XIMS::User;
use Net::LDAP qw(LDAP_SUCCESS);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;

    if ( $param{Server} and $param{Login} and $param{Password} ) {
        # using hardcoded port atm
        if ( my $ldap = Net::LDAP->new( $param{Server}, port => 1389 ) ) {
            # using hardcoded base atm
            my $dn = "uid=" . uc($param{Login}) . ",ou=people,o=Universitaet Innsbruck,c=AT";
            my $msg = $ldap->bind( $dn, password => $param{Password} );
            if ( $msg->code() == LDAP_SUCCESS ) {
                my $user = XIMS::User->new( name => $param{Login} );
                if ( $user and $user->enabled() ne '0' and $user->id ){
                    XIMS::Debug( 4, "user confirmed" );
                    $self = bless { User => $user}, $class;
                }
                else {
                    XIMS::Debug( 3, "user could not be found or has been disabled" );
                }
            }
            else {
                XIMS::Debug( 3, "could not authenticate" );
            }
        }
        else {
            XIMS::Debug( 2, "no connection to LDAP Server: $@" );
        }
    }

    return $self;
}

sub getUserInfo { return $_[0]->{User}; }

1;
