use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::DataProvider;

BEGIN {
    plan tests => 26;
}

my $dp = XIMS::DataProvider->new();

ok( $dp );

# test the AUTOLOAD stuff

# first, the basic object types.
my $return;

eval {
    $return = $dp->getSession();
};
unless ( $@ ) { ok( 1 ); }
$return = undef;

eval {
     $return = $dp->getUser( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getDocument( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObject( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectType( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getContent( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getUserPriv( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getBookmark( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;


eval {
     $return = $dp->getDataFormat( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getLanguage( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectPriv( content_id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectTypePriv( object_type_id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getMimeType( id => 1 );
};
unless ( $@ ) { ok( 1 ); }
ok( $return );
$return = undef;

