use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::Names;
use XIMS::ObjectPriv;
#use Data::Dumper;

BEGIN { 
    plan tests => 24;
}

my $p = XIMS::ObjectPriv->new();

ok( $p );

$p->privilege_mask( 0x43012F17 );
$p->grantor_id( 2 );
$p->grantee_id( 1 );
$p->content_id( 2 );

ok( $p->privilege_mask() == XIMS::Privileges::MODIFY() );
ok( $p->grantor_id() == 2 ); 
ok( $p->grantee_id() == 1 );
ok( $p->content_id() == 2 );

# try the more Perlish short cut
$p = undef;

my %hash = ( grantor_id   => 2,
             grantee_id   => 1,
             content_id   => 2,
             privilege_mask => 0x43012F17
           );

$p = XIMS::ObjectPriv->new->data( %hash );

ok( $p->privilege_mask() == XIMS::Privileges::MODIFY() );
ok( $p->grantor_id() == 2 ); 
ok( $p->grantee_id() == 1 );
ok( $p->content_id() == 2 );

# now try fetching a real one from the db
$p = undef;

$p = XIMS::ObjectPriv->new( grantee_id => 1, content_id => 2 );

ok( $p->privilege_mask() == 1 );
ok( $p->grantor_id() == 2 ); 
ok( $p->grantee_id() == 1 );
ok( $p->content_id() == 2 );

# test updating
$p->privilege_mask( XIMS::Privileges::MODIFY() );
$p->update();


ok( $p->privilege_mask() == XIMS::Privileges::MODIFY() );
ok( $p->grantor_id() == 2 ); 
ok( $p->grantee_id() == 1 );
ok( $p->content_id() == 2 );

# now put it back and check
$p->privilege_mask( 1 );
$p->update();

$p = undef;

$p = XIMS::ObjectPriv->new( grantee_id => 1, content_id => 2 );

ok( $p->privilege_mask() == 1 );
ok( $p->grantor_id() == 2 ); 
ok( $p->grantee_id() == 1 );
ok( $p->content_id() == 2 );


# now create a new one

$p = undef;

my %newhash = ( grantor_id   => 2,
                grantee_id   => 1,
                content_id   => 1,
                privilege_mask => 0x43012F17
              );

$p = XIMS::ObjectPriv->new->data( %newhash );
$p->create();

# select it back
$p = undef;
$p = XIMS::ObjectPriv->new(  grantee_id => 1, content_id => 1 );

ok( $p );
ok( $p->privilege_mask() == XIMS::Privileges::MODIFY() );

# now, delete;
$p->delete();

$p = undef;
$p = XIMS::ObjectPriv->new(  grantee_id => 1, content_id => 1 );
ok( $p == undef );
