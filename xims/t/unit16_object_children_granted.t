use Test::More tests => 6;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
#use Data::Dumper;

BEGIN { 
    use_ok('XIMS::Object');
}

# we need a User object to determine grants
my $admin = XIMS::User->new( id => 2 );
isa_ok( $admin, 'XIMS::User' );

my $o = XIMS::Object->new( id => 1 );
isa_ok( $o, 'XIMS::Object' );

my @granted_kids = $o->children_granted( User => $admin );
cmp_ok( scalar( @granted_kids ), '>=',  1, 'found granted kids for admin' );

@granted_kids = ();

my $guest = XIMS::User->new( id => 1 );
isa_ok( $guest, 'XIMS::User' );

@granted_kids = $o->children_granted( User => $guest ); 
cmp_ok( scalar( @granted_kids ), '>=',  1, 'found granted kids for guest' );
