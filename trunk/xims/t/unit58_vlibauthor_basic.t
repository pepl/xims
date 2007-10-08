use Test::More tests => 21;
use strict;
use lib "../lib", "lib";
use XIMS::Test;

#use Data::Dumper;

BEGIN {
    use_ok('XIMS::VLibAuthor');
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $author = XIMS::VLibAuthor->new();

isa_ok( $author, 'XIMS::VLibAuthor' );

$author->lastname('TestAuthorLastName');
$author->middlename('TestAuthorMiddleName');
$author->firstname('TestAuthorFirstName');
$author->object_type(0);

$author->suffix('TestAuthorSuffix');
$author->url('http://test.author.tld/yat/%e4%f6%fc%df/');
$author->email('test+test@aut-hor.tld');

eval { my $id = $author->create(); };
like( $@, qr/Query failed/, 'record insert w/o document_id must fail' );

$author->document_id(2);

my $id = $author->create();
cmp_ok( $id, '>', 0, "Author created with id $id" );

# fetch it back...
$author = undef;
$author = XIMS::VLibAuthor->new( id => $id );

ok($author);
is( $author->lastname(), 'TestAuthorLastName',
    'Testauthor has correct lastname' );
is( $author->middlename(), 'TestAuthorMiddleName',
    'Testauthor has correct middlename' );
is( $author->firstname(), 'TestAuthorFirstName',
    'Testauthor has correct firstname' );
is( $author->object_type(), 0, 'Testauthor has correct objecttype (Person)' );

is( $author->suffix(), 'TestAuthorSuffix', 'Testauthor has correct suffix' );
is( $author->url(),
    'http://test.author.tld/yat/%e4%f6%fc%df/',
    'Testauthor has correct url'
);
is( $author->email(), 'test+test@aut-hor.tld',
    'Testauthor has correct email' );

# now, change something
$author->firstname('RenamedTestAuthorFirstName');
ok( $author->update(), 'Updated TestauthorFirstName' );

# fetch it back...
$author = undef;
$author = XIMS::VLibAuthor->new( id => $id );

ok($author);
is( $author->firstname(), 'RenamedTestAuthorFirstName',
    'Testauthor has correct firstname' );

# work other ways to use the constructor
my $author2 = XIMS::VLibAuthor->new(
    lastname    => 'TestAuthorLastName',
    firstname   => 'RenamedTestAuthorFirstName',
    middlename  => 'TestAuthorMiddleName',
    document_id => 2
);
cmp_ok( $author->id(), '==', $author2->id(),
    "fetched author w/ different constructor" );

my $author3 = XIMS::VLibAuthor->new(
    lastname    => 'TestOrgaLastName',
    object_id   => 1,
    document_id => 2
);
my $id3 = $author3->create();
cmp_ok( $id3, '>', $id, "Second author created with id $id3" );

ok( $author->delete(),  'Successfully deleted testauthor' );
ok( $author3->delete(), 'Successfully deleted second testauthor' );

# try to fetch it back
( $author, $author2, $author3 ) = ( undef, undef, undef );

$author = XIMS::VLibAuthor->new( id => $id );
is( $author, undef, 'Unable to fetch deleted testauthor (OK)' );

$author3 = XIMS::VLibAuthor->new( id => $id3 );
is( $author3, undef, 'Unable to fetch deleted second testauthor (OK)' );

