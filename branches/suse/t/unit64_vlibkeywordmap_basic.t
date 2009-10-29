
use Test::More tests => 17;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Document;
use XIMS::User;
use XIMS::VLibKeyword;

#use Data::Dumper;

BEGIN {
    use_ok('XIMS::VLibKeywordMap');
}

# first, create a document and an keyword to add VLib KeywordMap data to
my $document = XIMS::Document->new();
isa_ok( $document, 'XIMS::Document' );

$document->title('TestDocumentKeywordMap');
$document->language_id(1);
$document->location('testdocumentkeywrdmap');
$document->parent_id(2);    # /xims

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );
my $doc_id = $document->create( User => $user );
cmp_ok( $doc_id, '>', 1, 'Document has a sane ID' );

my $keyword = XIMS::VLibKeyword->new();
isa_ok( $keyword, 'XIMS::VLibKeyword' );

$keyword->name('TestKeywordMapLastName');
$keyword->document_id(2);

my $keyword_id = $keyword->create();
cmp_ok( $keyword_id, '>', 0, "Keyword created with id $keyword_id" );

# make a simple one, test that the objecttype and data_formats are set by the
# constructor
my $keywrdmap = XIMS::VLibKeywordMap->new();

isa_ok( $keywrdmap, 'XIMS::VLibKeywordMap' );

$keywrdmap->document_id( $document->document_id() );
$keywrdmap->keyword_id( $keyword->id() );

my $id = $keywrdmap->create();
cmp_ok( $id, '>', 0, "KeywordMap created with id $id" );

# fetch it back...
$keywrdmap = undef;
$keywrdmap = XIMS::VLibKeywordMap->new( id => $id );

ok($keywrdmap);
is(
    $keywrdmap->document_id(),
    $document->document_id(),
    'TestKeywordMap has correct document_id'
);
is( $keywrdmap->keyword_id(),
    $keyword->id(), 'TestKeywordMap has correct keyword_id' );

# fetch it back by document_id
$keywrdmap = undef;
$keywrdmap = XIMS::VLibKeywordMap->new(
    document_id => $document->document_id(),
    keyword_id  => $keyword_id
);

ok($keywrdmap);
is( $keywrdmap->id(), $id, 'TestKeywordMap has correct id' );

ok( $keywrdmap->delete(), 'Successfully deleted testkeywrdmap' );

# try to fetch it back
$keywrdmap = undef;
$keywrdmap = XIMS::VLibKeywordMap->new( id => $id );
is( $keywrdmap, undef, 'Unable to fetch deleted testkeywrdmap (OK)' );

ok( $document->delete(), 'Successfully deleted testdocumentkeywrdmap' );
ok( $keyword->delete(),  'Successfully deleted testkeywordkeywrdmap' );

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

