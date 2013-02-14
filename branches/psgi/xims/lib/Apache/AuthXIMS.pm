
=head1 NAME

Apache::AuthXIMS - XIMS mod_perl AccessHandler.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    PerlAccessHandler Apache::AuthXIMS

=head1 DESCRIPTION

This module is a mod-perl AccessHandler that initiates authentication and
session handling for XIMS. 

=head1 SUBROUTINES/METHODS

=cut

package Apache::AuthXIMS;
use common::sense;

use Apache;
use Apache::Request ();
use Apache::URI;
use Apache::Constants qw(:common);
use Apache::Cookie;
use URI::Escape;

use XIMS;
use XIMS::DataProvider;
use XIMS::Auth;
use XIMS::Session;
use XIMS::Object;
use XIMS::User;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 handler($r)

=head3 Parameters

    $r: request-object.

=head3 Returns

    DECLINED, OK or FORBIDDEN.

=cut

sub handler {
    my $r = shift;

    XIMS::via_proxy_test($r) unless $r->pnotes('PROXY_TEST');
    XIMS::Debug( 5, "called from " . $r->connection->remote_ip() );

    my $cache_control = $r->dir_config('ximsCacheControl');
    if ( defined $cache_control and $cache_control ) {
        $r->header_out( 'Cache-Control', $cache_control );

        # HTTP/1.0 only defines the Pragma: no-cache, anything
        # else is a implementation dependent extension which might
        # or might not be recognized.
        unless ( $r->protocol eq 'HTTP/1.1' or $cache_control =~ /public/ ) {
            $r->header_out( 'Pragma', 'no-cache' );
        }
    }
    else {
        $r->no_cache(1);
    }

    my $retval = DECLINED;
    my %args   = $r->args();

    my $dp        = XIMS::DATAPROVIDER();
    my $accessdoc = $r->dir_config('ximsAccessDocument');
    $accessdoc ||= XIMS::PUBROOT_URL()
        . '/access.xsp';    # default hardcoded fallback value

    unless ($dp) {
        my $url = XIMS::PUBROOT_URL()
            . "/500.xsp?reason=A%20database%20connection%20problem%20occured.";
        $r->custom_response( SERVER_ERROR, $url );
        return SERVER_ERROR;
    }

    XIMS::Debug( 4, "getting session cookie" );
    my $cSession = undef;
    my $session  = get_session_cookie($r);
    my $login    = 0;
    if ( length $session ) {
        XIMS::Debug( 6, "session cookie found: '$session'" );
        $cSession = test_session( $r, $dp, $session );
        if ( not $cSession ) {
            XIMS::Debug( 2, "invalid session: drop cookie!" );
            unset_session_cookie($r);
        }
        elsif ( test_for_logout( $r, $dp, $cSession ) ) {
            unset_session_cookie($r);
            $cSession = undef;
        }
    }
    else {
        XIMS::Debug( 3, "no session cookie found " );
        $cSession = login_user( $r, $dp );
        $login = 1;
    }

    if ($cSession) {
        #warn "session found" . Dumper( $cSession ) . "\n";
        my $browsepublished = $r->dir_config('ximsBrowsePublished');
        if ( not $login ) {
            XIMS::Debug( 4, "session confirmed: storing to pnotes" );
            set_user_info( $r, $dp, $cSession );
            return view_privilege_handler( $r, $cSession )
                if $browsepublished;
        }
        else {
            XIMS::Debug( 4, "session confirmed: storing cookie" );
            set_session_cookie( $r, $cSession->session_id() );
            if ($browsepublished) {
                my $rv = view_privilege_handler( $r, $cSession );
                return FORBIDDEN if $rv == FORBIDDEN;
                $r->status_line("302 Found");
                $r->header_out( Location => $r->uri );
                $r->send_http_header("text/html");
                return OK;
            }
            else {
                redirToDefault( $r, $dp, $cSession->user_id() );
            }
        }
        return OK;
    }
    else {
        XIMS::Debug( 3, "access denied for " . $r->connection->remote_ip() );
        my $url = $accessdoc;
        if ( $args{dologin} ) {
            $url
                .= "?reason=Access%20Denied.%20Please%20provide%20a%20valid%20username%20and%20password.";
        }
        else {
            my $askedpath  = $r->path_info();
            my $askedquery = Apache::URI->parse($r)->query();

            if ( not defined $args{reason} ) {
                XIMS::Debug( 6, "setting client cookie 'askedquery' to value '$askedquery'" );
                Apache::Cookie->new(
                    $r,
                    -name  => 'askedquery',
                    -value => uri_escape($askedquery),
                    -path  => '/'
                )->bake();
            }

            XIMS::Debug( 6, "setting client cookie 'askedpath' to value '$askedpath'" );
            Apache::Cookie->new(
                $r,
                -name  => 'askedpath',
                -value => $askedpath,
                -path  => '/'
            )->bake();
        }
        $r->custom_response( FORBIDDEN, $url );
        return FORBIDDEN;
    }
}

