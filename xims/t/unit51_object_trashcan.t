use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::DataProvider;
#use Data::Dumper;

BEGIN {
    plan tests => 7;
}

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
ok( $user );
ok( $user->name() eq 'admin' );

# select the 'xims' folder
my $o = XIMS::Object->new( id => 2, User => $user );
ok( $o );

# now put the folder in the trash

$o->trashcan();

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

$o->marked_deleted( undef );

$o->update();

$o = undef;

$o = XIMS::Object->new( id => 2 );

ok( $o->marked_deleted() == undef );
