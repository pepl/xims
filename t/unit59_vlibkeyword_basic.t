use Test::More tests => 11;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibKeyword' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $keyword = XIMS::VLibKeyword->new();

isa_ok( $keyword, 'XIMS::VLibKeyword' );

$keyword->name( 'TestKeywordName' );
$keyword->description( 'TestKeywordDescription' );

my $id = $keyword->create();
cmp_ok( $id, '>', 0, "Keyword created with id $id" );

# fetch it back...
$keyword = undef;
$keyword = XIMS::VLibKeyword->new( id => $id );

ok( $keyword );
is( $keyword->name(), 'TestKeywordName', 'TestKeyword has correct name' );
is( $keyword->description(), 'TestKeywordDescription' , 'TestKeyword has correct description' );

# now, change something
$keyword->name( 'RenamedTestKeywordName' );
ok( $keyword->update(), 'Updated TestKeywordName' );

# fetch it back...
$keyword = undef;
$keyword = XIMS::VLibKeyword->new( id => $id );

ok( $keyword );
is( $keyword->name(), 'RenamedTestKeywordName' , 'TestKeyword has correct name' );

ok( $keyword->delete(), 'Successfully deleted testkeyword' );

# try to fetch it back
$keyword = undef;
$keyword = XIMS::VLibKeyword->new( id => $id );
is( $keyword, undef, 'Unable to fetch deleted testkeyword (OK)' );
