use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::DataProvider;

BEGIN {
    plan tests => 27;
}

my $dp;
eval {
    $dp = XIMS::DataProvider->new();
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $dp );

# test the AUTOLOAD stuff

# first, the basic object types.
my $return;

eval {
    $return = $dp->getSession();
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
$return = undef;

eval {
     $return = $dp->getUser( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getDocument( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObject( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectType( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getContent( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getUserPriv( grantor_id => 2 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return );
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
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getLanguage( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getObjectPriv( grantor_id => 2 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return );
$return = undef;

eval {
     $return = $dp->getObjectTypePriv( object_type_id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return and scalar ($return) > 0 );
$return = undef;

eval {
     $return = $dp->getMimeType( id => 1 );
};
unless ( $@ ) {
    ok( 1 );
} else {
    ok(0,1);
}
ok( $return );
$return = undef;


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

