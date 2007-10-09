use Test::More tests => 10;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::User;
use XIMS::DataProvider;
#use Data::Dumper;

BEGIN { 
    use_ok('XIMS::Object')
}

my $admin = XIMS::User->new( id => 2 );
my $guest = XIMS::User->new( id => 1 );

isa_ok( $admin, 'XIMS::User' );
isa_ok( $guest, 'XIMS::User' );

my $o = XIMS::Object->new( id => 2 );

isa_ok( $o, 'XIMS::Object' ); 

# save the old priv so we can reset
my $old_mask = $guest->object_privmask( $o );
ok( $old_mask, 'object_privmask');

# grant
my $new_mask = XIMS::Privileges::WRITE();
my $ret = $o->grant_user_privileges( grantee => $guest, grantor => $admin, privmask => $new_mask );
is( $ret, 1, 'setting new privmask');
#check it from the db...
my $privs = XIMS::DataProvider->new->getObjectPriv( content_id => $o->id(), grantee_id => $guest->id() );
ok( $privs, 'privs set in db' );

# check for the bad caching bug...
ok( $guest->object_privmask( $o ) & $new_mask, 'testing for caching bug' );

$ret = undef;
$ret = $o->grant_user_privileges( grantee => $guest, grantor => $admin, privmask => $old_mask );
is( $ret, 1, 'setting back to old privmask');
ok( $guest->object_privmask( $o ) & $old_mask, 'privmask set correctly');

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

