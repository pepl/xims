use Test::More tests => 10;
use lib "../lib";
use strict;
use XIMS;

BEGIN { use_ok( 'XIMS::Names' ); }

my @r_types = XIMS::Names::resource_types();
my @config_r_types = XIMS::Config::Names::ResourceTypes();
is_deeply( \@config_r_types, \@r_types , 'resource_types' );

my %props_hash = XIMS::Names::property_list();
is_deeply( \%XIMS::Names::Properties, \%props_hash, 'property_list' );

cmp_ok( scalar( XIMS::Names::property_list('Session') ), '>', 0, 'property_list');
is( scalar( XIMS::Names::property_list('Foo') ), undef, 'property_list' );

is( scalar( keys(%props_hash) ), scalar( @r_types ), 'keys of props_hash are r_types' );

is( XIMS::Names::valid_property('User', 'user.id' ), 1, 'valid_property');
isnt( XIMS::Names::valid_property('Foo'), 1, 'valid_property' );

cmp_ok( scalar( XIMS::Names::property_interface_names('Session') ), '>', 0, 'property_interface_names');

diag("an ErrorMSG expected from the next one");
is( XIMS::Names::get_URI('Foo', 'Bar'), 'foo.Bar' , 'getURI' );

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

