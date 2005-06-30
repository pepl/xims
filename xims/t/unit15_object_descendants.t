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

# fetch the 'root' container
my $o = XIMS::Object->new( id => 1 );

ok( $o );

my @all_kids = $o->descendants();

ok ( scalar( @all_kids) > 0 );

#now test that the descendant_count convenience works too.

my ($d_count, $levels) = $o->descendant_count;

ok( $d_count == scalar( @all_kids) );

ok( $levels == 1);
