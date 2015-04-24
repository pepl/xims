package Plack::Middleware::XIMS::Auth;
use common::sense;
use parent qw(Plack::Middleware);
use Plack::Request;
use XIMS;
use HTTP::Throwable::Factory;
use Encode qw(encode);

sub prepare_app {}

sub call {
    my ( $self, $env ) = @_;
    my $res;

    # have you got a good session cookie?
    if ( my $session = $self->get_session_from_cookie($env) ) {
        XIMS::Debug( 6, 'got session from cookie' );
        $env->{REMOTE_USER} = $session->user->name;
       
        # but you want to logout?
        if ( $self->is_logout_request($env) ) {
            return $self->logout($env);
        }

        # return app
        return $self->app->($env);
    }
    # no, but you are trying to log in ...
    elsif ( $self->is_login_request($env) ){
        return $self->login($env);
    }
    else {
        # you need to log in here (and haven't tried yet).
        return $self->unauthorized($env);
    }

}

# defines how we find out that we have a login-request;
# (to be overwritten in derived modules)
sub is_login_request {
    my ( $self, $env ) = @_;
    return ($env->{PATH_INFO} eq '/login') ? 1 : undef;
}

# detto
sub is_logout_request {
    my ( $self, $env ) = @_;
    return ($env->{PATH_INFO} eq '/logout') ? 1 : undef;
}


# see if we have a session cookie for a valid session
sub get_session_from_cookie {
    my ( $self, $env ) = @_;
    XIMS::Debug( 5, 'called' );

    my $session        = undef;
    my $session_cookie = Plack::Request->new($env)->cookies->{session};

    if ( length $session_cookie and $session_cookie =~ /^[0-9a-f]+$/ ) {
        XIMS::Debug( 6, "session cookie found: '$session_cookie'" );

        eval {
            $session = XIMS::Session->new( session_id => $session_cookie );
        };
        if ($@) {
            XIMS::Debug( 2, "no session found!" . $@ );
        }

        if ( $session ) {
            my $session_valid = $session->validate( $env->{REMOTE_ADDR} );
            # Session OK 
            if ( $session_valid == 1 ) {
                # check for forbidden authenticators, e.g. XIMS::Auth::Public
                # (see below)
                if ( $self->has_acceptable_authenticator( $session ) )
                {
                    XIMS::Debug( 4, "session cookie validated!" );
                    $env->{'xims.appcontext'}->session($session);
                }
                else {
                    XIMS::Debug( 2, "Authenticator '" . $session->auth_module() . "' not acceptable." );
                    return $self->unauthorized( $env );
                }
            }
            # Session Timeout
            elsif ( $session_valid == -1 ) {
                $env->{'xims.appcontext'}->{reason} = 'timeout';
                XIMS::Debug( 4, "session timeout" );
                $session = undef;
            }
            # Sessionhash did not match.
            else {    
                XIMS::Debug( 2, "rejecting session cookie" );
                $session = undef;
            }
        }
    }
    return $session;    # session or undef
}


sub create_new_session {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    my ( $session_id, $login, $user );
    XIMS::Debug( 5, 'called' );

    if ($login = $self->authenticate( $req->param('userid'), 
                                      $req->param('password'),
                                      $env )
        and $user = $login->getUserInfo()
        and $user->id()
        )
    {
        $env->{'xims.appcontext'}->session(
            XIMS::Session->new(
                'user_id'     => $user->id(),
                'host'        => $env->{REMOTE_ADDR},
                'auth_module' => ref($login)
            )
        );

        $env->{REMOTE_USER} = $user->name();
        $session_id = $env->{'xims.appcontext'}->session->session_id;
    }

    return $session_id;    # session-id or undef
}

sub unauthorized {
    my ($self, $env) = @_;
    my $reason = $env->{'xims.appcontext'}->{reason};
    my $redirect = $env->{PATH_INFO} eq '/logout' ? q{} : $env->{SCRIPT_NAME} . $env->{PATH_INFO};

    XIMS::Debug( 5, "called" );
    $env->{HTTP_AUTHORIZATION} = undef;

    HTTP::Throwable::Factory->throw({
             status_code => 302,
             reason      => "Found",
             additional_headers => ['Set-Cookie' => 'session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT',
                                    'Location'   => $env->{SCRIPT_NAME} . "/login?reason=$reason&redirect=$redirect",
                                    'X-Reason'   => $reason ? $reason : 'none' ]
         });
}

