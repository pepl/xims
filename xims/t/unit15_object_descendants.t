use Test::More tests => 27;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::User;
use XIMS::SiteRoot;
use XIMS::Folder;
#use Data::Dumper;

BEGIN {
    use_ok('XIMS::Object');;
}

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );

isa_ok( $root, 'XIMS::Object' );

my $user = XIMS::User->new( id => 1 );
my $admin = XIMS::User->new( id => 2 );
my $user_foo = XIMS::User->new();

isa_ok( $user, 'XIMS::User', 'user' );
isa_ok( $admin, 'XIMS::User', 'admin' );
isa_ok( $user_foo, 'XIMS::User', 'user_foo' );

$user_foo->name( 'object_descendants_Foo' );
$user_foo->lastname( 'object_descendants_Foo' );
$user_foo->object_type( 0 );
$user_foo->system_privs_mask( 1 );
ok( $user_foo->create(), 'create user Foo' );

my $testsite = XIMS::SiteRoot->new(
                                    User => $user,
                                    parent_id => $root->document_id(),
                                    language_id => $root->language_id(),
                                    location => 'testsite',
                                    title => 'testsite',
                                  );

isa_ok( $testsite, 'XIMS::SiteRoot' );

ok( $testsite->create(), 'create testsite') ;

ok( $testsite->update(), 'update testsite');

my $depth = 5;

ok( _create_folder_hierarchy( $testsite, $depth ), 'create folder-hierarchy' );

my @all_descendants = $testsite->descendants();
is( scalar( @all_descendants ), $depth, 'descendants' );

my $descendants_iterator = $testsite->descendants();
is( $descendants_iterator->getLength(), $depth, 'descendants (scalar context, iterator interface)' );
is( scalar( @all_descendants ), $descendants_iterator->getLength(), 'sanity check array-iterator interface' );

my ($d_count, $levels) = $testsite->descendant_count;
is( $d_count, scalar( @all_descendants ), 'descendant_count -- count' );
is( $levels, $depth, 'descendant_count -- levels' );

my @d_adm_granted = $testsite->descendants_granted(User => $admin);

is( scalar( @d_adm_granted ), $depth, 'descendants_granted as admin (list context)' );
is( $testsite->descendants_granted(User => $admin)->getLength, $depth, 'descendants_granted as admin (scalar context, iterator interface)' );

my @d_granted          = $testsite->descendants_granted( User => $user );
my $d_granted_iterator = $testsite->descendants_granted( User => $user );
is( scalar( @d_granted ), $depth, 'descendants_granted as user (list context)' );
is( $d_granted_iterator->getLength(), $depth, 'descendants_granted as user (scalar context, iterator interface)' );
is( scalar( @d_granted ), $d_granted_iterator->getLength(), 'sanity check array-iterator interface' );

is( $d_granted[0]->location(), 'testfolder1', 'first descendant granted as user is testfolder1 (array interface)' );
is( $d_granted_iterator->getNext->location(), 'testfolder1', 'first descendant granted as user is testfolder1 (iterator interface)' );

my @d_foo_granted = $testsite->descendants_granted( User => $user_foo );
my $d_foo_granted_iterator = $testsite->descendants_granted( User => $user_foo );
is( scalar( @d_foo_granted ), 0, 'descendants_granted as user foo (list context)' );
is( $d_foo_granted_iterator->getLength(), 0, 'descendants_granted as user foo (scalar context, iterator interface)' );
is( scalar( @d_foo_granted ), $d_foo_granted_iterator->getLength(), 'sanity check array-iterator interface' );

ok( $testsite->delete(), 'delete testsite' );
ok( $user_foo->delete(), 'delete user Foo' );


# helpers
sub _create_folder_hierarchy {
    my $start_object = shift;
    my $depth = shift;

    my $parent_id = $start_object->document_id();
    my $current_id;
    for ( my $i = 1; $i <= $depth; $i++) {
        my $testfolder = XIMS::Folder->new(
                                            User => $user,
                                            parent_id => $parent_id,
                                            language_id => $start_object->language_id(),
                                            location => "testfolder$i",
                                            title => "testfolder$i",
                                            department_id => $start_object->document_id(),
                                          );
        $testfolder->create();
        $testfolder->grant_user_privileges( grantee => $user
                                          , grantor => $admin
                                          , privmask => XIMS::Privileges::MODIFY()
                                          );
        $parent_id = $testfolder->document_id();
        $current_id = $testfolder->id();
    }

    my $deepest_child = XIMS::Folder->new( id => $current_id );
    return 1 if $deepest_child->location() eq "testfolder$depth";
}

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

