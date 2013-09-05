use Test::More tests => 27;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Document;
use XIMS::DepartmentRoot;
use XIMS::SiteRoot;
#use Data::Dumper;

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );
isa_ok( $root, 'XIMS::Object' );

my $user = XIMS::User->new( id => 1 );
my $admin = XIMS::User->new( id => 2 );

isa_ok( $user, 'XIMS::User', 'xgu' );
isa_ok( $admin, 'XIMS::User', 'admin' );

my $testsite = XIMS::SiteRoot->new(
                                    User => $admin,
                                    parent_id => $root->document_id(),
                                    location => 'testsite',
                                    title => 'testsite',
                                  );

isa_ok( $testsite, 'XIMS::SiteRoot' );
ok( $testsite->create(), 'created /testsite');

my $testdept1 = XIMS::DepartmentRoot->new(
                                    User => $admin,
                                    parent_id => $testsite->document_id(),
                                    location => 'testdept1',
                                    title => 'testdept1',
                                  );

isa_ok( $testdept1, 'XIMS::DepartmentRoot' );
ok( $testdept1->create(), 'created /testsite/testdept1');

my $testdept2 = XIMS::DepartmentRoot->new(
                                    User => $admin,
                                    parent_id => $testsite->document_id(),
                                    location => 'testdept2',
                                    title => 'testdept2',
                                  );

isa_ok( $testdept2, 'XIMS::DepartmentRoot' );
ok( $testdept2->create(), 'created /testsite/testdept2');

my $testdept3 = XIMS::DepartmentRoot->new(
                                    User => $admin,
                                    parent_id => $testdept1->document_id(),
                                    location => 'testdept3',
                                    title => 'testdept3',
                                  );

isa_ok( $testdept3, 'XIMS::DepartmentRoot' );
ok( $testdept3->create(), 'created /testsite/testdept1/testdept3');

my $depth = 3;
ok( _create_folder_hierarchy( $testdept3, $depth ), 'created folder-hierarchy under testdept3' );

my $folder = XIMS::Object->new( User => $user, path => '/testsite/testdept1/testdept3/testfolder1' );
ok ( $folder, 'fetched testfolder1' );

my $folderclone = $folder->clone( scope_subtree => 1 );
ok ( $folderclone, 'cloned testfolder1' );

my @folder_descs = $folder->descendants();
my @clone_descs = $folderclone->descendants();
map { $_->id(''); $_->{location_path}='';  $_->document_id(''); $_->parent_id(''); $_->last_modification_timestamp(''); $_->creation_timestamp('');} @folder_descs;
map { $_->id(''); $_->{location_path}=''; $_->document_id(''); $_->parent_id(''); $_->last_modification_timestamp(''); $_->creation_timestamp('');} @clone_descs;
is_deeply(\@folder_descs, \@clone_descs, 'folder and clone are the same');

my $index = XIMS::Document->new(
                              User => $user,
                              parent_id => $testdept3->document_id(),
                              location => 'index.html',
                              title => 'Index Document',
                              body => 'Welcome to the Index Document'
                             );

ok( $index->create(), 'created index document');

ok( $testdept3->add_departmentlinks( ( $index ) ), 'added departmentlinks to testdept3' );

my $testdept3clone = $testdept3->clone( scope_subtree => 1 );
ok( $testdept3clone, 'cloned testdept3' );

isnt( $testdept3->get_portlet_ids, $testdept3clone->get_portlet_ids, 'portlet id of clone has been updated' );

my $deptportlet = XIMS::Portlet->new( id => $testdept3clone->get_portlet_ids );
is( $deptportlet->location_path(), '/testsite/testdept1/copy_of_testdept3/departmentlinks_portlet.ptlt', 'portlet id points to the correct portlet' );

my $testdept3copy = $testdept3->copy( target => $testdept2->document_id(), target_location => 'testdept3copy' );
ok( $testdept3copy, 'copied testdept3 to testdept2/testdept3copy' );

is( $testdept3copy->location_path(), '/testsite/testdept2/testdept3copy', 'testdept3copy has correct location_path' );
is( $testdept3copy->department_id(), $testdept2->document_id(), 'testdept3copy has correct department_id' );

isnt( $testdept3->get_portlet_ids, $testdept3copy->get_portlet_ids, 'portlet id of copy has been updated' );
$deptportlet = XIMS::Portlet->new( id => $testdept3copy->get_portlet_ids );
is( $deptportlet->location_path(), '/testsite/testdept2/testdept3copy/departmentlinks_portlet.ptlt', 'portlet id points to the correct portlet' );

my $departmentlinksfolder = XIMS::Folder->new( path => '/testsite/testdept2/testdept3copy/departmentlinks' );
is( $deptportlet->symname_to_doc_id(), $departmentlinksfolder->document_id(), 'departmentlinks portlet points to the correct folder' );

ok( $testsite->delete(), 'deleted testsite' );

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

