use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::File;
#use Data::Dumper;

BEGIN { 
    plan tests => 6;
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $o = XIMS::File->new();

ok( $o );
ok( $o->isa('XIMS::File') );

my $ot = XIMS::ObjectType->new( id => $o->object_type_id() );
my $df = XIMS::DataFormat->new( id => $o->data_format_id() );

ok( $ot );
ok( $df );
ok( $ot->name() eq 'File' );
ok( $df->name() eq 'Binary' );
