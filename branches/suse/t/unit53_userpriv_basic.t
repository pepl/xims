use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::UserPriv;
#use Data::Dumper;

BEGIN {
    plan tests => 25;
}

my $p = XIMS::UserPriv->new();

ok( $p );

$p->grantor_id( 2 );
$p->grantee_id( 1 );
$p->id( 3 );
$p->default_role( 1 );

ok( $p->grantor_id() == 2 );
ok( $p->grantee_id() == 1 );
ok( $p->id() == 3 );
ok( $p->default_role() == 1 );


# try the more Perlish short cut
$p = undef;

my %hash = ( grantor_id   => 2,
             grantee_id   => 1,
             id   => 3,
             default_role => 1
           );

$p = XIMS::UserPriv->new->data( %hash );

ok( $p->grantor_id() == 2 );
ok( $p->grantee_id() == 1 );
ok( $p->id() == 3 );
ok( $p->default_role() == 1 );

# now try fetching a real one from the db
$p = undef;

$p = XIMS::UserPriv->new( grantee_id => 1, id => 3 );

ok( $p->grantor_id() == 2 );
ok( $p->grantee_id() == 1 );
ok( $p->id() == 3 );
ok( $p->default_role() == 1 );
ok( $p->role_master() == 0 );

# test updating
$p->role_master( 1 );
$p->update();


ok( $p->grantor_id() == 2 );
ok( $p->grantee_id() == 1 );
ok( $p->id() == 3 );
ok( $p->role_master() == 1 );

# now put it back and check
$p->role_master( 0 );
$p->update();

$p = undef;

$p = XIMS::UserPriv->new( grantee_id => 1, id => 3 );

ok( $p->grantor_id() == 2 );
ok( $p->grantee_id() == 1 );
ok( $p->id() == 3 );
ok( $p->role_master() == 0 );


# now create a new one

$p = undef;

my %newhash = ( grantor_id   => 2,
                grantee_id   => 2,
                id   => 3,
              );

$p = XIMS::UserPriv->new->data( %newhash );
$p->create();

# select it back
$p = undef;
$p = XIMS::UserPriv->new(  grantee_id => 2, id => 3 );

ok( $p );
ok( $p->id() == 3 );

# now, delete;
$p->delete();

$p = undef;
$p = XIMS::UserPriv->new(  grantee_id => 2, id => 3 );
ok( not defined $p );

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

