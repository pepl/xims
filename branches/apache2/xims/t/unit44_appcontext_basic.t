use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::Object;
use XIMS::User;
use XIMS::Session;
use XIMS::AppContext;
#use Data::Dumper;

BEGIN { 
    plan tests => 17;
}

my $ctxt = XIMS::AppContext->new();

ok( $ctxt );

# now test the sub objects...

# data provider
# note to pepl: no need for the 'provider'
# field on the Context object. as a subclass
# of XIMS::AbstractClass it already implements
# the data_provider method.

my $dp = $ctxt->data_provider();

ok( $dp );
ok( $dp->isa('XIMS::DataProvider') );

# object
my $o = XIMS::Object->new( id => 2 );
ok( $o );
$ctxt->object( $o );
ok( $ctxt->object->isa('XIMS::Object') );
ok( $ctxt->object->id() == 2 );

# user
my $u = XIMS::User->new( id => 1 );
ok( $u );
$ctxt->user( $u );
ok( $ctxt->user->isa('XIMS::User') );
ok( $ctxt->user->name eq 'xgu' );


# session
my $s = XIMS::Session->new();
ok( $s );
$ctxt->session( $s );
ok( $ctxt->session->isa('XIMS::Session') );

# now try loading it all up at when instantiating
$ctxt = undef;

$ctxt = XIMS::AppContext->new( user => $u,
                               session => $s,
                               object => $o
                             );


ok( $ctxt->data_provider->isa('XIMS::DataProvider') );
ok( $ctxt->object->isa('XIMS::Object') );
ok( $ctxt->object->id() == 2 );
ok( $ctxt->user->isa('XIMS::User') );
ok( $ctxt->user->name eq 'xgu' );
ok( $ctxt->session->isa('XIMS::Session') );


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

