use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
#use Data::Dumper;

BEGIN {
    plan tests => 28;
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

# refetch is needed, to reload current location_paths.
# we want in memory caching of location_paths in the object instances
# however we have no way to mark the cached location_paths as invalid if
# they have been changed by moving of the parent object... :-|
$child3 = XIMS::Object->new( User => $user, id => $child3_id );
ok( defined $child3 );
ok( $child3->location_path() eq '/xims/child1_renamed/child2/child3_renamed' );

# move with descendants, refetch children and recheck location_path
$child2->parent_id( $o->document_id() );
ok( $child2->update() );

$child1 = XIMS::Object->new( User => $user, id => $child1_id );
$child2 = XIMS::Object->new( User => $user, id => $child2_id );
$child3 = XIMS::Object->new( User => $user, id => $child3_id );
ok( defined $child1 and defined $child2 and defined $child3 );
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
ok( not defined $child3 );

$child2 = undef;
$child2 = XIMS::Object->new( id => $child2_id );
ok( not defined $child2 );

$child1 = undef;
$child1 = XIMS::Object->new( id => $child1_id );
ok( not defined $child1 );

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

