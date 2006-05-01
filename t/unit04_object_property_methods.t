use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;

use vars qw( @types @errors);

BEGIN { 
    plan tests => 3;
    @types = XIMS::Test::object_type_names();

    foreach my $ot ( @types ) {
        my $class = 'XIMS::' . $ot;
        eval "use $class"
    }
}

my $t = XIMS::Test->new();

ok( scalar( @types ) > 0 );

my $i = 0;
my @props = @XIMS::Object::Fields;

ok( scalar( @props ) > 0 );
 
foreach my $ot ( @types ) {
    my $class = 'XIMS::' . $ot;
    my $object = $class->new();
    foreach my $property ( @props ) {
        next unless $object->can( $property );
        $i++;
    }
}
my $count = ( scalar(@types) * scalar( @props ) );
ok( $i == $count && $count > 0);
