use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::SiteRoot;
use XIMS::Folder;
use Data::Dumper;

BEGIN {
    plan tests => 7;
}

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );

ok( $root );

my $user = XIMS::User->new( id => 1 );

my $testsite = XIMS::SiteRoot->new(
                                    User => $user,
                                    parent_id => $root->id(),
                                    language_id => $root->language_id(),
                                    location => 'testsite',
                                    title => 'testsite',
                                  );

$testsite->create();
# siteroots have their document_id as department_id
$testsite->department_id( $testsite->document_id() );
ok ( $testsite->update() );

my $depth = 5;
ok ( _create_folder_hierarchy( $testsite, $depth ) );

my @all_descendants = $testsite->descendants();

ok ( scalar( @all_descendants ) == $depth );

my ($d_count, $levels) = $testsite->descendant_count;

ok( $d_count == scalar( @all_descendants ) );

ok( $levels == $depth);

ok( $testsite->delete() );

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
        $parent_id = $testfolder->document_id();
        $current_id = $testfolder->id();
    }

    my $deepest_child = XIMS::Folder->new( id => $current_id );
    return 1 if $deepest_child->location() eq "testfolder$depth";
}
