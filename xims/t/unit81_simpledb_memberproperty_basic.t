use Test::More tests => 15;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::SimpleDBMemberProperty' );
}

my $memberproperty = XIMS::SimpleDBMemberProperty->new();
isa_ok( $memberproperty, 'XIMS::SimpleDBMemberProperty' );

# set some test values
$memberproperty->name( 'TestSimpleDBMemberPropertyName' );
$memberproperty->type( 'string' );
$memberproperty->regex( 'TestSimpleDBMemberPropertyRegex' );
$memberproperty->description( 'TestSimpleDBMemberPropertyDescription' );
$memberproperty->position( 100 );

my $id = $memberproperty->create();
cmp_ok( $id, '>', 0, "memberproperty created with id $id" );

# fetch it back...
$memberproperty = undef;
$memberproperty = XIMS::SimpleDBMemberProperty->new( id => $id );

ok( $memberproperty, 'Succesfully fetched member back' );
is( $memberproperty->name(), 'TestSimpleDBMemberPropertyName', 'TestSimpleDBMemberProperty has correct name' );
is( $memberproperty->type(), 'string', 'TestSimpleDBMemberProperty has correct type' );
is( $memberproperty->regex(), 'TestSimpleDBMemberPropertyRegex', 'TestSimpleDBMemberProperty has correct regex' );
is( $memberproperty->description(), 'TestSimpleDBMemberPropertyDescription' , 'TestSimpleDBMemberProperty has correct description' );
is( $memberproperty->position(), 100, 'TestSimpleDBMemberProperty has correct position' );

# now, change something
$memberproperty->name( 'RenamedTestSimpleDBMemberPropertyName' );
ok( $memberproperty->update(), 'Updated TestSimpleDBMemberPropertyName' );

# now, change something
$memberproperty->type( 'SomeInvalidType' );
eval { $memberproperty->update() };
isnt( $@, undef, 'Unable to change to an invalid type (OK)' );

# fetch it back...
$memberproperty = undef;
$memberproperty = XIMS::SimpleDBMemberProperty->new( id => $id );

ok( $memberproperty, 'Succesfully fetched member back' );
is( $memberproperty->name(), 'RenamedTestSimpleDBMemberPropertyName' , 'TestSimpleDBMemberProperty has correct name' );

ok( $memberproperty->delete(), 'Successfully deleted TestSimpleDBMemberProperty' );

# try to fetch it back
$memberproperty = undef;
$memberproperty = XIMS::SimpleDBMemberProperty->new( id => $id );
is( $memberproperty, undef, 'Unable to fetch deleted TestSimpleDBMemberProperty (OK)' );
