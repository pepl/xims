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
     $return = $dp->getUser();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getDocument();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObject();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectType();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getContent();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getUserPriv();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getBookmark();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;


eval {
     $return = $dp->getDataFormat();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getLanguage();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectPriv();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectTypePriv();
};
unless ( $@ ) { ok( 1 ); }
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getMimeType();
};
unless ( $@ ) { ok( 1 ); }
ok( $return );
$return = undef;

