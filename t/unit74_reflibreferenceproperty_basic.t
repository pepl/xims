use Test::More tests => 11;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::RefLibReferenceProperty' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $refproperty = XIMS::RefLibReferenceProperty->new();

isa_ok( $refproperty, 'XIMS::RefLibReferenceProperty' );

$refproperty->name( 'TestRefPropertyName' );
$refproperty->description( 'TestRefPropertyDescription' );

my $id = $refproperty->create();
cmp_ok( $id, '>', 0, "refproperty created with id $id" );

# fetch it back...
$refproperty = undef;
$refproperty = XIMS::RefLibReferenceProperty->new( id => $id );

ok( $refproperty );
is( $refproperty->name(), 'TestRefPropertyName', 'TestRefProperty has correct name' );
is( $refproperty->description(), 'TestRefPropertyDescription' , 'TestRefProperty has correct description' );

# now, change something
$refproperty->name( 'RenamedTestRefPropertyName' );
ok( $refproperty->update(), 'Updated TestRefPropertyName' );

# fetch it back...
$refproperty = undef;
$refproperty = XIMS::RefLibReferenceProperty->new( id => $id );

ok( $refproperty );
is( $refproperty->name(), 'RenamedTestRefPropertyName' , 'TestRefProperty has correct name' );

ok( $refproperty->delete(), 'Successfully deleted TestRefProperty' );

# try to fetch it back
$refproperty = undef;
$refproperty = XIMS::RefLibReferenceProperty->new( id => $id );
is( $refproperty, undef, 'Unable to fetch deleted TestRefProperty (OK)' );

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

