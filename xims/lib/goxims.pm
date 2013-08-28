=head1 NAME

godav -- XIMS' handler for WebDAV.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use godav;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package goxims;

use common::sense;

use Locale::Messages qw(bind_textdomain_filter bind_textdomain_codeset turn_utf_8_on);
use Locale::TextDomain ('info.xims');
use POSIX qw(setlocale LC_ALL LC_TIME);
use Time::Piece;
use XML::LibXSLT ();
use DBI;
use Encode qw(encode);

use Plack::Request;

use HTTP::Throwable::Factory qw(http_throw http_exception);

use XIMS;
use XIMS::AppContext;
use XIMS::DataProvider;
use XIMS::Object;
use XIMS::SiteRoot;
use XIMS::Document;
use XIMS::Image;
use XIMS::Importer;
use XIMS::Exporter;
use XIMS::User;
use XIMS::Session;

# preload commonly used and publish_gopublic objecttypes
use XIMS::CGI::SiteRoot;
use XIMS::CGI::DepartmentRoot;
use XIMS::CGI::Document;
use XIMS::CGI::Image;
use XIMS::CGI::Portlet;
use XIMS::CGI::Questionnaire;



BEGIN {
    # gettext encoding
    bind_textdomain_filter( 'info.xims', \&turn_utf_8_on );
    bind_textdomain_codeset( 'info.xims', 'utf-8' );

    XML::LibXSLT->max_depth(500);
}


# the main app
sub handler {
    my $env = shift;
    my ($res, $interface_type);
    my $ctxt = $env->{'xims.appcontext'}; # shortcut
    my $req = Plack::Request->new($env);

    XIMS::Debug( 5, "'" . $req->script_name() . "' called from " . $req->address() );

    http_throw('NotFound') unless $interface_type = get_interface($req);

    # set some session information
    my $tp = localtime;
    $ctxt->session->date( $tp->ymd() . ' ' . $tp->hms() );

    if( $ctxt->session->user->userprefs ){
    	$ctxt->session->skin( $ctxt->session->user->userprefs->skin() );
    }
    else{
    	$ctxt->session->skin( XIMS::DEFAULT_SKIN() );
    }

    my $app_class    = 'XIMS::CGI::';

    # 'content' interface
    if ( "/$interface_type" eq XIMS::CONTENTINTERFACE() ) {
        #  we have to get the content-object
        $ctxt->object( get_object( $req ) );

        http_throw('NotFound') unless $ctxt->object( get_object($req) ) and $ctxt->object->id();

        my $ot_fullname = $ctxt->object->object_type->fullname();

        rebless_object( "XIMS::$ot_fullname", $env );

        # if a 'objtype'-parameter is set, we are here to create a new object
        my $objtype = $req->param('objtype');

        my $prefix;
        if ( defined $objtype and length $objtype ) {
            XIMS::Debug( 6, "creating a new $objtype" );
            $app_class .= $objtype;
            $prefix = lc $objtype;
        }
        else {
            $app_class .= $ot_fullname;
            $prefix = lc $ot_fullname;
        }
        $prefix =~ s/::/_/g;
        $ctxt->properties->application->styleprefix($prefix);
    }
    # end 'content' case
    #
    # every other interface
    else {
        $app_class .= $interface_type;
        $ctxt->properties->application->styleprefix($interface_type);
    }
    # end interface-lookup

    # run app and return
    if ( $res = run_app($app_class, $env) ) {
        push $res->[1], ('Cache-Control', 'private, must-revalidate',
                         'X-UA-Compatible', 'IE=Edge');
        return $res;
    }

    # something did not work out...
    http_throw(
        'InternalServerError' => {
            message => __("You shouldn't have ended here, sorry!") }
    );
};



# for quick retrieval, see below
sub quick_handler {
    my $env = shift;
    my ($res,$prefix);
    my $ot_fullname = $env->{'xims.appcontext'}->object->object_type->fullname();

    XIMS::Debug( 5, "'" .  $env->{SCRIPT_NAME} . "' called from " . $env->{REMOTE_ADDR} );

    #  object class
    rebless_object( "XIMS::$ot_fullname", $env );

    # App Class
    $prefix = lc $ot_fullname;
    $prefix =~ s/::/_/g;
    $env->{'xims.appcontext'}->properties->application->styleprefix($prefix);

    if ( $res = run_app("XIMS::CGI::$ot_fullname", $env) ) {
        # add some headers
        push $res->[1],      (
            'Last-Modified', $env->{'xims.appcontext'}->{mtime},
            'Cache-Control', 'public, s-maxage=300' # 5 Min
        );

        return $res;
    }

    # something did not work out...
    http_throw(
        'InternalServerError' => {
            message => __("You shouldn't have ended here, sorry!") }
    );

};


