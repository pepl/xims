use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::AxPointPresentation;
#use Data::Dumper;

BEGIN { 
    plan tests => 6;
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $o = XIMS::AxPointPresentation->new();

ok( $o );
ok( $o->isa('XIMS::AxPointPresentation') );

my $ot = XIMS::ObjectType->new( id => $o->object_type_id() );
my $df = XIMS::DataFormat->new( id => $o->data_format_id() );

ok( $ot );
ok( $df );
ok( $ot->name() eq 'AxPointPresentation' );
ok( $df->name() eq 'AXPML' );


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

