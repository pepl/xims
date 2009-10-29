use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::DataProvider;
use XIMS::Object;

BEGIN {
    plan tests => 12;
}

my $dp = XIMS::DataProvider->new();

ok( $dp );

my @data = $dp->getObject( id => 2, properties => ['title', 'id'] );
my $odata = $data[0];
ok( $odata );
ok( scalar( keys( %{$odata} ) ) == 2 );
ok( $odata->{'content.title'} eq '/ximspubroot/xims' );
ok( $odata->{'content.id'} == 2 );

# now lets do the same via the Object interface
my $o = XIMS::Object->new( id => 2, properties => ['title', 'id'] );

ok( $o );
ok( $o->title() eq '/ximspubroot/xims' );
ok( $o->id() == 2 );
ok( not defined $o->location() );

# just for fun, lets try another resource type

my $ldata = $dp->getLanguage( id => 1, properties => ['fullname'] );
ok( $ldata );
ok( scalar( keys( %{$ldata} ) ) == 1 );
ok( $ldata->{'language.fullname'} eq 'English (US)' );


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

