use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::User;
use Authen::Passphrase::BlowfishCrypt;

#use Data::Dumper;

BEGIN {
    plan tests => 8;
}

##
# Test password validation and transition from MD5 to Bcryt hashes.
#
# The setup scripts import the default users with unsalted MD5 password hashes
# (The default passwords are no secret anyway and way we can test the behavior
# with old and new hashes, as they are updated.)
##

# X-G-U und dran bist du:
my $xgu = XIMS::User->new( name => 'xgu' );
my $xgu_passwd = 'xgu';
my $xgu_md5hash = '43a008171c3de746fde9c6e724ee1001';

my $admin = XIMS::User->new( name => 'admin' );
my $admin_passwd = '_adm1nXP';
my $admin_md5hash = 'f6d399e7dc811d185234a5d45f2b3caa';

SKIP: {
    skip "Well done, user 'xgu' had his password changed!", 4  unless (defined $xgu
                                                                           and $xgu->password() eq $xgu_md5hash
                                                                           and $xgu->enabled() == 1);

    ok( $xgu->validate_password($xgu_passwd)); # validate /w md5 hash.

    my $ppr = Authen::Passphrase::BlowfishCrypt->new( cost => 12,
                                                      salt_random => 1,
                                                      passphrase => $xgu_passwd );


    ok( $xgu->password( $ppr->as_crypt() ) );
    ok( $xgu->update() );
    ok( $xgu->validate_password($xgu_passwd));
}

SKIP: {
    skip "Well done, user 'admin' had his password changed!", 4  unless (defined $admin
                                                                             and $admin->password() eq $admin_md5hash
                                                                             and $admin->enabled() == 1);

    ok( $admin->validate_password($admin_passwd)); # validate /w md5 hash.

    my $ppr = Authen::Passphrase::BlowfishCrypt->new( cost => 12,
                                                      salt_random => 1,
                                                      passphrase => $admin_passwd );


    ok( $admin->password( $ppr->as_crypt() ) );
    ok( $admin->update() );
    ok( $admin->validate_password($admin_passwd));
}


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

