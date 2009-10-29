use Test::More tests => 17;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Document;
use XIMS::User;
use XIMS::VLibPublication;

#use Data::Dumper;

BEGIN {
    use_ok('XIMS::VLibPublicationMap');
}

# first, create a document and an publication to add VLib PublicationMap data to
my $document = XIMS::Document->new();
isa_ok( $document, 'XIMS::Document' );

$document->title('TestDocumentPublicationMap');
$document->language_id(1);
$document->location('testdocumentpubmap');
$document->parent_id(2);    # /xims

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );
my $doc_id = $document->create( User => $user );
cmp_ok( $doc_id, '>', 1, 'Document has a sane ID' );

my $publication = XIMS::VLibPublication->new();
isa_ok( $publication, 'XIMS::VLibPublication' );

$publication->name('TestPublicationMapName');
$publication->isbn('TestPublicationMapISBN');
$publication->issn('TestPublicationMapISSN');
$publication->document_id(2);

my $publication_id = $publication->create();
cmp_ok( $publication_id, '>', 0,
    "Publication created with id $publication_id" );

# make a simple one, test that the objecttype and data_formats are set by the
# constructor
my $pubmap = XIMS::VLibPublicationMap->new();

isa_ok( $pubmap, 'XIMS::VLibPublicationMap' );

$pubmap->document_id( $document->document_id() );
$pubmap->publication_id( $publication->id() );

my $id = $pubmap->create();
cmp_ok( $id, '>', 0, "PublicationMap created with id $id" );

# fetch it back...
$pubmap = undef;
$pubmap = XIMS::VLibPublicationMap->new( id => $id );

ok($pubmap);
is(
    $pubmap->document_id(),
    $document->document_id(),
    'TestPublicationMap has correct document_id'
);
is( $pubmap->publication_id(),
    $publication->id(), 'TestPublicationMap has correct publication_id' );

# fetch it back by document_id
$pubmap = undef;
$pubmap = XIMS::VLibPublicationMap->new(
    document_id    => $document->document_id(),
    publication_id => $publication_id
);

ok($pubmap);
is( $pubmap->id(), $id, 'TestPublicationMap has correct id' );

ok( $pubmap->delete(), 'Successfully deleted testpubmap' );

# try to fetch it back
$pubmap = undef;
$pubmap = XIMS::VLibPublicationMap->new( id => $id );
is( $pubmap, undef, 'Unable to fetch deleted testpubmap (OK)' );

ok( $document->delete(),    'Successfully deleted testdocumentpubmap' );
ok( $publication->delete(), 'Successfully deleted testpublicationpubmap' );

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

