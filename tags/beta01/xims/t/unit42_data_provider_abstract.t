use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::DataProvider;
use XIMS::Object;
#use Data::Dumper;

BEGIN { 
    plan tests => 15;
}

# location_path tests

# get the root path;
my $dp = XIMS::DataProvider->new();
ok ( $dp );

my $path = $dp->location_path( id => 1 );
ok( $path eq '/root' );

$path = undef;

# now get the 'xims' folder
$path = $dp->location_path( id => 2 );
ok( $path eq '/xims' );

# convenient listing methods

my @set = $dp->object_types;

ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::ObjectType') );
@set = ();

@set = $dp->data_formats;
ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::DataFormat') );
@set = ();

@set = $dp->users;
ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::User') );
@set = ();

@set = $dp->admins;
ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::User') );
@set = ();

@set = $dp->objects;
ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::Object') );
@set = ();

@set = $dp->trashcan;
ok( scalar( @set ) == 0 );
@set = ();

my $time = $dp->db_now;
ok( defined( $time ) and length( $time ) > 0 );
