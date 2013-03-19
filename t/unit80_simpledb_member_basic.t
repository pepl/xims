use Test::More tests => 10;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::SimpleDBMember' );
}

use XIMS::User;
use XIMS::Document;

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );

my $object = XIMS::Document->new( User => $user, location => 'TestSimpleDBMemberObject', title => 'TestSimpleDBMemberObject', language_id => 1, parent_id => 2 );
my $cid = $object->create();
cmp_ok( $cid, '>', 0, "testsimpledbmemberobject created with content_id $cid" );


my $member = XIMS::SimpleDBMember->new();
isa_ok( $member, 'XIMS::SimpleDBMember' );

$member->document_id( $object->document_id() );

my $mid = $member->create();
cmp_ok( $mid, '>', 0, "member created with id $mid" );

# fetch it back...
$member = undef;
$member = XIMS::SimpleDBMember->new( id => $mid );

ok( $member );
is( $member->document_id(), $object->document_id() , 'Testmember has correct document_id' );

ok( $member->delete(), 'Successfully deleted Testmember' );
ok( $object->delete(), 'Successfully deleted TestSimpleDBMemberObject' );

# try to fetch it back
$member = undef;
$member = XIMS::SimpleDBMember->new( id => $mid );
is( $member, undef, 'Unable to fetch deleted Testmember (OK)' );

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

