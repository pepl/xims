use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::DataProvider;
#use Data::Dumper;

BEGIN {
    plan tests => 9;
}

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
ok( $user );
ok( $user->name() eq 'admin' );

# select the 'xims' folder
my $o = XIMS::Object->new( id => 2, User => $user );
ok( $o );

# now put the folder in the trash
ok( $o->trashcan() );

# now fetch it back and test;

$o = undef;

$o = XIMS::Object->new( id => 2, User => $user );

ok( $o->marked_deleted() == 1 );

# check the global list
my $dp = XIMS::DataProvider->new();

my @trashed_objects = $dp->trashcan();

ok( scalar( @trashed_objects ) > 0 );
ok( grep { $_->id() == $o->id() } @trashed_objects );

# now, clean up...

ok( $o->undelete() );

$o = undef;

$o = XIMS::Object->new( id => 2 );

ok( not $o->marked_deleted() );

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

