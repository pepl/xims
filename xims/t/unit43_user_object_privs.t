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
    plan tests => 24;
}

##
# Basic tests for user role membership.
##

my $user = XIMS::User->new( id => 1  );
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

ok( scalar( keys( %priv_hash ) ) == 18 );
ok( defined( $priv_hash{attributes} ) );
ok( defined( $priv_hash{attributes_all} ) );
ok( defined( $priv_hash{create} ) );
ok( defined( $priv_hash{delete} ) );
ok( defined( $priv_hash{delete_all} ) );
ok( defined( $priv_hash{grant} ) );
ok( defined( $priv_hash{grant_all} ) );
ok( defined( $priv_hash{link} ) );
ok( defined( $priv_hash{master} ) );
ok( defined( $priv_hash{move} ) );
ok( defined( $priv_hash{owner} ) );
ok( defined( $priv_hash{publish} ) );
ok( defined( $priv_hash{publish_all} ) );
ok( defined( $priv_hash{send_as_mail} ) );
ok( defined( $priv_hash{translate} ) );
ok( defined( $priv_hash{view} ) );
ok( defined( $priv_hash{write} ) );





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

