use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use Data::Dumper;

BEGIN { 
    plan tests => 3;
}

# fetch the 'root' container
my $o = XIMS::Object->new( id => 1 );

ok( $o );

# get a specific child with the location 'xims'
my $kid = $o->children( location => 'xims' );

ok ( $kid );
ok ( $kid->location() eq 'xims' );
