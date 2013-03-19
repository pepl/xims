use Encode;
use Test::More tests => 26;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Document;
use XIMS::User;

#use Data::Dumper;

# Bytes in the source text that have their high-bit set will be treated as being part of a literal UTF-X sequence
use utf8;

BEGIN {
    use_ok('XIMS::VLibMeta');
}

# first, create a document to add VLib metadata to
my $document = XIMS::Document->new();
isa_ok( $document, 'XIMS::Document' );

$document->title('TestDocumentMeta');
$document->language_id(1);
$document->location('testdocumentmeta');
$document->parent_id(2);    # /xims

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );
my $id = $document->create( User => $user );
cmp_ok( $id, '>', 1, 'Document has a sane ID' );

# make a simple one, test that the objecttype and data_formats are set by the
# constructor
my $meta = XIMS::VLibMeta->new();

isa_ok( $meta, 'XIMS::VLibMeta' );

$meta->document_id( $document->document_id() );
$meta->legalnotice('© 2004 Gonkulator Inc.');
$meta->bibliosource('<a href="http://xims.info/">Gonkulators in the Nü Millienium Today Conference</a>');
$meta->mediatype('Conference Talk');
$meta->subtitle('A Position-Fixing');
$meta->coverage(
    '... the spatial and temporal characteristics of the object or resource ...'
);
$meta->publisher(
    '... entity responsible for making the resource available ...');
$meta->audience('the dahut.pm');

# our timeformat is YYYY-MM-DD HH24:MI:SS

$meta->dc_date('1970-01-01 00:00:00');
$meta->date_from_timestamp('1971-11-11 11:11:00');
$meta->date_to_timestamp('1972-01-01 22:22:03');

$id = $meta->create();
cmp_ok( $id, '>', 0, "Meta created with id $id" );

# fetch it back...
$meta = undef;
$meta = XIMS::VLibMeta->new( id => $id );

ok($meta);

is( $meta->document_id(),
    $document->document_id(),
    'TestMeta has correct document_id'
);

is( $meta->legalnotice(),
    '© 2004 Gonkulator Inc.',
    'TestMeta has correct legalnotice'
);
is( $meta->bibliosource(),
    '<a href="http://xims.info/">Gonkulators in the Nü Millienium Today Conference</a>',
    'TestMeta has correct bibliosource'
);

is( $meta->mediatype(), 'Conference Talk', 'TestMeta has correct mediatype' );
is( $meta->subtitle(), 'A Position-Fixing', 'TestMeta has correct subtitle' );
is( $meta->coverage(),
    '... the spatial and temporal characteristics of the object or resource ...',
    'TestMeta has correct coverage'
);

is( $meta->publisher(),
    '... entity responsible for making the resource available ...',
    'TestMeta has correct publisher'
);
is( $meta->audience(), 'the dahut.pm', 'TestMeta has correct audience' );

is( $meta->dc_date(), '1970-01-01 00:00:00', 'TestMeta has correct dc_date' );
is( $meta->date_from_timestamp(),
    '1971-11-11 11:11:00',
    'TestMeta has correct audience date_from_timestamp'
);
is( $meta->date_to_timestamp(),
    '1972-01-01 22:22:03',
    'TestMeta has correct audience date_to_timestamp'
);

# now, change something
$meta->bibliosource('Gonkulators in the New Millenium Conference');
ok( $meta->update(), 'Updated TestMetabibliosource' );

# fetch it back...
$meta = undef;
$meta = XIMS::VLibMeta->new( id => $id );

ok($meta);
is( $meta->bibliosource(),
    'Gonkulators in the New Millenium Conference',
    'TestMeta has correct bibliosource'
);

# fetch it back by document_id
$meta = undef;
$meta = XIMS::VLibMeta->new( document_id => $document->document_id() );

ok($meta);
is( $meta->id(), $id, 'TestMeta has correct id' );

ok( $meta->delete(), 'Successfully deleted testmeta' );

# try to fetch it back
$meta = undef;
$meta = XIMS::VLibMeta->new( id => $id );
is( $meta, undef, 'Unable to fetch deleted testmeta (OK)' );

ok( $document->delete(), 'Successfully deleted testdocumentmeta' );

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

