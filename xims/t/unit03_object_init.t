use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use vars qw( @types @errors);

BEGIN { 
    plan tests => 2;
    @types = XIMS::Test::object_type_names();

    foreach my $ot ( @types ) {
        my $class = 'XIMS::' . $ot;
        eval "use $class"
    }
}

my $t = XIMS::Test->new();

ok( scalar( @types ) > 0 );

my $i = 0;
foreach my $ot ( @types ) {
    my $class = 'XIMS::' . $ot;
    my $object = $class->new();
    $i++;
}

ok( $i == ( scalar( @types ) ) );

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

