use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::Session;
#use Data::Dumper;

BEGIN {
    plan tests => 24;
}

my $sess = XIMS::Session->new();
ok( $sess );

# now create a session in the DB
$sess = undef;
my ($sid, $ssid);

$sess = XIMS::Session->new( user_id => 1, auth_module => 'Fake' );
ok( $sess );

ok( defined( $sid = $sess->id() ) );
ok( defined( $ssid = $sess->session_id() ) );
ok( $sess->user_id() == 1 );
ok( defined( $sess->salt() ) );
ok( defined( $sess->token() ) );
ok( defined( $sess->last_access_timestamp() ) );
ok( defined( $sess->creation_timestamp() ) );
ok( defined( $sess->host() ) );
ok( defined( $sess->auth_module() eq 'Fake' ) );
ok( not defined $sess->attributes() );

# instanitate by session_id
$sess = undef;
$sess = XIMS::Session->new( session_id => $ssid );
ok($sess);

# test session validation and last_access_time updating
sleep 2;
ok($sess->validate('127.0.0.1'));
ok(not $sess->validate('127.0.0.2'));
ok(my $lat = Time::Piece->strptime($sess->last_access_timestamp(), '%Y-%m-%d %T') );
ok(my $ct  = Time::Piece->strptime($sess->creation_timestamp(),    '%Y-%m-%d %T') );
ok( $lat - $ct > 0 );

# void session
ok( $sess->void );

# fetching by ci_sessions.session_id must fail
$sess = undef;
$sess = XIMS::Session->new( session_id => $ssid );
ok(not defined $sess);

# fetching by the locked ci_sessions.session_id  (i.e. '!' prepended) must fail
$sess = undef;
$sess = XIMS::Session->new( session_id => "!$ssid" );
ok(not defined $sess);

# fetch by ci_sessions.id (that's why we kept it around)
$sess = undef;
$sess = XIMS::Session->new( id => $sid );
ok($sess);

# load missing data and delete.
$sess->data( %{ $sess->data_provider->getSession( id => $sid ) } );
ok( $sess->delete );

# getSession must fail now.
ok(not $sess->data_provider->getSession( id => $sid ) );

# done :)

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

