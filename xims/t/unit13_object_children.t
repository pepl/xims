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

my @kids = $o->children();


ok ( scalar( @kids ) > 0 );

ok ( $kids[0]->location() eq 'xims' );

#now, check that 'xims' has no kids

my @grandkids = $kids[0]->children();

ok( scalar( @grandkids ) == 0 ); 
