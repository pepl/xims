use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::SAX::Generator::Content;
#use Data::Dumper;

BEGIN { 
    plan tests => 1;
}

my $o = XIMS::SAX::Generator::Content->new();

ok( $o );
