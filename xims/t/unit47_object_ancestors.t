use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
#use Data::Dumper;

BEGIN {
    plan tests => 26;
}

# fetch the 'xims' container
my $o = XIMS::Object->new( id => 2 );

ok( $o );
ok( $o->location() eq 'xims' );

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
ok( $user );

ok( $user->name() eq 'admin' );

# now create some depth

my %c1_hash = ( title => 'Child One Dir',
                language_id => 1,
                location => 'child1',
                parent_id => $o->document_id(),
                object_type_id => 1,
                department_id => 1,
                data_format_id => 18,
              );

my $child1 = XIMS::Object->new->data( %c1_hash );
my $child1_id = $child1->create( User => $user );
ok( $child1_id and $child1_id > 1 );

my %c2_hash = ( title => 'Child Two Dir',
                language_id => 1,
                location => 'child2',
                parent_id => $child1->document_id(),
                object_type_id => 1,
                department_id => 1,
                data_format_id => 18,
              );


my $child2 = XIMS::Object->new->data( %c2_hash );
my $child2_id = $child2->create( User => $user );
ok( $child2_id and $child2_id > $child1_id );

my %c3_hash = ( title => 'Child Three Dir',
                language_id => 1,
                location => 'child3',
                parent_id => $child2->document_id(),
                object_type_id => 1,
                department_id => 1,
                data_format_id => 18,
              );


my $child3 = XIMS::Object->new->data( %c3_hash );
my $child3_id = $child3->create( User => $user  );
ok( $child3_id and $child3_id > $child2_id );

# now for the real tests:

# check location_paths
ok( $o->location_path() eq '/xims' );
ok( $child1->location_path() eq '/xims/child1' );
ok( $child2->location_path() eq '/xims/child1/child2' );
ok( $child3->location_path() eq '/xims/child1/child2/child3' );

# check ancestor count
ok( scalar @{$o->ancestors()} == 1 );
ok( scalar @{$child1->ancestors()} == 2 );
ok( scalar @{$child2->ancestors()} == 3 );
ok( scalar @{$child3->ancestors()} == 4 );

# rename and recheck location_path
$child3->location( 'child3_renamed' );
ok( $child3->update() );
ok( $child3->location_path() eq '/xims/child1/child2/child3_renamed' );

# rename with descendants and recheck location_path
$child1->location( 'child1_renamed' );
ok( $child1->update() );
ok( $child3->location_path() eq '/xims/child1_renamed/child2/child3_renamed' );

# move with descendants and recheck location_path
$child2->parent_id( $o->document_id() );
ok( $child2->update() );
ok( $child1->location_path() eq '/xims/child1_renamed' );
ok( $child2->location_path() eq '/xims/child2' );
ok( $child3->location_path() eq '/xims/child2/child3_renamed' );

# now clean up
$child3->delete();
$child2->delete();
$child1->delete();

# make sure.

$child3 = undef;
$child3 = XIMS::Object->new( id => $child3_id );
ok( $child3 == undef );

$child2 = undef;
$child2 = XIMS::Object->new( id => $child2_id );
ok( $child2 == undef );

$child1 = undef;
$child1 = XIMS::Object->new( id => $child1_id );
ok( $child1 == undef );
