use Test;
use strict;
use lib "../lib", "lib";
use XIMS;
use XIMS::Test;
use XIMS::Object;
use XIMS::User;
use XIMS::Session;
use XIMS::AppContext;
use XIMS::CGI;

BEGIN { 
    plan tests => 9;
}

# set up a dummy context
my $u = XIMS::User->new( id => 1 );
my $o = XIMS::Object->new( id => 2, User => $u );
my $s = XIMS::Session->new( user_id => $u->id(), auth_module => 'Fake' );

ok( $o );
ok( $u );
ok( $s );

my $ctxt = XIMS::AppContext->new( user => $u,
                                  session => $s,
                                  object => $o,
                                );


ok( $ctxt );

my $q = XIMS::CGI->new({}); # empty $env

ok( $q );

my $ret = undef;
$ctxt = undef;
$ctxt = XIMS::AppContext->new( user => $u,
                               session => $s,
                               object => $o,
                                );
# sendError
$q->sendError( $ctxt, 'Whoopsie!' );

ok( $ctxt->session->error_msg() eq 'Whoopsie!' );
ok( $ctxt->properties->application->style() eq 'error');

# selectStyleSheet
$ret = undef;
$ctxt = undef;
$ctxt = XIMS::AppContext->new( user => $u,
                               session => $s,
                               object => $o,
                                );


# we should test every case but... :-/ 
$ctxt->session->skin( 'default' );
$ctxt->session->uilanguage( 'de-at' );
$ret = $q->selectStylesheet( $ctxt );

#warn "select is $ret \n";
ok( $ret eq XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/siteroot_default.xsl' );

$ret = undef;

# DOM getting
$ret = $q->getDOM( $ctxt );
ok( $ret->isa('XML::LibXML::Document') );

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

