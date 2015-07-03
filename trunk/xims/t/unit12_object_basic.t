use Test::More tests => 52;
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
$o = XIMS::Object->new( id => $id, User => $user,  marked_deleted => 0 );
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
is( $o->nav_title(), undef, 'testobject has undefined navigation title');
is( $o->nav_hide(), 0, 'testobject is not set to be hidden from navigation');


# now, change something
$o->title( 'Renamed Test Dir' );
ok( $o->update(), 'update title' );

# now, fetch it back again
$o = undef;
$o = XIMS::Object->new( id => $id, User => $user, language_id => 1, marked_deleted => 0 );
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
is ($o->marked_deleted, 0, 'testobject is not marked_deleted' );
cmp_ok($o->position, '>', 0, 'testobject has a defined position' );

# valid_from, valid_to
my $valid_from = '2002-02-02 02:02:02';
my $valid_to = '2003-03-03 03:03:03';
$o->valid_from_timestamp( $valid_from );
$o->valid_to_timestamp( $valid_to );
ok( $o->update(), 'update valid_from and valid_to' );

$o->nav_title( "Navigation" );
$o->nav_hide( 1 );
ok( $o->update(), 'update navigation properties' );

# attributes
my $val1 = 'dbi:Pg:dbname=ddd;host=10.0.0.1;mx_id=gonk234';
my $val2 = 'Bender is no "Dahut".';
my $val3 = "As I sit; Something 'happens'.";
my $val4 = 0;
my $val5 = '';
my $val6 = undef;
ok( $o->attribute( key1 => $val1 ), "setting attribute --$val1--" );
ok( $o->attribute( key2 => $val2 ), "setting attribute --$val2--" );
ok( $o->attribute( key3 => $val3 ), "setting attribute --$val3--" );
ok( $o->attribute( key4 => $val4 ), "setting attribute --$val4--" );
ok( $o->attribute( key5 => $val5 ), "setting attribute --$val5--" );
ok( $o->attribute( key6 => $val6 ), "setting attribute --$val6--" );
is( $o->attribute_by_key( 'key1' ), $val1, "attrib has correct value" );
is( $o->attribute_by_key( 'key2' ), $val2, "attrib has correct value" );
is( $o->attribute_by_key( 'key3' ), $val3, "attrib has correct value" );
is( $o->attribute_by_key( 'key4' ), $val4, "attrib has correct value" );
is( $o->attribute_by_key( 'key5' ), undef, "attrib has correct value" );
is( $o->attribute_by_key( 'key6' ), undef,    "attrib has correct value" );

# now, fetch it back again
$o = undef;
$o = XIMS::Object->new( id => $id, User => $user, marked_deleted => 0 );
is($o->valid_from_timestamp(), $valid_from, 'valid_from_timestamp has correct value');
is($o->valid_to_timestamp(), $valid_to, 'valid_to_timestamp has correct value');
is($o->nav_title(), "Navigation", 'correct value in nav_title');
is($o->nav_hide(), 1, 'correct value in nav_hide');
# now, delete the object (still not sure if we do this or
# just set 'marked_deleted' on the object;
ok ( $o->delete(), 'delete testobject' );

# now try to get the deleted record.
$o = undef;
$o = XIMS::Object->new( id => $id );
is ( $o, undef, 'unable to fetch deleted testobject' );

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

