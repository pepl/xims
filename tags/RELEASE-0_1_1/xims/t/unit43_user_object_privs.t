use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::Names;
use XIMS::User;
use XIMS::Object;
#use Data::Dumper;

BEGIN { 
    plan tests => 23;
}

##
# Basic tests for user role membership.
##

my $user = XIMS::User->new( id => 1	 );
my $o = XIMS::Object->new( id => 2 );

ok( $user );
ok( $user->name() eq 'xgu' );

my %priv_hash  = $user->object_privileges( $o );

ok( scalar( keys( %priv_hash ) ) == 1 );
ok( defined( $priv_hash{view} ) );

# now try it with the admin.
$user = undef;
%priv_hash = ();

$user = XIMS::User->new( id => 2 );

%priv_hash  = $user->object_privileges( $o );
ok( $user );
ok( $user->name() eq 'admin' );

ok( scalar( keys( %priv_hash ) ) == 16 );
ok( defined( $priv_hash{view} ) );
ok( defined( $priv_hash{delete} ) );
ok( defined( $priv_hash{create} ) );
ok( defined( $priv_hash{write} ) );
ok( defined( $priv_hash{publish_all} ) );
ok( defined( $priv_hash{attributes_all} ) );
ok( defined( $priv_hash{publish} ) );
ok( defined( $priv_hash{master} ) );
ok( defined( $priv_hash{attributes} ) );
ok( defined( $priv_hash{delete_all} ) );
ok( defined( $priv_hash{translate} ) );
ok( defined( $priv_hash{owner} ) );
ok( defined( $priv_hash{grant_all} ) );
ok( defined( $priv_hash{grant} ) );
ok( defined( $priv_hash{move} ) );
ok( defined( $priv_hash{link} ) );




