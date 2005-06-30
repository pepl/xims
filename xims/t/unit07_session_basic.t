use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::Session;
use Data::Dumper;

BEGIN { 
    plan tests => 9;
}

my $sess = XIMS::Session->new();
ok( $sess );

# now create a session in the DB
$sess = undef;

$sess = XIMS::Session->new( user_id => 1 );
ok( $sess );
ok( $sess->user_id() == 1 );
ok( defined( $sess->id() ) );      
ok( defined( $sess->salt() ) );
ok( defined( $sess->session_id() ) );
ok( defined( $sess->last_access_timestamp() ) );
ok( defined($sess->host() ) );
ok( $sess->attributes() == undef );

