use Test::More tests => 13;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibPublication' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $publication = XIMS::VLibPublication->new();

isa_ok( $publication, 'XIMS::VLibPublication' );

$publication->name( 'TestPublicationName' );
$publication->volume( 'TestPublicationVolume' );
$publication->isbn( 'TestPublicationISBN' );
$publication->issn( 'TestPublicationISSN' );

my $id = $publication->create();
cmp_ok( $id, '>', 0, "Publication created with id $id" );

# fetch it back...
$publication = undef;
$publication = XIMS::VLibPublication->new( id => $id );

ok( $publication );
is( $publication->name(), 'TestPublicationName', 'TestPublication has correct name' );
is( $publication->volume(), 'TestPublicationVolume', 'TestPublication has correct volume' );
is( $publication->isbn(), 'TestPublicationISBN' , 'TestPublication has correct isbn' );
is( $publication->issn(), 'TestPublicationISSN' , 'TestPublication has correct issn' );


# now, change something
$publication->name( 'RenamedTestPublicationName' );
ok( $publication->update(), 'Updated TestPublicationName' );

# fetch it back...
$publication = undef;
$publication = XIMS::VLibPublication->new( id => $id );

ok( $publication );
is( $publication->name(), 'RenamedTestPublicationName' , 'TestPublication has correct name' );

ok( $publication->delete(), 'Successfully deleted testpublication' );

# try to fetch it back
$publication = undef;
$publication = XIMS::VLibPublication->new( id => $id );
is( $publication, undef, 'Unable to fetch deleted testpublication (OK)' );
