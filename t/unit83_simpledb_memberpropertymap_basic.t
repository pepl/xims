use Test::More tests => 33;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::SimpleDBMemberPropertyMap' );
}

use XIMS::SimpleDB;
use XIMS::SimpleDBMemberProperty;
use XIMS::User;

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );

my $simpledb = XIMS::SimpleDB->new( User => $user, location => 'TestSimpleDB', title => 'TestSimpleDB', language_id => 1, parent_id => 2 );
my $cid = $simpledb->create();
cmp_ok( $cid, '>', 0, "TestSimpleDB created with content_id $cid" );

my @memberproperties;
my @data = (
            [ ( 'Lastname', "The person's lastname" ) ],
            [ ( 'Firstname', "The person's firstname" ) ],
           );

my $i = 1;
for ( @data ) {
   my $memberproperty = XIMS::SimpleDBMemberProperty->new();
   $memberproperty->name( $_->[0] );
   #$memberproperty->type( 'string' );
   $memberproperty->description( $_->[1] );
   $memberproperty->position( ++$i );
   my $id = $memberproperty->create();
   push( @memberproperties, $memberproperty ) if defined $id;
}
is( scalar @memberproperties, 2, "Succesfully created test member properties");

#
# Manually Map
#
foreach my $memberproperty ( @memberproperties ) {
   my $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new();
   isa_ok( $memberpropertymap, 'XIMS::SimpleDBMemberPropertyMap' );

   $memberpropertymap->document_id( $simpledb->document_id() );
   $memberpropertymap->property_id( $memberproperty->id() );

   my $id = $memberpropertymap->create();
   cmp_ok( $id, '>', 0, "Memberpropertymap created with id $id" );

   # fetch it back...
   $memberpropertymap = undef;
   $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( id => $id );

   ok( $memberpropertymap );
   is( $memberpropertymap->document_id(), $simpledb->document_id(), 'TestMemberPropertyMap has correct document id' );
   is( $memberpropertymap->property_id(), $memberproperty->id() , 'TestMemberPropertyMap has correct property id' );

   # fetch it back again...
   $memberpropertymap = undef;
   $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( document_id => $simpledb->document_id(), property_id => $memberproperty->id() );

   ok( $memberpropertymap );
   is( $memberpropertymap->id(), $id , 'TestMemberPropertyMap has correct id' );

   ok( $memberpropertymap->delete(), 'Successfully deleted TestMemberPropertyMap' );

   # try to fetch it back
   $memberpropertymap = undef;
   $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( id => $id );
   is( $memberpropertymap, undef, 'Unable to fetch deleted TestMemberPropertyMap (OK)' );
}

#
# Map through XIMS::SimpleDB
#
my @mapped_member_properties = $simpledb->mapped_member_properties();
is( scalar @mapped_member_properties, 0, "XIMS::SimpleDB::mapped_member_properties() returned correct result (0)");

# map using map_member_property()
foreach my $memberproperty ( @memberproperties ) {
   my $mappid = $simpledb->map_member_property( $memberproperty );
   cmp_ok( $mappid, '>', 0, "Memberpropertymap created with id $mappid" );
}

@mapped_member_properties = $simpledb->mapped_member_properties();
is( scalar @mapped_member_properties, scalar @data, "XIMS::SimpleDB::mapped_member_properties() returned correct result (" . scalar @data . ")");

@mapped_member_properties = $simpledb->mapped_member_properties( gopublic => 0 );
is( scalar @mapped_member_properties, 0, "XIMS::SimpleDB::mapped_member_properties( gopublic => 0 ) returned correct result (0)");

# unmap using unmap_member_property()
foreach my $memberproperty ( @memberproperties ) {
   ok( $simpledb->unmap_member_property( $memberproperty ), 'Successfully unmapped property with id ' . $memberproperty->id() );
}

@mapped_member_properties = $simpledb->mapped_member_properties();
is( scalar @mapped_member_properties, 0, "XIMS::SimpleDB::mapped_member_properties() returned correct result (0)");

foreach my $memberproperty ( @memberproperties ) {
   my $mid = $memberproperty->id();
   ok( $memberproperty->delete(), "Successfully deleted TestMemberProperty with id $mid" );
}

ok( $simpledb->delete(), 'Successfully deleted TestSimpleDB' );



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

