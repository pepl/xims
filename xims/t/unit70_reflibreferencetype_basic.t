use Test::More tests => 11;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::RefLibReferenceType' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $reftype = XIMS::RefLibReferenceType->new();

isa_ok( $reftype, 'XIMS::RefLibReferenceType' );

$reftype->name( 'TestRefTypeName' );
$reftype->description( 'TestRefTypeDescription' );

my $id = $reftype->create();
cmp_ok( $id, '>', 0, "reftype created with id $id" );

# fetch it back...
$reftype = undef;
$reftype = XIMS::RefLibReferenceType->new( id => $id );

ok( $reftype );
is( $reftype->name(), 'TestRefTypeName', 'TestRefType has correct name' );
is( $reftype->description(), 'TestRefTypeDescription' , 'TestRefType has correct description' );

# now, change something
$reftype->name( 'RenamedTestRefTypeName' );
ok( $reftype->update(), 'Updated TestRefTypeName' );

# fetch it back...
$reftype = undef;
$reftype = XIMS::RefLibReferenceType->new( id => $id );

ok( $reftype );
is( $reftype->name(), 'RenamedTestRefTypeName' , 'TestRefType has correct name' );

ok( $reftype->delete(), 'Successfully deleted TestRefType' );

# try to fetch it back
$reftype = undef;
$reftype = XIMS::RefLibReferenceType->new( id => $id );
is( $reftype, undef, 'Unable to fetch deleted TestRefType (OK)' );

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

