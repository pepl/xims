use Test::More tests => 17;
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

my $testsite = XIMS::SiteRoot->new(
                                    User => $user,
                                    parent_id => $root->id(),
                                    language_id => $root->language_id(),
                                    location => 'testsite',
                                    title => 'testsite',
                                  );

isa_ok( $testsite, 'XIMS::SiteRoot' );

ok ( $testsite->create(), 'create testsite') ;

ok ( $testsite->update(), 'update testsite');

my $depth = 5;

ok ( _create_folder_hierarchy( $testsite, $depth ), 'create folder-hierarchy' );

my @all_descendants = $testsite->descendants();
is( scalar( @all_descendants ), $depth, 'descendants' );


my ($d_count, $levels) = $testsite->descendant_count;
is( $d_count, scalar( @all_descendants ), 'descendant_count -- count' );
is( $levels, $depth, 'descendant_count -- levels' );

my @d_adm_granted = $testsite->descendants_granted(User => $admin);

is ( scalar( @d_adm_granted ), $depth, 'descendants_granted as admin (list context)' );
isa_ok ($testsite->descendants_granted(User => $admin)
       , 'XIMS::Object'
       , 'descendants_granted as admin (scalar context)'
       ); 

my @d_granted     = $testsite->descendants_granted( User => $user );
is ( scalar( @d_granted ), $depth, 'descendants_granted as user (list context)' );

my @d_foo_granted = $testsite->descendants_granted( User => $user_foo );
is ( scalar( @d_foo_granted ), 0, 'descendants_granted as user foo (list context)' );

ok( $testsite->delete(), 'delete testsite' );



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
