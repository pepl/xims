use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use vars qw( @types @errors);

BEGIN { 
    plan tests => 2;
    @types = XIMS::Test::object_type_names();

    foreach my $ot ( @types ) {
        my $class = 'XIMS::' . $ot;
        eval "use $class"
    }
}

my $t = XIMS::Test->new();

ok( scalar( @types ) > 0 );

my $i = 0;
foreach my $ot ( @types ) {
    my $class = 'XIMS::' . $ot;
    my $object = $class->new();
    $i++;
}

ok( $i == ( scalar( @types ) ) );
