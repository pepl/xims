use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Folder;

BEGIN {
    plan tests => 9;
}


# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );
#1
ok ( $root );

# fetch the 'xims' container
my $xims = XIMS::Object->new( id => 2 );

#2
ok ( $xims );

my @orig_xims_descs = $xims->descendant_count();

my $user = XIMS::User->new( id => 1 );
my $testfolder = XIMS::Folder->new(
                                    User => $user,
                                    parent_id => $root->document_id(),
                                    language_id => $root->language_id(),
                                    location => 'testfolder',
                                    title => 'testfolder',
                                  );
$testfolder->create();

my $orig_dept_id = $testfolder->department_id();

#3
ok ( $testfolder->move( User => $user, target => $xims->document_id() ) );

#4
ok ( $testfolder->department_id() == $xims->document_id() );

my @new_xims_descs = $xims->descendant_count();

#5
ok ( $new_xims_descs[0] == $orig_xims_descs[0] + 1 );

#6
ok ( $testfolder->move( User => $user, target => $root->document_id() ) );

#7
ok ( $testfolder->department_id() == $root->document_id() );

my @restored_xims_descs = $xims->descendant_count();

#8
ok ( $restored_xims_descs[0] == $orig_xims_descs[0] );

#9
ok ( $testfolder->delete() );

