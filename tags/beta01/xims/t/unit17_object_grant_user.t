use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::DataProvider;
#use Data::Dumper;

BEGIN { 
    plan tests => 6;
}


my $admin = XIMS::User->new( id => 2 );
my $guest = XIMS::User->new( id => 1 );

ok( $admin );

my $o = XIMS::Object->new( id => 2 );

# save the old priv so we can reset;

my $old_mask = $guest->object_privmask( $o );
ok( $old_mask );

my $new_mask = XIMS::Privileges::WRITE();


my $ret = $o->grant_user_privileges( grantee => $guest, grantor => $admin, privmask => $new_mask );


#check it from the db...

my $privs = XIMS::DataProvider->new->getObjectPriv( content_id => $o->id(), grantee_id => $guest->id() );

ok( $privs );

# check for the bad caching bug...
ok( $guest->object_privmask( $o ) & $new_mask );

$ret = undef;

$ret = $o->grant_user_privileges( grantee => $guest, grantor => $admin, privmask => $old_mask );
ok( $ret and $ret == 1 );
ok( $guest->object_privmask( $o ) & $old_mask );


