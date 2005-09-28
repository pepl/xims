use Test::More tests => 35;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::Object' );
}

# first, make a new local (unserialized) one the verbose way.
my $o = XIMS::Object->new();
isa_ok( $o, 'XIMS::Object' );

$o->title( 'My Test Dir' );
$o->language_id( 1 );
$o->location( 'testdir' );
$o->parent_id( 2 );
$o->object_type_id( 1 );
$o->data_format_id( 18 );

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
isa_ok( $user, 'XIMS::User' );
my $id = $o->create( User => $user );
cmp_ok( $id, '>', 1, 'User has a sane ID' );

# now, fetch it back...
$o = undef;
$o = XIMS::Object->new( id => $id, User => $user, marked_deleted => undef );
isa_ok( $o, 'XIMS::Object', 're-fetched our object, ' );

is( $o->title(), 'My Test Dir', 'testobject has correct title' );
is( $o->language_id(), 1 , 'testobject has correct language_id' );
is( $o->created_by_id(), $user->id() , 'testobject has correct created_by_id' );
is( $o->location(), 'testdir' , 'testobject has correct location' );
is( $o->parent_id(), 2 , 'testobject has correct parent_id' );
is( $o->object_type_id(), 1, 'testobject has correct object_type_id' );
is( $o->department_id(), 2, 'testobject has correct department_id' );
is( $o->data_format_id(), 18 , 'testobject has correct data_format_id' );
is( $o->symname_to_doc_id(), undef, 'testobject has undefined symname_to_doc_id' );

# now, change something
$o->title( 'Renamed Test Dir' );
ok( $o->update(), 'update title' );

# now, fetch it back again
$o = undef;
$o = XIMS::Object->new( id => $id, User => $user, marked_deleted => undef );
is( $o->title(), 'Renamed Test Dir', 'title correctly altered' );
is( $o->last_modified_by_id(), $user->id(), 'testobject has correct last_modified_by_id' );

# locking
isnt($o->locked(), 1, 'object currently not locked');
is($o->lock( User => $user ), 1, 'locking object');
is($o->locked(), 1, 'object currently locked');
isa_ok($o->locker(), 'XIMS::User');
is( $user->id(), $o->locker()->id(), 'locker has matching id');
is($o->unlock(), 1, 'unlocking object');
isnt($o->locked(), 1, 'object not locked anymore');

# trashcan, / undelete
ok ($o->trashcan(User => $user), 'thrashcan testobject');
is ($o->marked_deleted, 1, 'testobject is marked_deleted' );
is ($o->position, undef, 'testobject has undefined position' );
ok ( $o->undelete(), 'undelete testobject' );
is ($o->marked_deleted, undef, 'testobject is not marked_deleted' );
cmp_ok($o->position, '>', 0, 'testobject has a defined position' );

# valid_from, valid_to
my $valid_from = '2002-02-02 02:02:02';
my $valid_to = '2003-03-03 03:03:03';
$o->valid_from_timestamp( $valid_from );
$o->valid_to_timestamp( $valid_to );
ok( $o->update(), 'update valid_from and valid_to' );

# now, fetch it back again
$o = undef;
$o = XIMS::Object->new( id => $id, User => $user, marked_deleted => undef );
is($o->valid_from_timestamp(), $valid_from, 'valid_from_timestamp has correct value');
is($o->valid_to_timestamp(), $valid_to, 'valid_to_timestamp has correct value');

# now, delete the object (still not sure if we do this or
# just set 'marked_deleted' on the object;
ok ( $o->delete(), 'delete testobject' );

# now try to get the deleted record.
$o = undef;
$o = XIMS::Object->new( id => $id );
is ( $o, undef, 'unable to fetch deleted testobject' );
