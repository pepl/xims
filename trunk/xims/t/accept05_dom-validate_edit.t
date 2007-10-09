use Test;
BEGIN { plan tests => 5 }
use lib "../lib";
use lib "lib";
use strict;
use XIMS::Test;

my $t = XIMS::Test->new();
my $res = $t->login();
ok( $res );
ok( defined( $t->{Cookie} ) );
$res = undef;
$res = $t->get('/content/xims?edit=1&passthru=1');
ok( $res );

my $xml;
# Check the outcome of the response
if ($res->is_success) {
    $xml = $res->content;
}
else {
   warn "request failed: " . $res->message . ".\n";
}
ok( length($xml) > 0 );

my $schema = 'schemata/basic.scm';
my @messages = $t->validate_xml( $xml, $schema );

ok( scalar( @messages ) == 0 );

if ( scalar( @messages ) > 0 ) {
    my $err = join "\n", @messages;
    warn "Validation errors:\n$err\n";
    #print $xml . "\n";
}

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

