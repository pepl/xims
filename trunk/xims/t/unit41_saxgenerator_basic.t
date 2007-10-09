use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::SAX::Generator::Content;
#use Data::Dumper;

BEGIN { 
    plan tests => 1;
}

my $o = XIMS::SAX::Generator::Content->new();

ok( $o );

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

