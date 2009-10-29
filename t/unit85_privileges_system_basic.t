## no critic
use Test::More;
use lib "../lib";
use XIMS::Privileges::System;

my %privs = %XIMS::Privileges::System::;
map { delete $privs{$_} } qw(BEGIN list import);

plan tests => keys(%privs) + 2;
can_ok( "XIMS::Privileges::System", XIMS::Privileges::System::list() );

foreach ( keys(%privs) ) {
    cmp_ok( 0, '<', &{"XIMS::Privileges::System::$_"}, $_ );
    delete $privs{$_};
}

is( keys(%privs), 0, "no privileges missing in list()" );

1;

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

