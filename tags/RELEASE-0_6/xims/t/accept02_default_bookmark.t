use Test;
BEGIN { plan tests => 3 }
use lib "../lib";
use lib "lib";
use strict;
use XIMS::Test;

my $t = XIMS::Test->new();
my $res = $t->login();
ok( $res );
ok( defined( $t->{Cookie} ) );
ok( $res->message() eq 'OK' );
