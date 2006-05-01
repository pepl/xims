use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::DataProvider;
use XIMS::Object;

BEGIN {
    plan tests => 7;
}

# location_path tests

# get the root path;
my $dp = XIMS::DataProvider->new();
ok ( $dp );

my $path = $dp->location_path( id => 1 );
ok( $path eq '' );

# convenient listing methods

my @set = $dp->object_types;

ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::ObjectType') );
@set = ();

@set = $dp->data_formats;
ok( scalar( @set ) > 0 );
ok( $set[0]->isa('XIMS::DataFormat') );
@set = ();

# deactivated because they don't scale with the content, maybe add params to ask for
# default_data.sql created content
#@set = $dp->users;
#ok( scalar( @set ) > 0 );
#ok( $set[0]->isa('XIMS::User') );
#@set = ();
#
#@set = $dp->admins;
#ok( scalar( @set ) > 0 );
#ok( $set[0]->isa('XIMS::User') );
#@set = ();
#
#@set = $dp->objects;
#ok( scalar( @set ) > 0 );
#ok( $set[0]->isa('XIMS::Object') );
#@set = ();
#
#@set = $dp->trashcan;
#ok( scalar( @set ) == 0 );
#@set = ();

my $time = $dp->db_now;
ok( defined( $time ) and length( $time ) > 0 );
