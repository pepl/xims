use Test::More tests => 9;
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
@kids = $root->children( location => 'xims' );
is( $kids[0]->location(), 'xims', 'could get the child with location \'xims\' using the array interface' );
my $kid_iterator = $root->children( location => 'xims' );
my $kid =  $kid_iterator->getNext();
is( $kid->location(), 'xims', 'could get the child with location \'xims\' using the iterator interface' );

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

