use Test::More tests => 8;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Folder;
#use Data::Dumper;

BEGIN {
    use_ok('XIMS::Object');
}

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );

isa_ok( $root, 'XIMS::Object' );

my @kids = $root->children();

cmp_ok ( scalar( @kids ), '>', '0', 'rootfolder has children' );

# get a specific child with the location 'xims'
my $kid = $root->children( location => 'xims' );
is( $kid->location(), 'xims', 'able to get the child with location \'xims\''  );

# create a child for 'xims'
my $user = XIMS::User->new( id => 1 );
my $testfolder = XIMS::Folder->new(
                                    User => $user,
                                    parent_id => $kid->document_id(),
                                    language_id => $kid->language_id(),
                                    location => "testfolder",
                                    title => "testfolder",
                                    department_id => $kid->document_id(),
                                    );
ok ( $testfolder->create(), 'create a testfolder' );

my @grandkids = $testfolder->children();
is( scalar( @grandkids ), 0, 'testfolder has no children...' );
is( $testfolder->child_count, 0, '...thence child_count() returns zero');

ok( $testfolder->delete(), 'delete testfolder');
