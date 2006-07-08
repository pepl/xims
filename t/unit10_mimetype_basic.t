use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::MimeType;
#use Data::Dumper;

BEGIN {
    plan tests => 13;
}

my $mt = XIMS::MimeType->new();

ok( $mt );
$mt->mime_type( 'application/ubu' );
$mt->data_format_id( 1 );

ok( $mt->mime_type() eq 'application/ubu' );
ok( $mt->data_format_id() == 1 );

# try the more Perlish short cut
$mt = undef;

my %hash = ( data_format_id   => 1,
             mime_type => 'application/ubu',
           );

$mt = XIMS::MimeType->new->data( %hash );

ok( $mt->mime_type() eq 'application/ubu' );
ok( $mt->data_format_id() == 1 );

# now create one
$mt = undef;
$mt = XIMS::MimeType->new();

ok( $mt );
$mt->mime_type( 'application/ubu' );
$mt->data_format_id( 1 );

my $id = $mt->create();

ok( $id and $id > 0 );

# now select it back out of the DB.

$mt = undef;
$mt = XIMS::MimeType->new( mime_type => 'application/ubu' );

ok( $mt );
ok( $mt->mime_type() eq 'application/ubu' );
ok( $mt->data_format_id() == 1 );
ok( $mt->id() == $id );


# now delete.
ok( $mt->delete() );

# and make sure
$mt = undef;
$mt = XIMS::MimeType->new( mime_type => 'application/ubu' );
ok( not defined $mt );
