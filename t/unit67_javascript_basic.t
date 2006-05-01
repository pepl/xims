use Test::More tests => 4;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::JavaScript' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $o = XIMS::JavaScript->new();
isa_ok( $o, 'XIMS::JavaScript' );

my $ot = XIMS::ObjectType->new( id => $o->object_type_id() );
my $df = XIMS::DataFormat->new( id => $o->data_format_id() );

is( $ot->name(), 'JavaScript', 'Object has correct object type' );
is( $df->name(), 'ECMA', 'Object has correct data format' );




