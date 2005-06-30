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

my $odata = $dp->getObject( id => 2, properties => ['title', 'id'] );

ok( $odata );
ok( scalar( keys( %{$odata} ) ) == 2 );
ok( $odata->{'content.title'} eq 'xims' );
ok( $odata->{'content.id'} == 2 );

# now lets do the same via the Object interface
my $o = XIMS::Object->new( id => 2, properties => ['title', 'id'] );

ok( $o );
ok( $o->title() eq 'xims' );
ok( $o->id() == 2 );
ok( $o->location() == undef );

# just for fun, lets try another resource type

my $ldata = $dp->getLanguage( id => 1, properties => ['fullname'] );
ok( $ldata );
ok( scalar( keys( %{$ldata} ) ) == 1 );
ok( $ldata->{'language.fullname'} eq 'English (US)' );