# TODO: i18n. 
sub login_screen {
    my $env = shift;
    #my ($env, $reason) = @_;
    my $req = Plack::Request->new($env);  
    my %messages = (mismatch => '<div class="message"><span>Login failed.<br/>Try again with your correct username and password.</span></div>',
                    logout => '<div class="message"><span>Logout successful.<br/>To log in again, enter your username and password.</span></div>');
    my $message = $messages{ $req->param('reason') };
    my $action = $req->param('r');
    my $goxims = XIMS::GOXIMS();
    if ($action =~ /^$goxims/) {
        $action =~ s!(^/[a-z]+(?:/[-_a-z0-9]+(?:\.[a-z0-9]+){0,2})*/?)?.*!$1!i;
    }
    else {
        $action = XIMS::GOXIMS();
    }

    # my $motd = q();
    my $motd = <<MOTD;
<div class="warning">
    <p>I am the optional message of the day. (Lorem ipsum, baby!)</p>
</div>
MOTD

    my $body = <<FORM;
<!DOCTYPE html>
<html>
  <head>
    <title>XIMS - Login</title>
    <link rel="stylesheet" media="screen" type="text/css" href="/ximspubroot/stylesheets/login.css"/>
  </head>
  <body onload="document.forms['login'].userid.focus()">
    <div id="main">
      <div id="header">
        <h1 class="university">My Organization
                <br/><span class="infotext">XIMS</span></h1>
        <div id="emotionimage">
          <a title="XIMS" href="http://xims.info">
            <img alt="XIMS Logo" title="XIMS" src="/ximspubroot/images/xims_logo_44x44.jpg"/>
          </a>
        </div>
      </div>
      $motd
      <form method="post" name="login" action="$action" id="login">
        <h2>
          <span class="infotext">XIMS LOGIN</span>
        </h2>
        $message
        <div>
          <label for="userid">Username: </label>
          <input tabindex="1" type="text" name="userid" id="userid" class="text" value=""/>
        </div>
        <div>
          <label for="password">Password: </label>
          <input tabindex="2" type="password" name="password" class="text"/>
        </div>
        <div class="submit">
          <input type="hidden" name="dologin" value="1" />
          <input tabindex="3" type="submit" name="login" value="Login" class="control"/>
        </div>
      </form>
    </div>
  </body>
</html>
FORM

return [ 200,
         [ 'Content-Type' => 'text/html;charset=UTF-8',
           'Set-Cookie' => 'session=; path=/; expires=-1Y', ],
         [ encode('UTF-8', $body) ]
     ];
};

sub get_interface {
    my $req = shift;

    my $script_name = $req->script_name();
    $script_name =~ s!.*/([^/]+)$!$1!;

    return $script_name;
}

=head2    getObject($req)

=head3 Parameter

    $req:    Plack::Request object      (mandatory)

=head3 Returns

    $retval: a XIMS::Object

=head3 Description

Watch out: language is hardcoded to de-at here!

=cut

sub get_object {
    my $req  = shift;
    my $user = $req->env->{'xims.appcontext'}->session->user();
    my %args;

    if ( $req and $user ) {
        my $pathinfo = $req->path();

        my $id = $req->param('id');
        if ( defined $id and $id > 0 ) {
            $args{id} = $id;
        }
        else {
            $args{path} = $pathinfo;
        }
        return XIMS::Object->new( %args, User => $user, language => 2);
    }

    return undef;
}

sub rebless_object {
    my ($object_class, $env) = @_;

    ## no critic (ProhibitStringyEval)
    # load the object class
    eval "require $object_class;";

    if ($@) {
        XIMS::Debug( 2, "could not load object class $object_class: $@" );
        http_throw(
            'InternalServerError' => {
                message => __x(
                    "Could not load object class {classname}.",
                    classname => $object_class,
                )
            }
        );
    }

    ## use critic
    # rebless the object
    XIMS::Debug( 4, "reblessing object to " . $object_class );
    return bless $env->{'xims.appcontext'}->object(), $object_class;
}

sub run_app {
    my ( $app_class, $env ) = @_;
    my $app;

    eval "require $app_class";

    if ($@) {
        XIMS::Debug( 2, "could not load application-class $app_class: $@" );
        http_throw(
            'InternalServerError' => {
                message => __x(
                    "Could not load object class {classname}.",
                    classname => $app_class,
                )
            }
        );
    }

    if ($app = $app_class->new($env)) {
        XIMS::Debug( 4, "application-class $app_class initiated." );
        $app->setStylesheetDir( XIMS::XIMSROOT()
                . '/skins/'
                . $env->{'xims.appcontext'}->session->skin
                . '/stylesheets/'
                . $env->{'xims.appcontext'}->session->uilanguage() );

        return $app->run( $env->{'xims.appcontext'} );
    }

    return;
}

1;



__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

=head1 BUGS AND LIMITATION

This module has beta status. All Litmus tests besides some of the props tests
do pass.

This DAV handler has been tested with cadaver, konqueror, Webdrive, Novell's
Netdrive DAV client software and MS WebFolders

Body-less or dynamic object types like URLLink or Questionnaire are filtered
out.

It is not possible to rename/move or delete published objects.

Under Windows: Do not create objects with Explorer using the right mouse
button. "New Text Document.txt" will be created as "new_text_document.txt" and
not found again right away...

http://host/godav/xims/

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 TODO

=over

=item *

Add acceptance tests (HTTP::DAV)

=item *

Add documentation with nice screenshots

=item *

PROPPATCH?

=back

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

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