=head2 get_session_cookie($r)

=head3 Parameters

    $r: request-object.

=head3 Returns

Session handle if successful, empty string otherwise.

=cut

sub get_session_cookie {
    XIMS::Debug( 5, "called" );
    my $r = shift;

    my $cookiename = "session";    # should this get from the config
    my $session;

    my %cookies = Apache::Cookie->fetch();
    if ( $cookies{$cookiename} ) {
        $session = $cookies{$cookiename}->value();
        XIMS::Debug( 6,
            "found session '$session' in client cookie '$cookiename'" );
    }

    XIMS::Debug( 5, "done" );
    return $session || q{};
}

=head2 set_session_cookie($r, $session)

=head3 Parameters

    $r:       request-object,
    $session: session-object.

=head3 Returns

    1 if succsessful, 0 otherwise.

=head3 Description

Creates a cookie, redirects to old destination?

=cut

sub set_session_cookie {
    XIMS::Debug( 5, "called" );
    my $r       = shift;
    my $session = shift;

    my $retval = 0;

    if ( length $session ) {
        XIMS::Debug( 4, "session string found: $session" );
        my $cookiename = "session";    # should this get from the config

        XIMS::Debug( 6,
            "setting client cookie '$cookiename' to value '$session'" );

        # need expires? if it not set, the cookie gets lost after
        # browser shutdown
        Apache::Cookie->new(
            $r,
            -name  => $cookiename,
            -value => $session,
            -path  => '/'
        )->bake();
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "cannot set empty session key" );
    }

    XIMS::Debug( 5, "done" );
    return $retval;
}

=head2 unset_session_cookie($r)

=head3 Parameters

    $r: request-object.

=head3 Returns

    1.

=cut

sub unset_session_cookie {
    XIMS::Debug( 5, "called" );
    my $r          = shift;
    my $cookiename = "session";    # should this get from the config

    # XXX not needed anymore? no other references to 'ximsCookie' found!
    # $r->pnotes( "ximsCookie", "$cookiename= ; path=/" );

    XIMS::Debug( 6, "removing client cookie '$cookiename'" );
    Apache::Cookie->new(
        $r,
        -name    => $cookiename,
        -path    => '/',
        -expires => '-1Y',
    )->bake();

    XIMS::Debug( 5, "done" );
    return 1;
}

=head2 set_user_info($r,$dp,$session)

=head3 Parameters

    $r:       request-object,
    $dp:      dataprovider-object,
    $session: session-object,

=head3 Returns

nothing meaningful.

=cut

sub set_user_info {
    XIMS::Debug( 5, "called" );
    my $r       = shift;
    my $dp      = shift;
    my $session = shift;

    $r->pnotes( ximsSession  => $session );
    $r->pnotes( ximsProvider => $dp );

    return;
}

=head2 test_session()

=head3 Parameters

    $r:  request-object,
    $dp: dataprovider,
    $sessionstring: ???.

=head3 Returns

    $cSession.

=cut

