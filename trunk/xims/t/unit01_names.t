use Test;
BEGIN { plan tests => 3 }
use lib "../lib";
use strict;
use XIMS::Names;

my @r_types = XIMS::Names::resource_types();
ok( scalar( @r_types ) > 0 );

my %props_hash = XIMS::Names::properties();
ok( scalar( keys( %props_hash ) ) > 0 );

ok( scalar( keys( %props_hash ) ) == scalar( @r_types ) );
