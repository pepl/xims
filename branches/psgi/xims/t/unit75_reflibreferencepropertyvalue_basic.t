use Test::More tests => 25;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::RefLibReferencePropertyValue' );
}

use XIMS::RefLibReferenceType;
use XIMS::RefLibReferenceProperty;
use XIMS::RefLibReference;
use XIMS::User;
use XIMS::Document;

my $reftype = XIMS::RefLibReferenceType->new();
isa_ok( $reftype, 'XIMS::RefLibReferenceType' );
$reftype->name( 'TestRefTypeName' );
$reftype->description( 'TestRefTypeDescription' );
my $rtid = $reftype->create();
cmp_ok( $rtid, '>', 0, "reftype created with id $rtid" );

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );

my $object = XIMS::Document->new( User => $user, location => 'TestRefObject', title => 'TestRefObject', language_id => 1, parent_id => 2 );
my $cid = $object->create();
cmp_ok( $cid, '>', 0, "testrefobject created with content_id $cid" );

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $reference = XIMS::RefLibReference->new();

isa_ok( $reference, 'XIMS::RefLibReference' );

$reference->reference_type_id( $reftype->id() );
$reference->document_id( $object->document_id() );

my $rid = $reference->create();
cmp_ok( $rid, '>', 0, "reference created with id $rid" );

my $refproperty = XIMS::RefLibReferenceProperty->new();

isa_ok( $refproperty, 'XIMS::RefLibReferenceProperty' );

$refproperty->name( 'TestRefPropertyName' );
$refproperty->description( 'TestRefPropertyDescription' );

my $pid = $refproperty->create();
cmp_ok( $pid, '>', 0, "refproperty created with id $pid" );

my $refpropertyval = XIMS::RefLibReferencePropertyValue->new();
isa_ok( $refpropertyval, 'XIMS::RefLibReferencePropertyValue' );

$refpropertyval->reference_id( $reference->id() );
$refpropertyval->property_id( $refproperty->id() );
$refpropertyval->value( 'TestRefPropertyValue' );

my $id = $refpropertyval->create();
cmp_ok( $id, '>', 0, "refpropertyval created with id $id" );

# fetch it back...
$refpropertyval = undef;
$refpropertyval = XIMS::RefLibReferencePropertyValue->new( id => $id );

ok( $refpropertyval );
is( $refpropertyval->reference_id(), $reference->id(), 'TestPropertyVal has correct reference_id' );
is( $refpropertyval->property_id(), $refproperty->id() , 'TestPropertyVal has correct property_id' );
is( $refpropertyval->value(), 'TestRefPropertyValue' , 'TestPropertyVal has correct value' );

$refpropertyval->value( 'TestRefPropertyValue-New' );
ok( $refpropertyval->update, 'Updated TestPropertyVal' );

# fetch it back again...
$refpropertyval = undef;
$refpropertyval = XIMS::RefLibReferencePropertyValue->new( reference_id => $reference->id(), property_id => $refproperty->id() );

ok( $refpropertyval );
is( $refpropertyval->id(), $id , 'TestPropertyVal has correct id' );
is( $refpropertyval->value(), 'TestRefPropertyValue-New' , 'TestPropertyVal has correct updated value' );

ok( $refpropertyval->delete(), 'Successfully deleted TestPropertyVal' );

ok( $reference->delete(), 'Successfully deleted Testreference' );
ok( $object->delete(), 'Successfully deleted TestRefObject' );
ok( $refproperty->delete(), 'Successfully deleted TestRefProperty' );
ok( $reftype->delete(), 'Successfully deleted TestRefType' );

# try to fetch it back
$refpropertyval = undef;
$refpropertyval = XIMS::RefLibReferencePropertyValue->new( id => $id );
is( $refpropertyval, undef, 'Unable to fetch deleted TestPropertyVal (OK)' );

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

