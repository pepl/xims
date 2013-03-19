
use Test::More tests => 16;
use strict;
use lib "../lib", "lib";
use XIMS::Test;

#use Data::Dumper;

BEGIN {
    use_ok('XIMS::VLibPublication');
}

# make a simple one, test that the objecttype and data_formats are set by the
# constructor
my $publication = XIMS::VLibPublication->new();

isa_ok( $publication, 'XIMS::VLibPublication' );

$publication->name('TestPublicationName');
$publication->volume('TestPublicationVolume');
$publication->isbn('TestPublicationISBN');
$publication->issn('TestPublicationISSN');
$publication->url('http://xims.info/url?nonesene=lots&TestPublication=ok');
$publication->image_url(
    'http://xims.info/image%20url?nonesene=lots&TestPublication=ok');

eval { my $id = $publication->create(); };
like( $@, qr/Query failed/, 'record insert w/o document_id must fail' );

$publication->document_id(2);

my $id = $publication->create();
cmp_ok( $id, '>', 0, "Publication created with id $id" );

# fetch it back...
$publication = undef;
$publication = XIMS::VLibPublication->new( id => $id );

ok($publication);
is( $publication->name(), 'TestPublicationName',
    'TestPublication has correct name' );
is( $publication->volume(), 'TestPublicationVolume',
    'TestPublication has correct volume' );
is( $publication->isbn(), 'TestPublicationISBN',
    'TestPublication has correct isbn' );
is( $publication->issn(), 'TestPublicationISSN',
    'TestPublication has correct issn' );
is(
    $publication->url(),
    'http://xims.info/url?nonesene=lots&TestPublication=ok',
    'TestPublication has correct url'
);
is(
    $publication->image_url(),
    'http://xims.info/image%20url?nonesene=lots&TestPublication=ok',
    'TestPublication has correct image_url'
);

# now, change something
$publication->name('RenamedTestPublicationName');
ok( $publication->update(), 'Updated TestPublicationName' );

# fetch it back...
$publication = undef;
$publication = XIMS::VLibPublication->new( id => $id );

ok($publication);
is( $publication->name(), 'RenamedTestPublicationName',
    'TestPublication has correct name' );

ok( $publication->delete(), 'Successfully deleted testpublication' );

# try to fetch it back
$publication = undef;
$publication = XIMS::VLibPublication->new( id => $id );
is( $publication, undef, 'Unable to fetch deleted testpublication (OK)' );

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

