use strict;
use warnings;

use lib "../lib", "lib";

use Test::More tests => 33;
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Folder;
use XIMS::Document;
use XIMS::SiteRoot;
use XIMS::DepartmentRoot;
use XIMS::Importer::Object;

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );
isa_ok( $root, 'XIMS::Object' );

my $admin = XIMS::User->new( id => 2 );
isa_ok( $admin, 'XIMS::User', 'admin' );

#2
ok ( $root, "fetched /root" );

my @orig_xims_descs;# = $xims->descendant_count();

my $siteroot = import_object( 'testsite', $root, 'SiteRoot' );
ok( $siteroot, 'imported /testsite' );

my $dept1 = import_object( 'testdept1', $siteroot, 'DepartmentRoot' );
ok( $dept1, 'imported /testsite/testdept1' );
my $dept1_id = $dept1->id();

my $dept2 = import_object( 'testdept2', $siteroot, 'DepartmentRoot' );
ok( $dept2, 'imported /testsite/testdept2' );

my $depth = 5;
my $breadth = 2;
ok( create_folder_hierarchy( $dept1, $depth, $breadth ), "Created folder hierarchy below /testsite/testdept1 (depth: $depth, breadth: $breadth)");
ok( create_folder_hierarchy( $dept2, $depth, $breadth ), "Created folder hierarchy below /testsite/testdept2 (depth: $depth, breadth: $breadth)");

my @desc_count_dept1 = $dept1->descendant_count();

my $nodes = 0;
my $parent = 1;
for ( my $i = 1; $i <= $depth; ++$i ) {
    $parent = $breadth * $parent;
    $nodes += $parent;
}

is( $desc_count_dept1[0], $nodes, "dept1 has correct number of descendants");
is( $desc_count_dept1[1], $depth, "dept1 has correct number of maximum descendant level");

my $dept1folder2222 = XIMS::Folder->new( User => $admin, path => '/testsite/testdept1/folder2/folder2/folder2/folder2' );
ok( $dept1folder2222, 'fetched /testsite/testdept1/folder2/folder2/folder2/folder2' );
my $document = import_object( 'index.html', $dept1folder2222, 'Document' );
ok( $document, 'imported Document /testsite/testdept1/folder2/folder2/folder2/folder2/index.html there' );
my $docid = $document->id();

my $dept2folder2221 = XIMS::Folder->new( User => $admin, path => '/testsite/testdept2/folder2/folder2/folder2/folder1' );
ok( $dept2folder2221, 'fetched /testsite/testdept2/folder2/folder2/folder2/folder1' );

ok ( $dept1->move( User => $admin, target => $dept2folder2221->document_id() ), 'moved testdept1 there' );

# refetch to test for closed position gap
$dept2 = XIMS::DepartmentRoot->new( User => $admin, path => '/testsite/testdept2' );
is ( $dept2->position(), 1, "testdept2 got position correctly updated");

my @desc_count_dept2 = $dept2->descendant_count();
is ( $desc_count_dept2[0], $nodes*2+2, "testdept2 has got correct number of descendants");

$dept1 = XIMS::DepartmentRoot->new( User => $admin, id => $dept1_id  );
ok( $dept1, "refetched dept1");
is ( $dept1->position(), 3, "dept1 got position correctly updated");
is ( $dept1->location_path(), '/testsite/testdept2/folder2/folder2/folder2/folder1/testdept1', 'dept1 has got correct location_path');
is ( $dept1->department_id(), $dept2->document_id(), 'dept1 has got correct department_id');

$document = XIMS::Document->new( User => $admin, id => $docid );
ok( $document, "refetched document");
is ( $document->location_path(), '/testsite/testdept2/folder2/folder2/folder2/folder1/testdept1/folder2/folder2/folder2/folder2/index.html', 'document has got correct location_path');
is ( $document->department_id(), $dept1->document_id(), 'document has got correct department_id');

# move a subfolder including the document of dept1 into dept2
my $dept1folder2 = XIMS::Folder->new( User => $admin, path => '/testsite/testdept2/folder2/folder2/folder2/folder1/testdept1/folder2' );
ok( $dept1folder2, 'fetched /testsite/testdept2/folder2/folder2/folder2/folder1/testdept1/folder2' );
my $dept1folder2_id = $dept1folder2->id();
$dept1folder2->location( 'folder2moving' );
ok ( $dept1folder2->update(), "renamed it to 'folder2moving'" );
ok ( $dept1folder2->move( User => $admin, target => $dept2->document_id() ), 'moved it to dept2' );
$dept1folder2 = XIMS::Folder->new( User => $admin, path => '/testsite/testdept2/folder2moving' );
ok( $dept1folder2, 'refetched it by location_path /testsite/testdept2/folder2moving' );
is( $dept1folder2->id(), $dept1folder2_id, "object id matches" );
is( $dept1folder2->department_id(), $dept2->document_id(), "got correct department_id" );

$document = XIMS::Document->new( User => $admin, id => $docid );
ok( $document, "refetched document" );
is( $document->department_id(), $dept2->document_id(), "got correct department_id" );
is( $document->location_path(), '/testsite/testdept2/folder2moving/folder2/folder2/folder2/index.html', 'got correct location_path' );

ok ( $siteroot->delete(), 'deleted /testsite' );

sub import_object {
    my $location = shift;
    my $parent = shift;
    my $object_type = shift;
    
    my $object_class = "XIMS::$object_type";
    my $object = $object_class->new( User => $admin, location => $location );
    my $oimporter = XIMS::Importer::Object->new( User => $admin, Parent => $parent );
    my $id = $oimporter->import( $object );
    if ( defined $id ) {
        #print "created " . $object->location_path . "\n";
        return $object;
    }
    else {
        return;
    }
}

sub create_folder_hierarchy {
    my $parent = shift;
    my $depth = shift;
    my $breadth = shift;
    my $current_level = shift;
    $current_level ||= 0;

    if ( ++$current_level <= $depth ) {
        for ( my $i = 1; $i <= $breadth; $i++ ) {
            my @siblings;
            push( @siblings, import_object( "folder$i", $parent, 'Folder' ) );
            foreach my $sibling ( @siblings ) {
                create_folder_hierarchy( $sibling, $depth, $breadth, $current_level );
            }
        }
    }

    return 1;
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

