use Test::More tests => 19;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Document;
use XIMS::User;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibMeta' );
}

# first, create a document to add VLib metadata to
my $document = XIMS::Document->new();
isa_ok( $document, 'XIMS::Document' );

$document->title( 'TestDocumentMeta' );
$document->language_id( 1 );
$document->location( 'testdocumentmeta' );
$document->parent_id( 2 ); # /xims

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );
my $id = $document->create( User => $user );
cmp_ok( $id, '>', 1, 'Document has a sane ID' );

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $meta = XIMS::VLibMeta->new();

isa_ok( $meta, 'XIMS::VLibMeta' );

$meta->document_id( $document->document_id() );
$meta->legalnotice( '© 2004 Gonkulator Inc.' );
$meta->bibliosource( 'Gonkulators in the Nu Millienium Today Conference' );
$meta->mediatype( 'Conference Talk' );
$meta->subtitle( 'A Position-Fixing' );

my $id = $meta->create();
cmp_ok( $id, '>', 0, "Meta created with id $id" );

# fetch it back...
$meta = undef;
$meta = XIMS::VLibMeta->new( id => $id );

ok( $meta );
is( $meta->document_id(), $document->document_id(), 'TestMeta has correct document_id' );
is( $meta->legalnotice(), '© 2004 Gonkulator Inc.' , 'TestMeta has correct legalnotice' );
is( $meta->bibliosource(), 'Gonkulators in the Nu Millienium Today Conference' , 'TestMeta has correct bibliosource' );
is( $meta->mediatype(), 'Conference Talk' , 'TestMeta has correct mediatype' );
is( $meta->subtitle(), 'A Position-Fixing' , 'TestMeta has correct subtitle' );


# now, change something
$meta->bibliosource( 'Gonkulators in the New Millenium Conference' );
ok( $meta->update(), 'Updated TestMetabibliosource' );

# fetch it back...
$meta = undef;
$meta = XIMS::VLibMeta->new( id => $id );

ok( $meta );
is( $meta->bibliosource(), 'Gonkulators in the New Millenium Conference' , 'TestMeta has correct bibliosource' );

# fetch it back by document_id
$meta = undef;
$meta = XIMS::VLibMeta->new( document_id => $document->document_id() );

ok( $meta );
is( $meta->id(), $id , 'TestMeta has correct id' );

ok( $meta->delete(), 'Successfully deleted testmeta' );

# try to fetch it back
$meta = undef;
$meta = XIMS::VLibMeta->new( id => $id );
is( $meta, undef, 'Unable to fetch deleted testmeta (OK)' );

ok( $document->delete(), 'Successfully deleted testdocumentmeta' );

