use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::User;
#use Data::Dumper;

BEGIN {
    plan tests => 41;
}

##
# Basic tests for fetching, creating, updating and deleting users.
##

my $user = XIMS::User->new();

ok( $user );

# try fetching one by ID
$user = undef;

$user = XIMS::User->new( id => 1 );
ok( $user );
ok( $user->name() eq 'xgu' );
ok( not defined $user->middlename() );
ok( $user->admin() == 0 );
ok( $user->password() eq '43a008171c3de746fde9c6e724ee1001' );
ok( not defined $user->email() );
ok( not defined $user->firstname() );
ok( not defined $user->url() );
ok( $user->id() == 1 );
ok( $user->object_type() == 0 );
ok( $user->enabled() == 1 );
ok( $user->system_privs_mask() == 0 );
ok( $user->lastname() eq 'XIMS Test User' );

# test update
$user->firstname( 'Ima' );
$user->lastname( 'Tester' );

# check the local, first
ok ( $user->firstname() eq 'Ima' );
ok ( $user->lastname() eq 'Tester' );

# now serialize...
my $ret = $user->update();
ok( $ret == 1);

# pull a fresh copy of the updated user, just be sure
$user = undef;

$user = XIMS::User->new( id => 1 );
ok ( $user->firstname() eq 'Ima' );
ok ( $user->lastname() eq 'Tester' );

# now, change it back...
$ret = undef;
$user->firstname( undef );
$user->lastname( 'XIMS Test User' );
$ret = $user->update();
ok( $ret == 1);

# test creation...
$user = undef;
$user = XIMS::User->new();

$user->firstname( 'Kip' );
$user->lastname( 'Hampton' );
$user->name( 'ubu' );
$user->admin( '1' );
$user->system_privs_mask( '1' );
$user->object_type( '0' );
$user->enabled( 1 );
$user->password( '43a008171c3de746fde9c6e724ee1001' );

my $ubu_id = $user->create();
ok( $ubu_id and $ubu_id > 2 );

# make *abolutely* sure that the data made it into the DB
$user = undef;
$user = XIMS::User->new( id => $ubu_id );
ok( $user );

ok( $user->firstname() eq 'Kip' );
ok( $user->lastname() eq 'Hampton' );
ok( $user->name() eq 'ubu' );
ok( $user->admin() == 1 );
ok( $user->system_privs_mask() == 1 );
ok( $user->object_type() == 0 );
ok( $user->enabled() ==  1 );
ok( $user->password() eq '43a008171c3de746fde9c6e724ee1001' );

# now try deleting...
$user->delete();

$user = undef;
$user = XIMS::User->new( id => $ubu_id );
ok( not defined $user );

# now, test loading the object via the data() method.

my %hash = ( id                => $ubu_id,
             firstname         => 'Kip',
             lastname          => 'Hampton',
             name              => 'ubu',
             admin             => 1,
             system_privs_mask => 1,
             object_type       => 0,
             enabled           => 1,
             password          => '43a008171c3de746fde9c6e724ee1001'
           );


$user = undef;
$user = XIMS::User->new->data( %hash );

ok( $user );
ok( $user->id() eq $ubu_id );
ok( $user->firstname() eq 'Kip' );
ok( $user->lastname() eq 'Hampton' );
ok( $user->name() eq 'ubu' );
ok( $user->admin() == 1 );
ok( $user->system_privs_mask() == 1 );
ok( $user->object_type() == 0 );
ok( $user->enabled() ==  1 );
ok( $user->password() eq '43a008171c3de746fde9c6e724ee1001' );


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

