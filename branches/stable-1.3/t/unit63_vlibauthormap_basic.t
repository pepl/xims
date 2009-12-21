
use Test::More tests => 17;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Document;
use XIMS::User;
use XIMS::VLibAuthor;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibAuthorMap' );
}

# first, create a document and an author to add VLib AuthorMap data to
my $document = XIMS::Document->new();
isa_ok( $document, 'XIMS::Document' );

$document->title( 'TestDocumentAuthorMap' );
$document->language_id( 1 );
$document->location( 'testdocumentauthmap' );
$document->parent_id( 2 ); # /xims

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );
my $doc_id = $document->create( User => $user );
cmp_ok( $doc_id, '>', 1, 'Document has a sane ID' );

my $author = XIMS::VLibAuthor->new();
isa_ok( $author, 'XIMS::VLibAuthor' );

$author->lastname( 'TestAuthorMapLastName' );
$author->middlename( 'TestAuthorMapMiddleName' );
$author->firstname( 'TestAuthorMapFirstName' );
$author->document_id( 2 );
$author->object_type( 0 );

my $author_id = $author->create();
cmp_ok( $author_id, '>', 0, "Author created with id $author_id" );

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $authmap = XIMS::VLibAuthorMap->new();

isa_ok( $authmap, 'XIMS::VLibAuthorMap' );

$authmap->document_id( $document->document_id() );
$authmap->author_id( $author->id() );

my $id = $authmap->create();
cmp_ok( $id, '>', 0, "AuthorMap created with id $id" );

# fetch it back...
$authmap = undef;
$authmap = XIMS::VLibAuthorMap->new( id => $id );

ok( $authmap );
is( $authmap->document_id(), $document->document_id(), 'TestAuthorMap has correct document_id' );
is( $authmap->author_id(), $author->id(), 'TestAuthorMap has correct author_id' );

# fetch it back by document_id
$authmap = undef;
$authmap = XIMS::VLibAuthorMap->new( document_id => $document->document_id(), author_id => $author_id );

ok( $authmap );
is( $authmap->id(), $id , 'TestAuthorMap has correct id' );

ok( $authmap->delete(), 'Successfully deleted testauthmap' );

# try to fetch it back
$authmap = undef;
$authmap = XIMS::VLibAuthorMap->new( id => $id );
is( $authmap, undef, 'Unable to fetch deleted testauthmap (OK)' );

ok( $document->delete(), 'Successfully deleted test document' );
ok( $author->delete(), 'Successfully deleted test author' );


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

