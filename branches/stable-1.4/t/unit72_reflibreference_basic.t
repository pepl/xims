use Test::More tests => 16;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::RefLibReference' );
}

use XIMS::RefLibReferenceType;
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

# fetch it back...
$reference = undef;
$reference = XIMS::RefLibReference->new( id => $rid );

ok( $reference );
is( $reference->reference_type_id(), $reftype->id(), 'Testreference has correct reference_type_id' );
is( $reference->document_id(), $object->document_id() , 'Testreference has correct document_id' );

# fetch it back again...
$reference = undef;
$reference = XIMS::RefLibReference->new( reference_type_id => $reftype->id(), document_id => $object->document_id() );

ok( $reference );
is( $reference->id(), $rid , 'Testreference has correct id' );

ok( $reference->delete(), 'Successfully deleted Testreference' );
ok( $object->delete(), 'Successfully deleted TestRefObject' );
ok( $reftype->delete(), 'Successfully deleted TestRefType' );

# try to fetch it back
$reference = undef;
$reference = XIMS::RefLibReference->new( id => $rid );
is( $reference, undef, 'Unable to fetch deleted Testreference (OK)' );

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

