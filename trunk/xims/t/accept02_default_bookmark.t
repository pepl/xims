use Test;
BEGIN { plan tests => 3 }
use lib "../lib";
use lib "lib";
use strict;
use XIMS::Test;

my $t = XIMS::Test->new();
my $res = $t->login();
ok( $res );
ok( defined( $t->{Cookie} ) );
ok( $res->message() eq 'OK' );

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

