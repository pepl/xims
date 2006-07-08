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
#use Data::Dumper;
use Apache::FakeRequest;

BEGIN { 
    plan tests => 10;
}

# set up a dummy context

my $u = XIMS::User->new( id => 1 );
my $o = XIMS::Object->new( id => 2, User => $u );
my $s = XIMS::Session->new( user_id => $u->id() );
my $a = Apache::FakeRequest->new();
ok( $o );
ok( $u );
ok( $s );
ok( $a );
my $ctxt = XIMS::AppContext->new( user => $u,
                                  session => $s,
                                  object => $o,
                                  apache => $a
                                );


ok( $ctxt );

my $q = XIMS::CGI->new();

ok( $q );

my $ret = undef;
$ctxt = undef;
$ctxt = XIMS::AppContext->new( user => $u,
                               session => $s,
                               object => $o,
                               apache => $a
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
                               apache => $a
                                );


# we should test every case but... :-/ 
$ctxt->session->skin( 'default' );
$ret = $q->selectStylesheet( $ctxt );
#warn "select is $ret \n";
ok( $ret eq XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/siteroot_default.xsl' );

$ret = undef;

# DOM getting
$ret = $q->getDOM( $ctxt );
ok( $ret->isa('XML::LibXML::Document') );
