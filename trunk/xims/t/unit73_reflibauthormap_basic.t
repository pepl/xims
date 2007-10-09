use Test::More tests => 24;
use strict;
use lib "../lib", "lib";
use XIMS::Test;

#use Data::Dumper;

BEGIN {
    use_ok('XIMS::RefLibAuthorMap');
}

use XIMS::RefLibReferenceType;
use XIMS::RefLibReference;
use XIMS::Document;
use XIMS::User;
use XIMS::VLibAuthor;

my $reftype = XIMS::RefLibReferenceType->new();
isa_ok( $reftype, 'XIMS::RefLibReferenceType' );
$reftype->name('TestRefTypeName');
$reftype->description('TestRefTypeDescription');
my $rtid = $reftype->create();
cmp_ok( $rtid, '>', 0, "reftype created with id $rtid" );

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );

my $object = XIMS::Document->new(
    User        => $user,
    location    => 'TestRefObject',
    title       => 'TestRefObject',
    language_id => 1,
    parent_id   => 2
);
my $cid = $object->create();
cmp_ok( $cid, '>', 0, "testrefobject created with content_id $cid" );

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $reference = XIMS::RefLibReference->new();

isa_ok( $reference, 'XIMS::RefLibReference' );

$reference->reference_type_id( $reftype->id() );
$reference->document_id( $object->document_id() );

my $rid = $reference->create();
cmp_ok( $rid, '>', 0, "reference created with id $rid" );

my $author = XIMS::VLibAuthor->new();
isa_ok( $author, 'XIMS::VLibAuthor' );

$author->lastname('TestAuthorMapLastName');
$author->middlename('TestAuthorMapMiddleName');
$author->firstname('TestAuthorMapFirstName');
$author->object_type(0);
$author->document_id(2);

my $author_id = $author->create();
cmp_ok( $author_id, '>', 0, "Author created with id $author_id" );

my $authmap = XIMS::RefLibAuthorMap->new();
isa_ok( $authmap, 'XIMS::RefLibAuthorMap' );
$authmap->reference_id( $reference->id() );
$authmap->author_id( $author->id() );
$authmap->role(0);

my $id = $authmap->create();
cmp_ok( $id, '>', 0, "AuthorMap created with id $id" );

# fetch it back...
$authmap = undef;
$authmap = XIMS::RefLibAuthorMap->new( id => $id );

ok($authmap);
is( $authmap->reference_id(),
    $reference->id(), 'TestAuthorMap has correct reference id' );
is( $authmap->author_id(), $author->id(),
    'TestAuthorMap has correct author_id' );

$authmap->position(2);
ok( $authmap->update, 'Updated TestAuthorMap' );

# fetch it back by reference_id
$authmap = undef;
$authmap = XIMS::RefLibAuthorMap->new(
    reference_id => $reference->id(),
    author_id    => $author->id,
    role         => 0
);

ok($authmap);
is( $authmap->id(), $id, 'TestAuthorMap has correct id' );
is( $authmap->position(), 2, 'TestAuthorMap has correct position' );

ok( $authmap->delete(),   'Successfully deleted Testauthormap' );
ok( $reference->delete(), 'Successfully deleted Testreference' );
ok( $object->delete(),    'Successfully deleted TestRefObject' );
ok( $reftype->delete(),   'Successfully deleted TestRefType' );
ok( $author->delete(),   'Successfully deleted test author' );

# try to fetch it back
$authmap = undef;
$authmap = XIMS::RefLibAuthorMap->new( id => $id );
is( $authmap, undef, 'Unable to fetch deleted Testauthormap (OK)' );

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

