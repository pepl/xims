use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::User;
#use Data::Dumper;

BEGIN {
    plan tests => 11;
}

##
# Basic tests for user role membership.
##

my $user = XIMS::User->new( id => 1  );
ok( $user );
ok( $user->name() eq 'xgu' );

my @roles = $user->roles_granted();
ok( scalar( @roles ) == 2 );
@roles = $user->roles_granted( default_role => 1 );
ok( scalar( @roles ) == 1 );
ok( $roles[0]->name eq 'guests' );

$user = XIMS::User->new( id => 2 );
ok( $user );
ok( $user->name() eq 'admin' );

@roles = $user->roles_granted();
ok( scalar( @roles ) == 2 );

@roles = $user->roles_granted( default_role => 1 );
ok( scalar( @roles ) == 1 ) ;
ok( $roles[0]->name eq 'admins' );
@roles = $user->roles_granted( role_master => 1 );
ok( scalar( @roles ) == 2 );
