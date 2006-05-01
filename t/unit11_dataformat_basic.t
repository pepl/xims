use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::DataFormat;
#use Data::Dumper;

BEGIN {
    plan tests => 34;
}

my $df = XIMS::DataFormat->new();

ok( $df );
$df->mime_type( 'application/ubu' );
$df->id( 1 );
$df->name( 'UbuApp' );
$df->suffix( 'ubu' );

ok( $df->mime_type() eq 'application/ubu' );
ok( $df->id() == 1 );
ok( $df->name() eq 'UbuApp' );
ok( $df->suffix() eq 'ubu' );

# try the more Perlish short cut
$df = undef;

my %hash = ( id   => 1,
             mime_type => 'application/ubu',
             name => 'UbuApp',
             suffix => 'ubu',
           );

$df = XIMS::DataFormat->new->data( %hash );

ok( $df->mime_type() eq 'application/ubu' );
ok( $df->id() == 1 );
ok( $df->name() eq 'UbuApp' );
ok( $df->suffix() eq 'ubu' );

# now create one
$df = undef;
$df = XIMS::DataFormat->new();

ok( $df );
$df->mime_type( 'application/ubu' );
$df->name( 'UbuApp' );
$df->suffix( 'ubu' );

my $id = $df->create();

ok( $id and $id > 0 );

# now select it back out of the DB.

$df = undef;
$df = XIMS::DataFormat->new( id => $id );

ok( $df );
ok( $df->mime_type() eq 'application/ubu' );
ok( $df->id() == $id );
ok( $df->name() eq 'UbuApp' );
ok( $df->suffix() eq 'ubu' );

# now modify a field and test updating

$df->suffix( 'fez' );

ok( $df->update() );

$df = undef;
$df = XIMS::DataFormat->new( id => $id );

ok( $df );
ok( $df->mime_type() eq 'application/ubu' );
ok( $df->id() == $id );
ok( $df->name() eq 'UbuApp' );
ok( $df->suffix() eq 'fez' );

# now delete

ok( $df->delete() );

# and make sure

$df = undef;
$df = XIMS::DataFormat->new( id => $id );
ok( not defined $df );

# now try getting an existing one by name instead of ID
$df = undef;
$df = XIMS::DataFormat->new( name => 'DOC' );

ok( $df );
ok( $df->mime_type() eq 'application/vnd.ms-word' );
ok( $df->id() == 11 );
ok( $df->name() eq 'DOC' );
ok( $df->suffix() eq 'doc' );

# now, do the same, but force a mime_type alias lookup
$df = undef;
$df = XIMS::DataFormat->new( mime_type => 'application/msword' );

ok( $df );
ok( $df->mime_type() eq 'application/vnd.ms-word' );
ok( $df->id() == 11 );
ok( $df->name() eq 'DOC' );
ok( $df->suffix() eq 'doc' );

