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
    plan tests => 14;
}

my $dp=XIMS::Test->data_provider();

my $dbh = $dp->{Driver}->{dbh} or die "failed to get db-handle!\n";

my $orig_root = _get_object_values( 1 );
my $orig_xims = _get_object_values( 2 );

# phase 1; create testsite;
# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );
#1
ok ( $root );

my $user = XIMS::User->new( id => 1 );
my $testsite = XIMS::SiteRoot->new(
                                    User => $user,
                                    parent_id => $root->id(),
                                    language_id => $root->language_id(),
                                    location => 'testsite',
                                    title => 'testsite',
                                  );
$testsite->create();
my $orig_testsite = _get_object_values( $testsite->id );
#2
ok ( $testsite->update() );
my $depth = 5;
#3
ok ( my $inner_folder = _create_folder_hierarchy( $testsite, $depth ) );
my $inner_folder_id = $inner_folder->{id};
my $orig_inner = _get_object_values( $inner_folder_id );

# phase 2; move most inner folder into 'xims'
#4
ok ( $inner_folder->move( User=>$user, target=>2 ) );
my $new_inner = _get_object_values( $inner_folder_id );
#5 
ok ( $new_inner->{PARENT_ID} == 2); 
#6
ok ( $new_inner->{DEPARTMENT_ID} == 2);
my $new_root = _get_object_values( 1 );
my $new_xims = _get_object_values( 2 );
#7
ok ( $new_root->{LFT} == $orig_root->{LFT}         and
     $new_root->{RGT} == ($orig_root->{RGT} + 12)  and
     $new_inner->{LFT} > $orig_xims->{LFT}         and
     $new_inner->{LFT} < ($new_xims->{RGT} - 1)    and
     $new_inner->{RGT} < $new_xims->{RGT}          and
     $new_inner->{RGT} > ($new_xims->{LFT} + 1)  );
#8
ok (     $new_xims->{RGT} == ($orig_xims->{RGT} + 2)   );
# phase 3; move siteroot into the previously moved folder
# 9
ok ( $testsite->move(User=>$user, target=>$inner_folder_id) );
my $new_testsite = _get_object_values( $testsite->id );

$new_root = _get_object_values( 1 );
$new_xims = _get_object_values( 2 );
$new_inner = _get_object_values( $inner_folder_id );
#10
ok ( $new_testsite->{PARENT_ID} == $inner_folder_id);
#11
ok ( $new_root->{LFT} == $orig_root->{LFT}           and
     $new_root->{RGT} == ($orig_root->{RGT} + 12)    and
     $new_testsite->{LFT} == ($new_inner->{LFT} + 1) and
     $new_testsite->{RGT} == ($new_inner->{RGT} - 1)
   );
#12
ok (  $new_testsite->{DEPARTMENT_ID} == 2);

# phase 4; clean up
#13
ok ( $inner_folder->delete(User=>$user) );

$new_root = _get_object_values( 1 );
$new_xims = _get_object_values( 2 );

# test if lft and rgt are the same again
#14
ok ( $new_root->{LFT} == $orig_root->{LFT} and
     $new_root->{RGT} == $orig_root->{RGT} and
     $new_xims->{LFT} == $orig_xims->{LFT} and
     $new_xims->{RGT} == $orig_xims->{RGT} ); 


# helpers...
sub _create_folder_hierarchy {
    my $start_object = shift;
    my $depth = shift;

    my $parent_id = $start_object->document_id();
    my $current_id;
    for ( my $i = 1; $i <= $depth; $i++) {
        my $testfolder = XIMS::Folder->new( User => $user,
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

    return undef unless $deepest_child->location() eq "testfolder$depth";
    return $deepest_child; 
}


sub _get_object_values {
    my $id = shift;
    my $rv = $dbh->fetch_select( sql => "select id,department_id,parent_id,location,lft,rgt from ci_documents where id = $id" );
    #warn Dumper( $rv );
    return $rv->[0];
}
