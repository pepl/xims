use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use Data::Dumper;

BEGIN { 
    plan tests => 18;
}

# first, make a new local (unserialized) one the vebose way.
my $o = XIMS::Object->new();

ok( $o );

$o->title( 'My Test Dir' );
$o->language_id( 1 );
$o->location( 'testdir' );  
$o->parent_id( 2 );
$o->object_type_id( 1 );
$o->data_format_id( 18 );

# we need a User object to fill in the right data

my $user = XIMS::User->new( id => 2 );

ok( $user );

my $id = $o->create( User => $user );

ok( $id and $id > 1 );

# now, fetch it back...

$o = undef;
$o = XIMS::Object->new( id => $id, User => $user );

ok( $o );

ok( $o->title() eq 'My Test Dir' );
ok( $o->language_id() == 1 );
ok( $o->created_by_id() == $user->id() );
ok( $o->location() eq 'testdir' );
ok( $o->parent_id() == 2 );
ok( $o->object_type_id() == 1 );
ok( $o->department_id() == 2 );
ok( $o->data_format_id() == 18 );
ok( $o->symname_to_doc_id() == undef );

# now, change something

$o->title( 'Renamed Test Dir' );

ok( $o->update() );

# now, fetch it back again

$o = undef;
$o = XIMS::Object->new( id => $id, User => $user );

ok( $o->title() eq 'Renamed Test Dir' );
ok( $o->last_modified_by_id() == $user->id() );

# now, delete the object (still not sure if we do this or
# just set 'marked_deleted' on the object;
ok ( $o->delete() );

# now try to get the deleted record.

$o = undef;
$o = XIMS::Object->new( id => $id );

ok ( $o == undef );
