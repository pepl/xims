
use Test::More tests => 12;
use strict;
use lib "../lib", "lib";
use XIMS::Test;

#use Data::Dumper;

BEGIN {
    use_ok('XIMS::VLibKeyword');
}

# make a simple one, test that the objecttype and data_formats are set by the
# constructor
my $keyword = XIMS::VLibKeyword->new();

eval { my $id = $keyword->create(); };
like( $@, qr/Query failed/, 'record insert w/o document_id must fail' );

$keyword->document_id(2);

isa_ok( $keyword, 'XIMS::VLibKeyword' );

$keyword->name('TestKeywordName');
$keyword->description('TestKeywordDescription');

my $id = $keyword->create();
cmp_ok( $id, '>', 0, "Keyword created with id $id" );

# fetch it back...
$keyword = undef;
$keyword = XIMS::VLibKeyword->new( id => $id );

ok($keyword);
is( $keyword->name(), 'TestKeywordName', 'TestKeyword has correct name' );
is( $keyword->description(), 'TestKeywordDescription',
    'TestKeyword has correct description' );

# now, change something
$keyword->name('RenamedTestKeywordName');
ok( $keyword->update(), 'Updated TestKeywordName' );

# fetch it back...
$keyword = undef;
$keyword = XIMS::VLibKeyword->new( id => $id );

ok($keyword);
is( $keyword->name(), 'RenamedTestKeywordName',
    'TestKeyword has correct name' );

ok( $keyword->delete(), 'Successfully deleted testkeyword' );

# try to fetch it back
$keyword = undef;
$keyword = XIMS::VLibKeyword->new( id => $id );
is( $keyword, undef, 'Unable to fetch deleted testkeyword (OK)' );

__END__
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

