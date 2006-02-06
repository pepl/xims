# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::LDAP;

use strict;
use vars qw( $VERSION );

use XIMS::User;
use Net::LDAP qw(LDAP_SUCCESS);

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

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
            if ( $msg->code() == LDAP_SUCCESS ){
                my $user = XIMS::User->new( name => $param{Login} );
                if ( $user and $user->id ){
                    XIMS::Debug( 4, "user confirmed" );
                    $self = bless { User => $user}, $class;
                }
                else {
                    XIMS::Debug( 3, "user could not be found in xims-db" );
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
