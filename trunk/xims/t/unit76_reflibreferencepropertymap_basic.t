use Test::More tests => 16;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::RefLibReferencePropertyMap' );
}

use XIMS::RefLibReferenceType;
use XIMS::RefLibReferenceProperty;

my $reftype = XIMS::RefLibReferenceType->new();
isa_ok( $reftype, 'XIMS::RefLibReferenceType' );
$reftype->name( 'TestRefTypeName' );
$reftype->description( 'TestRefTypeDescription' );
my $rtid = $reftype->create();
cmp_ok( $rtid, '>', 0, "reftype created with id $rtid" );

my $refproperty = XIMS::RefLibReferenceProperty->new();
isa_ok( $refproperty, 'XIMS::RefLibReferenceProperty' );
$refproperty->name( 'TestRefPropertyName' );
$refproperty->description( 'TestRefPropertyDescription' );
my $pid = $refproperty->create();
cmp_ok( $pid, '>', 0, "refproperty created with id $pid" );

my $refpropertymap = XIMS::RefLibReferencePropertyMap->new();
isa_ok( $refpropertymap, 'XIMS::RefLibReferencePropertyMap' );

$refpropertymap->reference_type_id( $reftype->id() );
$refpropertymap->property_id( $refproperty->id() );

my $id = $refpropertymap->create();
cmp_ok( $id, '>', 0, "refpropertymap created with id $id" );

# fetch it back...
$refpropertymap = undef;
$refpropertymap = XIMS::RefLibReferencePropertyMap->new( id => $id );

ok( $refpropertymap );
is( $refpropertymap->reference_type_id(), $reftype->id(), 'TestPropertyMap has correct reference type' );
is( $refpropertymap->property_id(), $refproperty->id() , 'TestPropertyMap has correct property id' );

# fetch it back again...
$refpropertymap = undef;
$refpropertymap = XIMS::RefLibReferencePropertyMap->new( reference_type_id => $reftype->id(), property_id => $refproperty->id() );

ok( $refpropertymap );
is( $refpropertymap->id(), $id , 'TestPropertyMap has correct id' );

ok( $refpropertymap->delete(), 'Successfully deleted TestPropertyMap' );

ok( $reftype->delete(), 'Successfully deleted TestRefType' );
ok( $refproperty->delete(), 'Successfully deleted TestRefProperty' );

# try to fetch it back
$refpropertymap = undef;
$refpropertymap = XIMS::RefLibReferencePropertyMap->new( id => $id );
is( $refpropertymap, undef, 'Unable to fetch deleted TestPropertyMap (OK)' );

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