sub test_session {
    XIMS::Debug( 5, "called" );

    # gets session string and returns related session class if any
    my $r             = shift;
    my $dp            = shift;
    my $sessionstring = shift;

    my $cSession = undef;

    eval { $cSession = XIMS::Session->new( session_id => $sessionstring ); };
    if ($@) {
        XIMS::Debug( 2, "no session found!" . $@ );
    }

    # TODO: Think of separately checking for session timeout and display a
    # corresponding message to the user in case
    if ( $cSession and $cSession->validate( $r->connection->remote_ip() ) ) {
        XIMS::Debug( 4, "session cookie validated!" );
    }
    else {
        XIMS::Debug( 2, "rejecting session cookie" );
        $cSession = undef;
    }

    return $cSession;    # return session class
}

=head2 create_session_id($r, $dp, $cUser)

=head3 Parameters

    $r:  request-object,
    $dp: dataprovider,
    $cUser: ???.

=head3 Returns

    $cSession.

=cut

sub create_session_id {
    XIMS::Debug( 5, "called" );
    my $r     = shift;
    my $dp    = shift;
    my $cUser = shift;

    # secret key from config?
    my $cSession = undef;

    if ( $dp and $r and $cUser ) {
        XIMS::Debug( 4, "completing dataset for cookie creation" );

        $cSession = XIMS::Session->new(
            'user_id'   => $cUser->id(),
            'user_name' => $cUser->name(),
            'host'      => $r->connection->remote_ip()
        );
        unless ($cSession) {
            XIMS::Debug( 2, "session cannot be created in system database" );
            $cSession = undef;
        }
    }
    else {
        XIMS::Debug( 3, "incomplete parameter list" );
    }

    XIMS::Debug( 5, "done" );
    return $cSession;
}

=head2 get_logindata($r)

=head3 Parameters

    $r: request-object.

=head3 Returns

    ( userid, password ).

=head3 Description

Read login data from request and return it as an array.

=cut

sub get_logindata {
    XIMS::Debug( 5, "called" );

    my $r = shift;
    my $apr = Apache::Request->new($r);

    return($apr->param('userid'), $apr->param('password'));
}

=head2 login_user($r, $dp)

=head3 Parameters

    $r:  request-object,
    $dp: dataprovider.

=head3 Returns

    $csession:

=head3 Description

Gets the login info and tests the information against the UserDB and LDAP.

=cut

sub login_user {
    XIMS::Debug( 5, "called" );
    my $r  = shift;
    my $dp = shift;
    my $session;
    my ( $username, $password ) = get_logindata($r);

    # first we test if the parameters are ok
    if (    $dp
        and $username
        and length $username
        and $password
        and length $password )
    {
        my $user
            = XIMS::Auth->new( Username => $username, Password => $password )
            ->authenticate();
        if ( $user and $user->id() ) {
            XIMS::Debug( 4, "user found after login; creating session" );
            $session = create_session_id( $r, $dp, $user );
        }
        else {
            XIMS::Debug( 3, "no userinformation found!" );
        }
    }
    else {
        XIMS::Debug( 3, "incomplete parameter list" );
    }

    return $session;
}

=head2 test_for_logout($r, $dp, $session)

=head3 Parameters

    $r:       request-object,
    $dp:      dataprovider,
    $session: session object.

=head3 Returns

    undef or 1.

=cut

sub test_for_logout {
    XIMS::Debug( 5, "called" );
    my $r       = shift;
    my $dp      = shift;
    my $session = shift;

    my $retval = undef;

    if ( lc( $r->method() ) eq 'get' ) {
        my %args = $r->args();
        if ( exists $args{reason} and $args{reason} eq 'logout' ) {
            $retval = 1 if $session->delete();
        }
    }

    XIMS::Debug( 5, "done" );
    return $retval;
}

=head2 redirToDefault($r, $dp, $userid)

=head3 Parameters

    $r:  request-object,
    $dp: dataprovider,
    $userid.

=cut

