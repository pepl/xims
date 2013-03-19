use Test::More tests => 22;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::SimpleDBMemberPropertyValue' );
}

use XIMS::SimpleDBMember;
use XIMS::SimpleDBMemberProperty;
use XIMS::User;
use XIMS::Document;

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );

my $object = XIMS::Document->new( User => $user, location => 'TestSimpleDBMemberObject', title => 'TestSimpleDBMemberObject', language_id => 1, parent_id => 2 );
my $cid = $object->create();
cmp_ok( $cid, '>', 0, "testsimpledbmemberobject created with content_id $cid" );

my $member = XIMS::SimpleDBMember->new();
isa_ok( $member, 'XIMS::SimpleDBMember' );

$member->document_id( $object->document_id() );

my $mid = $member->create();
cmp_ok( $mid, '>', 0, "member created with id $mid" );

my $memberproperty = XIMS::SimpleDBMemberProperty->new();
isa_ok( $memberproperty, 'XIMS::SimpleDBMemberProperty' );

# set some test values
$memberproperty->name( 'TestSimpleDBMemberPropertyName' );
$memberproperty->type( 'string' );
$memberproperty->regex( 'TestSimpleDBMemberPropertyRegex' );
$memberproperty->description( 'TestSimpleDBMemberPropertyDescription' );
$memberproperty->position( 100 );

my $id = $memberproperty->create();
cmp_ok( $id, '>', 0, "TestMemberProperty created with id $id" );

my $memberpropertyval = XIMS::SimpleDBMemberPropertyValue->new();
isa_ok( $memberpropertyval, 'XIMS::SimpleDBMemberPropertyValue' );

$memberpropertyval->member_id( $member->id() );
$memberpropertyval->property_id( $memberproperty->id() );
$memberpropertyval->value( 'TestMemberPropertyValue' );

my $id = $memberpropertyval->create();
cmp_ok( $id, '>', 0, "memberpropertyval created with id $id" );

# fetch it back...
$memberpropertyval = undef;
$memberpropertyval = XIMS::SimpleDBMemberPropertyValue->new( id => $id );

ok( $memberpropertyval );
is( $memberpropertyval->member_id(), $member->id(), 'TestPropertyVal has correct member_id' );
is( $memberpropertyval->property_id(), $memberproperty->id() , 'TestPropertyVal has correct property_id' );
is( $memberpropertyval->value(), 'TestMemberPropertyValue' , 'TestPropertyVal has correct value' );

$memberpropertyval->value( 'TestMemberPropertyValue-New' );
ok( $memberpropertyval->update, 'Updated TestPropertyVal' );

# fetch it back again...
$memberpropertyval = undef;
$memberpropertyval = XIMS::SimpleDBMemberPropertyValue->new( member_id => $member->id(), property_id => $memberproperty->id() );

ok( $memberpropertyval );
is( $memberpropertyval->id(), $id , 'TestPropertyVal has correct id' );
is( $memberpropertyval->value(), 'TestMemberPropertyValue-New' , 'TestPropertyVal has correct updated value' );

ok( $memberpropertyval->delete(), 'Successfully deleted TestPropertyVal' );

ok( $member->delete(), 'Successfully deleted TestSimpleDBMember' );
ok( $object->delete(), 'Successfully deleted TestSimpleDBMemberObject' );
ok( $memberproperty->delete(), 'Successfully deleted TestMemberProperty' );

# try to fetch it back
$memberpropertyval = undef;
$memberpropertyval = XIMS::SimpleDBMemberPropertyValue->new( id => $id );
is( $memberpropertyval, undef, 'Unable to fetch deleted TestPropertyVal (OK)' );

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

