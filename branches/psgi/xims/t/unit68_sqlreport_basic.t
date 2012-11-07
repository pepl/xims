use Test::More tests => 4;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::SQLReport' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $o = XIMS::SQLReport->new();
isa_ok( $o, 'XIMS::SQLReport' );

my $ot = XIMS::ObjectType->new( id => $o->object_type_id() );
my $df = XIMS::DataFormat->new( id => $o->data_format_id() );

is( $ot->name(), 'SQLReport', 'Object has correct object type' );
is( $df->name(), 'HTML', 'Object has correct data format' );





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

