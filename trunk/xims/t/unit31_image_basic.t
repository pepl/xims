use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Image;
use Data::Dumper;

BEGIN { 
    plan tests => 4;
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $o = XIMS::Image->new();

ok( $o );
ok( $o->isa('XIMS::Image') );

my $ot = XIMS::ObjectType->new( id => $o->object_type_id() );

ok( $ot );
ok( $ot->name() eq 'Image' );    


