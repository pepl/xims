use Test;
BEGIN { plan tests => 2 }
use lib "../lib";
use lib "lib";
use strict;
use XIMS::Test;

my $t = XIMS::Test->new();
my $res = $t->login( 'admin', '_adm1nXP' );
ok( $res );
ok( defined( $t->{Cookie} ) );
