use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use Data::Dumper;

BEGIN { 
    plan tests => 4;
}

# we need a User object to determine grants
my $admin = XIMS::User->new( id => 2 );

ok( $admin );

my $o = XIMS::Object->new( id => 1 );

ok( $o );

my @granted_kids = $o->children_granted( User => $admin );

ok( scalar( @granted_kids ) >= 1 );

@granted_kids = ();

my $guest = XIMS::User->new( id => 1 );

@granted_kids = $o->children_granted( User => $guest ); 

ok( scalar( @granted_kids ) >= 1 );

