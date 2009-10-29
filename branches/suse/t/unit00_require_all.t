use Test::More qw(no_plan);
use lib "../lib";
use strict;
use File::Find;

BEGIN{
    use_ok('XIMS');
}

my @files;

sub wanted {
    push @files, $File::Find::name if /\.pm$/;
}

find( \&wanted, '../lib');

foreach my $file (@files) {
  SKIP: {
        if ( $file =~ /Auth\/IMAP.pm$/) {
            eval {require IMAP::Admin;};
            skip "IMAP::Admin not installed." if $@;
        }

        if ( $file =~ /Auth\/LDAP.pm$/) {
            eval {require Net::LDAP;};
            skip "Net::LDAP not installed." if $@;
        }
        require_ok($file);
    }
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

