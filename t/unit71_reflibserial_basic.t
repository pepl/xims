use Test::More tests => 13;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::RefLibSerial' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $serial = XIMS::RefLibSerial->new();

isa_ok( $serial, 'XIMS::RefLibSerial' );

$serial->title( 'TestserialTitle' );
$serial->issn( 'TestserialISSN' );

my $id = $serial->create();
cmp_ok( $id, '>', 0, "serial created with id $id" );

# fetch it back...
$serial = undef;
$serial = XIMS::RefLibSerial->new( id => $id );

ok( $serial );
is( $serial->title(), 'TestserialTitle', 'Testserial has correct title' );
is( $serial->issn(), 'TestserialISSN' , 'Testserial has correct ISSN' );

# now, change something
$serial->title( 'RenamedTestserialTitle' );
ok( $serial->update(), 'Updated TestserialTitle' );

# fetch it back...
$serial = undef;
$serial = XIMS::RefLibSerial->new( id => $id );

ok( $serial );
is( $serial->title(), 'RenamedTestserialTitle' , 'Testserial has correct title' );

# fetch it back again by ISSN lookup...
$serial = undef;
$serial = XIMS::RefLibSerial->new( issn => 'TestserialISSN' );
ok( $serial );
is( $serial->id(), $id , 'Testserial has correct id' );

ok( $serial->delete(), 'Successfully deleted Testserial' );

# try to fetch it back
$serial = undef;
$serial = XIMS::RefLibSerial->new( id => $id );
is( $serial, undef, 'Unable to fetch deleted Testserial (OK)' );

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