sub authenticate {
    my ( $self, $username, $password, $env ) = @_;
    XIMS::Debug(5, 'called');

    # username/password sanity check  
    return unless ( $username =~ /^[-a-zA-Z0-9.:@]{3,40}$/ 
                and $password =~ /^[-a-zA-Z0-9.:_&!?*\$%+,<=#@;>\/\(\)\[\]{~}]{6,60}$/ );

    # expand domain unless given
    $username .= '@uibk.ac.at' unless $username =~ /@.+$/; 
    
    my @authmods = split(',', XIMS::AUTHSTYLE());

    foreach my $authmod ( @authmods ) {
        XIMS::Debug( 6, "trying authstyle: $authmod" );
        eval "require $authmod;";
        if ( $@ ) {
            XIMS::Debug( 2, "could not load authmod $authmod! reason: $@" );
        }
        else {
            my $login = $authmod->new(  Server   => XIMS::AUTHSERVER(),
                                        Login    => $username,
                                        Password => $password );
            if ( $login ) {
                XIMS::Debug( 4, "login with authstyle $authmod ok" );
                return $login;
            }
            else {
                XIMS::Debug( 4, "login with authstyle $authmod failed" );
            }
        }
    }
    XIMS::Debug( 3, "login failed!" );
    return;
}

# accept anything but public authentication
sub has_acceptable_authenticator {
    my ($self, $session) = @_;
    XIMS::Debug(6, "Authmodule is '" . $session->auth_module() . "'");
    return $session->auth_module() eq 'XIMS::Auth::Public' ? 0 : 1;
}

sub logout {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    XIMS::Debug( 4, "Logout user '" . $env->{'xims.appcontext'}->session->user->name . "'" );

    # so we void your XIMS session
    $env->{'xims.appcontext'}->session()->void();
    
    # congratulation, you have logged out
    $env->{'xims.appcontext'}->{reason} = 'logout';
    $env->{PATH_INFO} = $self->sanitize_redirect($env, $req->param('redirect'));;
    return $self->unauthorized($env);
}

sub login {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    XIMS::Debug( 5, 'called' );

    # ... POST login data?    
    if ( $env->{REQUEST_METHOD} eq 'POST' ) { 
        # try 
        if( my $session_id = $self->create_new_session($env) ) {
            
            XIMS::Debug( 6, 'this is a login request, creating a new session' );
            my $redirect = $self->sanitize_redirect($env, $req->param('redirect'));
            my $res = [ 302, [Location => "$redirect?from_login=1"], ["<html><body><a href=\"$redirect\">Back</a></body></html>"]];

            # all fine, you get a fresh XIMS session cookie, unless we have an
            # ephemeral session (e.g. BasicAuth) 
            # TODO: this should find out when to set the cookies secure flag...
            unless ($session_id eq 'ephemeral') {
               push @{ $res->[1] },
               'Set-Cookie' => "session=$session_id;path=/;httponly;";
            } 
            return $res;   
        }
        else {
            # fail, no session for you, but you certainly may try again ...
            $env->{'xims.appcontext'}->{reason} = 'mismatch';

            # set $env->{PATH_INFO} from redirect parameter for unauthorized() 
            my $script_name = $env->{SCRIPT_NAME}; 
            my $path_info = $self->sanitize_redirect($env, $req->param('redirect'));
            $path_info =~ s/^$script_name//; 
            $env->{PATH_INFO} = $path_info;

            return $self->unauthorized($env);
        }
    }
    # /login, but not POSTing
    else {
        return _render_form($env);
    }  
}

sub sanitize_redirect {
    my ($self, $env, $path) = @_;
    my $script_name = $env->{SCRIPT_NAME};
    
    if ($path =~ /^$script_name/) {
        $path =~ s!(^/[a-z]+(?:/[-_a-z0-9]+(?:\.[a-z0-9]+){0,2})*/?)?.*!$1!i;
        return $path;
    }
    else {
        return $script_name;
    }
}

sub _render_form {
# TODO: i18n.
    my $env = shift;
    my $req = Plack::Request->new($env);  
    my %messages = (mismatch => '<div class="message"><span>Login failed.<br/>Try again with your correct username and password.</span></div>',
                    logout => '<div class="message"><span>Logout successful.<br/>To log in again, enter your username and password.</span></div>',
                    timeout => '<div class="message"><span>Sorry, your session timed out.<br/>To log in again, enter your username and password.</span></div>'
                );
    
    my $message = $messages{ $req->param('reason') };
    my $redirect = sanitize_redirect(undef, $env, $req->param('redirect'));

    # my $motd = q();
    my $motd = XIMS::MOTD();
    my $script_name = $env->{SCRIPT_NAME};
    my $body = <<FORM;
<!DOCTYPE html>
<html>
  <head>
    <title>XIMS - Login</title>
    <link rel="stylesheet" media="screen" type="text/css" href="/ximsroot/stylesheets/login.css"/>
  </head>
  <body">
    <div id="main">
      <div id="header">
        <h1 class="university">My Organization</h1>
        <div id="emotionimage">
          <a title="XIMS" href="http://xims.info">
            <img alt="XIMS Logo" title="XIMS" width="44px" height="44px" src="/ximsroot/images/xims_logo_44x44.png"/>
          </a>
        </div>
      </div>
      $motd
      <form method="post" name="login" action="$script_name/login" id="login">
        <h2>
          <span class="infotext">XIMS LOGIN</span>
        </h2>
        $message
        <div>
          <label for="userid">Username: </label>
          <input tabindex="1" type="text" name="userid" id="userid" class="text" required autofocus/>
        </div>
        <div>
          <label for="password">Password: </label>
          <input tabindex="2" type="password" name="password" id="password" class="text" required/>
        </div>
        <div class="submit">
          <input type="hidden" name="redirect" value="$redirect">
          <input tabindex="3" type="submit" name="login" value="Login" class="control"/>
        </div>
      </form>
    </div>
  </body>
</html>
FORM

return [ 200,
         [ 'Content-Type' => 'text/html;charset=UTF-8',
           'Set-Cookie' => 'session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT',
           'Content-Security-Policy' => "default-src 'none'; img-src 'self'; style-src 'self'",
           'X-Frame-Options' => "DENY", ],
         [ encode('UTF-8', $body) ]
     ];
};


1;
