use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::Names;
use XIMS::ObjectPriv;
#use Data::Dumper;

BEGIN {
    plan tests => 43;
}

my $p = XIMS::ObjectPriv->new();
my $modify = (XIMS::Privileges::VIEW | XIMS::Privileges::WRITE | XIMS::Privileges::DELETE | XIMS::Privileges::ATTRIBUTES | XIMS::Privileges::TRANSLATE | XIMS::Privileges::CREATE | XIMS::Privileges::MOVE | XIMS::Privileges::COPY | XIMS::Privileges::LINK | XIMS::Privileges::ATTRIBUTES_ALL | XIMS::Privileges::DELETE_ALL | XIMS::Privileges::GRANT | XIMS::Privileges::GRANT_ALL | XIMS::Privileges::OWNER);

ok( $p );

no strict 'refs';
foreach my $privname (XIMS::Privileges::list()) {
    if ( $privname eq 'PUBLISH' 
      or $privname eq 'PUBLISH_ALL' 
      or $privname eq 'DENIED' 
      or $privname eq 'MASTER'
      or $privname eq 'SEND_AS_MAIL') {
        ok( (&{"XIMS::Privileges::$privname"} & XIMS::Privileges::MODIFY()) == 0 );
    }
    else {
        ok( (&{"XIMS::Privileges::$privname"} & XIMS::Privileges::MODIFY()) == &{"XIMS::Privileges::$privname"} );
    }
}

$p->privilege_mask( $modify );
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
             privilege_mask => $modify
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
                privilege_mask => $modify
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

