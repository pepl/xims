# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package Apache::AuthXIMS;

use strict;

use Apache;
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
##
#
# SYNOPSIS
#    handler
#
# PARAMETERS
#    $r: request-object
#
# RETURNVALUES
#    'DECLINED', 'OK' or 'FORBIDDEN'
#
# DESCRIPTION
#    none yet
#
sub handler {
    XIMS::Debug( 5, "called" );
    my $r = shift;

    my $retval = DECLINED;
    my %args = $r->args();

    my $dp = XIMS::DATAPROVIDER();
    my $accessdoc = $r->dir_config('ximsAccessDocument');
    $accessdoc ||= XIMS::PUBROOT_URL() . '/access.xsp'; # default hardcoded fallback value

    my $url = $accessdoc . "?reason=DataProvider%20could%20not%20be%20instantiated.%20There%20may%20be%20a%20database%20connection%20problem.";
    $r->custom_response(SERVER_ERROR, $url);
    return SERVER_ERROR unless $dp;

    XIMS::Debug( 4, "getting session cookie" );
    my $cSession = undef;
    my $session  = get_session_cookie( $r );
    my $login = 0 ;
    if ( length $session ) {
        XIMS::Debug( 6, "session cookie found: '$session'" );
        $cSession = test_session( $r, $dp, $session );
        if ( not $cSession ) {
            XIMS::Debug( 2, "invalid session: drop cookie!" );
            unset_session_cookie( $r );
        }
        elsif ( test_for_logout( $r, $dp, $cSession ) ) {
            unset_session_cookie( $r );
            $cSession = undef;
        }
    }
    else {
        XIMS::Debug( 3, "no session cookie found " );
        $cSession = login_user( $r, $dp );
        unless ( $cSession ) {
            my $askedpath = $r->path_info();
            my $askedquery = Apache::URI->parse( $r )->query();

            if ( $askedquery !~ m/dologin/ ) {
                XIMS::Debug( 6, "setting client cookie 'askedquery' to value '$askedquery'" );
                Apache::Cookie->new($r,
                                    -name    =>  'askedquery',
                                    -value   =>  uri_escape( $askedquery ),
                                    -path    =>  '/'
                                   )->bake();
                XIMS::Debug( 6, "setting client cookie 'askedpath' to value '$askedpath'" );
                Apache::Cookie->new($r,
                                    -name    =>  'askedpath',
                                    -value   =>  $askedpath,
                                    -path    =>  '/'
                                   )->bake();
            }
        }
        $login = 1;
    }

    if ( $cSession ) {
        #warn "session found" . Dumper( $cSession ) . "\n";
        my $browsepublished = $r->dir_config('ximsBrowsePublished');
        if ( not $login ) {
            XIMS::Debug( 4, "session confirmed: storing to pnotes" );
            set_user_info( $r ,
                           $dp,
                           $cSession );
            return view_privilege_handler( $r, $cSession ) if $browsepublished;
        }
        else {
            XIMS::Debug( 4, "session confirmed: storing cookie" );
            set_session_cookie( $r, $cSession->session_id() );
            if ( $browsepublished ) {
                my $rv = view_privilege_handler( $r, $cSession );
                return FORBIDDEN if $rv == FORBIDDEN;
                $r->status_line( "302 Found" );
                $r->header_out( Location => $r->uri );
                $r->send_http_header( "text/html" );
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
        $url = $accessdoc;
        if ( $args{dologin} ) {
            $url .= "?reason=Access%20Denied.%20Please%20provide%20a%20valid%20username%20and%20password.";
        };
        $r->custom_response(FORBIDDEN, $url);
        return FORBIDDEN;
    }
}

##
#
# SYNOPSIS
#    get_session_cookie($r)
#
# PARAMETER
#    $r: request-object
#
# RETURNS
#    SessionHandle if successful,
#    "" otherwise
#
# DESCRIPTION
#    none yet
#
sub get_session_cookie {
    XIMS::Debug( 5, "called" );
    my $r = shift;

    my $cookiename = "session"; # should this get from the config
    my $session;
    my %cookies = Apache::Cookie->fetch();
    my $cookie = $cookies{ $cookiename } if %cookies;
    if( $cookie ) {
        $session = $cookie->value();
        XIMS::Debug( 6, "found session '$session' in client cookie '$cookiename'" );
    }

    XIMS::Debug( 5, "done" );
    return $session || "";
}


##
#
# SYNOPSIS
#    set_session_cookie( $r, $session )
#
# PARAMETERS
#    $r: request-object
#    $session: session-object
#
# RETURNVALUES
#    1 if succsessful,
#    0 otherwise
#
# DESCRIPTION
#    creates a cookie
#    redirects to old destination ?
#
sub set_session_cookie {
    XIMS::Debug( 5, "called" );
    my $r = shift;
    my $session = shift;

    my $retval  = 0;

    if ( length $session ) {
        XIMS::Debug( 4, "session string found: $session" );
        my $cookiename = "session"; # should this get from the config

        XIMS::Debug( 6, "setting client cookie '$cookiename' to value '$session'" );
        # need expires? if it not set, the cookie gets lost after browser shutdown
        Apache::Cookie->new($r,
                            -name    =>  $cookiename,
                            -value   =>  $session,
                            -path    =>  '/'
                           )->bake();
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "cannot set empty session key" );
    }

    XIMS::Debug( 5, "done" );
    return $retval ;
}


##
#
# SYNOPSIS
#    unset session_cookie($r)
#
# PARAMETERS
#    $r: request-object
#
# RETURNVALUES
#    1
#
# DESCRIPTION
#    none yet
#
sub unset_session_cookie {
    XIMS::Debug( 5, "called" );
    my $r = shift;
    my $cookiename = "session"; # should this get from the config

    # not needed anymore? no other references to 'ximsCookie' found!
    # $r->pnotes( "ximsCookie", "$cookiename= ; path=/" );

    XIMS::Debug( 6, "removing client cookie '$cookiename'" );
    Apache::Cookie->new($r, -name =>  $cookiename, -path => '/', -expires => '-1Y', )->bake();

    XIMS::Debug( 5, "done" );
    return 1;
}


##
#
# SYNOPSIS
#    set_user_info()
#
# PARAMETERS
#    $r: request-object
#    $dp: dataprovider-object
#    $session: session-object
#    $config: directory configuration
#
#
# RETURNVALUES
#    none
#
# DESCRIPTION
#    none yet
#
sub set_user_info {
    XIMS::Debug( 5, "called" );
    my $r       = shift;
    my $dp      = shift;
    my $session = shift;

    $r->pnotes( ximsSession   => $session );
    $r->pnotes( ximsProvider  => $dp );
}


##
#
# SYNOPSIS
#    test_session()
#
# PARAMETERS
#    $r: request-object
#    $dp: dataprovider
#    $sessionstring:
#
# RETURNVALUES
#    $cSession
#
# DESCRIPTION
#    none yet
#
sub test_session {
    XIMS::Debug( 5, "called" );

    # gets session string and returns related session class if any
    my $r = shift;
    my $dp = shift;
    my $sessionstring= shift;

    my $cSession = undef;

    eval {
        $cSession = XIMS::Session->new( session_id => $sessionstring );
    };
    if ( $@ ) {
        XIMS::Debug( 2, "no session found!" . $@ );
    }

    if ( $cSession and $cSession->validate( $r->connection->remote_ip() ) ) {
        XIMS::Debug( 4, "session cookie validated!" );
        #$cSession->update(); # ubu: is this really needed?
    }
    else {
        XIMS::Debug( 2, "rejecting session cookie" );
        $cSession = undef;
    }

    XIMS::Debug( 5, "done" );
    return $cSession; # return session class
}


##
#
# SYNOPSIS
#    create_session_id($r, $dp, $cUser)
#
# PARAMETERS
#    $r: request-object
#    $dp: dataprovider
#    $cUser:
#
# RETURNVALUES
#    $cSession
#
# DESCRIPTION
#    none yet
#
sub create_session_id {
    XIMS::Debug( 5, "called" );
    my $r     = shift;
    my $dp    = shift;
    my $cUser = shift;

    # sekret key from config?
    my $cSession = undef;

    if ( $dp and $r and $cUser) {
        XIMS::Debug( 4, "completing dataset for cookie creation" );
        $cSession =  XIMS::Session->new( 'user_id'   => $cUser->id(),
                                         'user_name' => $cUser->name(),
                                         'host'      => $r->connection->remote_ip());
        unless ( $cSession ) {
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


##
#
# SYNOPSIS
#    get_logindata($r)
#
# PARAMETERS
#    $r: request-object
#
# RETURNVALUES
#    ( userid, password )
#
# DESCRIPTION
#    read logindata from request and return it as an array
#
sub get_logindata {
    # this function handles POST and GET equally
    # pepl: what about Apache::Request::param() here?
    XIMS::Debug( 5, "called" );

    my $r = shift;
    my %args = ();
    if ( lc( $r->method() ) eq 'get' ) {
        XIMS::Debug( 4, "METHOD = GET" );
        %args = $r->args();
    }
    else {
        XIMS::Debug( 4, "METHOD = POST" );
        my $qstr = $r->content();
        #    XIMS::Debug( 6, "query string ", $qstr );
        $r->method( 'GET' );
        $r->args( $qstr );
        %args = split /=|&/, $qstr ;
    }

    return ( Apache::unescape_url_info($args{userid}) , Apache::unescape_url_info($args{password}) ) ;
}


##
#
# SYNOPSIS
#    login_user($r, $dp)
#
# PARAMETERS
#    $r: request-object
#    $dp: dataprovider
#
# RETURNVALUES
#    $csession:
#
# DESCRIPTION
#    gets the login info
#    and tests the information against the UserDB and LDAP =)
#
sub login_user {
    XIMS::Debug( 5, "called" );
    my $r  = shift;
    my $dp = shift;
    my $session;
    my ( $username, $password ) = get_logindata( $r );

    # first we test if the parameter are ok
    if ( $dp and $username and length $username and $password and length $password ) {
        my $user = XIMS::Auth->new( Username => $username, Password => $password )->authenticate();
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


##
#
# SYNOPSIS
#    test_for_logout($r, $dp, $session)
#
# PARAMETERS
#    $r: request-object
#    $dp: dataprovider
#    $session: session-object
#
# RETURNVALUES
#    $retval: undef or 1
#
# DESCRIPTION
#    none yet
#
sub test_for_logout {
    XIMS::Debug( 5, "called" );
    my $r = shift;
    my $dp = shift;
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


##
#
# SYNOPSIS
#    redirToDefault($r, $dp, $userid)
#
# PARAMETERS
#    $r: request-object
#    $dp: dataprovider
#    $userid
#
# RETURNVALUES
#    none
#
# DESCRIPTION
#    none yet
#
sub redirToDefault {
    XIMS::Debug( 5, "called" );
    my $r = shift;
    my $dp = shift;
    my $userid = shift;

    #warn "r: $r dp: $dp uid: $userid ";
    if ( $r and $dp and $userid ) {
        XIMS::Debug( 4, "redirecting user " );
        my $pathinfo;
        # here we should find the root path for the user (the department for example)

        # check for previous (before login) path and query stored in cookie
        my %cookies = Apache::Cookie->fetch();
        my $cookie;
        my $askedpath;
        my $askedquery;

        # check if a path was asked before login prompt
        $cookie = $cookies{ askedpath } if %cookies;
        $askedpath = $cookie->value() if $cookie;
        if ( length $askedpath and $askedpath ne "/") {
            XIMS::Debug( 5, "user previously requested path $askedpath");
            # user requested an explicit path
            $pathinfo = $askedpath;

            # let the client forget about the requested path (by setting expire time in the past)
            $cookies{ askedpath }->expires("-1Y");
            $cookies{ askedpath }->bake();

            # check for queryparameter in query before login prompt
            $cookie = $cookies{ askedquery } if %cookies;
            $askedquery = uri_unescape( $cookie->value() ) if $cookie;
            if ( length $askedquery ) {
                XIMS::Debug( 5, "user previously requested with query parameters $askedquery" );

                # remove query paramters (by setting expire time in the past)
                $cookies{ askedquery }->expires("-1Y");
                $cookies{ askedquery }->bake();
            }
            else {
                $askedquery = undef;
            }
        }
        else {
            # check the default bookmark for the current user:
            $pathinfo = "/user";
            XIMS::Debug( 5, "user did not previously request a path, so we use /user" );
        }

        my $uri = Apache::URI->parse( $r );
        # we got user login information including the password in $uri->query which we want to get rid of
        $uri->query(undef);

        $uri->path( XIMS::GOXIMS() . $pathinfo );
        # add possible paramters of query before login
        $uri->query($askedquery) if $askedquery;

        XIMS::Debug( 6, "redirecting to " . $uri->unparse() );

        $r->status_line( "302 Found" );
        $r->header_out( Location => $uri->unparse );
        $r->send_http_header( "text/html" );
    }
    XIMS::Debug( 5, "done" );
}

sub view_privilege_handler {
    my $r = shift;
    my $session = shift;

    $session ||= $r->pnotes('ximsSession');
    return AUTH_REQUIRED unless $session and $session->isa('XIMS::Session');

    my $pathbase = $r->dir_config('ximsPubPathBase');
    my $siterootloc = $r->dir_config('ximsSiteRootLocation');
    return FORBIDDEN unless $siterootloc;

    my $uri = $r->uri();
    $uri =~ s/$pathbase//;

    my $object = XIMS::Object->new( path => $siterootloc . $uri );
    return NOT_FOUND unless $object;

    my $privmask = $session->user->object_privmask( $object );
    #warn "privmask $privmask for user " . $session->user->name();

    return FORBIDDEN unless $privmask & XIMS::Privileges::VIEW();
    return OK;
}


1;
