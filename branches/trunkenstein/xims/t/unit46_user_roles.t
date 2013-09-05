use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::User;
#use Data::Dumper;

BEGIN {
    plan tests => 25;
}

##
# Basic tests for user role membership.
##

# xgu

my $user = XIMS::User->new( id => 1  );
ok( $user );
ok( $user->name() eq 'xgu' );

my @roles = $user->roles_granted();

ok( scalar( @roles ) == 3 );
ok( $roles[0]->name eq 'guests' );
ok( $roles[1]->name eq 'everyone' );
ok( $roles[2]->name eq 'authenticated' );

@roles = $user->roles_granted( default_role => 1 );

ok( scalar( @roles ) == 1 );
ok( $roles[0]->name eq 'guests' );
# admin

$user = XIMS::User->new( id => 2 );
ok( $user );
ok( $user->name() eq 'admin' );

@roles = $user->roles_granted();

ok( scalar( @roles ) == 3 );
ok( $roles[0]->name eq 'admins' );
ok( $roles[1]->name eq 'everyone' );
ok( $roles[2]->name eq 'authenticated' );

@roles = $user->roles_granted( default_role => 1 );
ok( scalar( @roles ) == 1 ) ;
ok( $roles[0]->name eq 'admins' );

@roles = $user->roles_granted( role_master => 1 );
ok( scalar( @roles ) == 2 );
ok( $roles[0]->name eq 'admins' );
ok( $roles[1]->name eq 'everyone' );

# public

$user = XIMS::User->new( id => 6 );
ok( $user );
ok( $user->name() eq 'public' );

@roles = $user->roles_granted();

ok( scalar( @roles ) == 1 );
ok( $roles[0]->name eq 'everyone' );

@roles = $user->roles_granted( default_role => 1 );
ok( scalar( @roles ) == 0 ) ;

@roles = $user->roles_granted( role_master => 1 );
ok( scalar( @roles ) == 0);

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

