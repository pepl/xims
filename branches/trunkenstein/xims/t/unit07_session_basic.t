use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::Session;
#use Data::Dumper;

BEGIN {
    plan tests => 9;
}

my $sess = XIMS::Session->new();
ok( $sess );

# now create a session in the DB
$sess = undef;

$sess = XIMS::Session->new( user_id => 1, auth_module => 'Fake' );
ok( $sess );
ok( $sess->user_id() == 1 );
ok( defined( $sess->id() ) );
ok( defined( $sess->salt() ) );
ok( defined( $sess->session_id() ) );
ok( defined( $sess->last_access_timestamp() ) );
ok( defined($sess->host() ) );
ok( not defined $sess->attributes() );


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

