use Test;
BEGIN { plan tests => 4 }
use lib "../lib";
use lib "lib";
use strict;
use XIMS::Test;

my $t = XIMS::Test->new();
my $res = $t->login();
ok( $res );
ok( defined( $t->{Cookie} ) );
$res = undef;
$res = $t->get('/content/xims');
ok( $res );

my $xml;
# Check the outcome of the response
if ($res->is_success) {
    $xml = $res->content;
} 
else {
   warn "request failed: " . $res->message . ".\n";
}
ok( length($xml) > 0 );