sub redirToDefault {
    XIMS::Debug( 5, "called" );
    my $r      = shift;
    my $dp     = shift;
    my $userid = shift;

    #warn "r: $r dp: $dp uid: $userid ";
    if ( $r and $dp and $userid ) {
        XIMS::Debug( 4, "redirecting user " );
        my $pathinfo;

        # here we should find the root path for the user (the department for
        # example)

        #check for previous (before login) path and query stored in cookie
        my %cookies = Apache::Cookie->fetch();
        my $cookie;
        my $askedpath;
        my $askedquery;

        # check if a path was asked before login prompt
        $cookie    = $cookies{askedpath} if %cookies;
        $askedpath = $cookie->value()    if $cookie;
        if ( length $askedpath and $askedpath ne "/" ) {
            XIMS::Debug( 5, "user previously requested path $askedpath" );

            # user requested an explicit path
            $pathinfo = $askedpath;

            # let the client forget about the requested path (by setting
            # expire time in the past)
            $cookies{askedpath}->expires("-1Y");
            $cookies{askedpath}->bake();

            # check for queryparameter in query before login prompt
            $cookie     = $cookies{askedquery}             if %cookies;
            $askedquery = uri_unescape( $cookie->value() ) if $cookie;
            if ( length $askedquery ) {
                XIMS::Debug( 5,
                    "user previously requested with query parameters $askedquery"
                );

                # remove query paramters (by setting expire time in the past)
                $cookies{askedquery}->expires("-1Y");
                $cookies{askedquery}->bake();
            }
            else {
                $askedquery = undef;
            }
        }
        else {

            # check the default bookmark for the current user:
            $pathinfo = "/user";
            XIMS::Debug( 5,
                "user did not previously request a path, so we use /user" );
        }

        my $uri = Apache::URI->parse($r);

        # we got user login information including the password in $uri->query
        # which we want to get rid of
        $uri->query(undef);

        $uri->path( XIMS::GOXIMS() . $pathinfo );

        # add possible paramters of query before login
        $uri->query($askedquery) if $askedquery;

        my $frontend_uri = Apache::URI->parse( $r, XIMS::get_server_url( $r ) );
        $uri->scheme( $frontend_uri->scheme() );
        $uri->hostname( $frontend_uri->hostname() );
        $uri->port( $frontend_uri->port() );

        XIMS::Debug( 6, "redirecting to " . $uri->unparse() );

        $r->status_line("302 Found");
        $r->header_out( Location => $uri->unparse );
        $r->send_http_header("text/html");
    }
    XIMS::Debug( 5, "done" );
    return;
}

=head2 view_privilege_handler($r, $session)

=head3 Parameters

    $r:       request object,
    $session: session object.

=head3 Returns

    OK, NOT_FOUND, AUTH_REQUIRED, FORBIDDEN or NOT_FOUND.

=head3 Description

Checks, whether the session owner has VIEW privileges on the requested object.

=cut

sub view_privilege_handler {
    my $r       = shift;
    my $session = shift;

    $session ||= $r->pnotes('ximsSession');
    return AUTH_REQUIRED unless $session and $session->isa('XIMS::Session');

    my $siterootloc = $r->dir_config('ximsSiteRootLocation');
    return FORBIDDEN unless $siterootloc;

    my $uri = $r->uri();

    my $pathbase = $r->dir_config('ximsPubPathBase');
    $uri =~ s/$pathbase//;

    # If we have been directed to an autoindex, use the folder's
    # privileges for testing
    my $autoindex = '/' . XIMS::AUTOINDEXFILENAME() . '$';
    $uri =~ s/$autoindex//;

    my $object = XIMS::Object->new( path => $siterootloc . $uri );
    return NOT_FOUND unless $object;

    my $privmask = $session->user->object_privmask($object);

    #warn "privmask $privmask for user " . $session->user->name();

    return FORBIDDEN unless $privmask & XIMS::Privileges::VIEW();
    return OK;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

A configuration example as intranet AccessHandler:

    <DirectoryMatch "intranet">
        PerlAccessHandler Apache::AuthXIMS
        SetHandler perl-script

        # might be useful for IE-6 and HTTPS
        # PerlSetVar ximsCacheControl private

        PerlSetVar ximsBrowsePublished On
        PerlSetVar ximsPubPathBase /var/www/ximspubroot
        PerlSetVar ximsSiteRootLocation /site
        PerlSetVar ximsAccessDocument /intranet_login.xsp
        PerlSetVar ximsAuthStyle XIMS::Auth::LDAP
    </DirectoryMatch>

=head1 DEPENDENCIES

mod_perl, Apache::Request, Apache::Cookie, URI::Escape, XIMS.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

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

