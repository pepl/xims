use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Folder;
use Data::Dumper;

BEGIN {
    plan tests => 6;
}

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );

ok( $root );

my @kids = $root->children();

ok ( scalar( @kids ) > 0 );

# get a specific child with the location 'xims'
my $kid = $root->children( location => 'xims' );

ok ( $kid->location() eq 'xims' );

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
ok ( $testfolder->create() );

#now, check that ''testfolder has no kids

my @grandkids = $testfolder->children();
ok( scalar( @grandkids ) == 0 );

ok( $testfolder->delete() );
