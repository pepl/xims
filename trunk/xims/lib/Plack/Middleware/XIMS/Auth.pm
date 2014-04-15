package Plack::Middleware::XIMS::Auth;
use common::sense;
use parent qw(Plack::Middleware);
use Plack::Request;
use XIMS;
use HTTP::Throwable::Factory;

sub prepare_app {}

sub call {
    my ( $self, $env ) = @_;
    my $res;

    XIMS::Debug( 5, 'called' );

    # have you got a good session cookie?
    if ( my $session = $self->get_session_from_cookie($env) ) {
        XIMS::Debug( 6, 'got session from cookie' );
        $env->{REMOTE_USER} = $session->user->name;
        $res = $self->app->($env);

        # but you want to logout?
        if ( $self->is_logout_request($env) ) {
            XIMS::Debug( 4, "Logout user '" . $env->{'xims.appcontext'}->session->user->name . "'" );

            # so we void your XIMS session
            $env->{'xims.appcontext'}->session()->void();

            # congratulation, you have logged out
            $res = $self->unauthorized($env, 'logout');
        }

        return $res;
    }

    # no, but you are trying to log in ...
    elsif ( $self->is_login_request($env) ){
        # ... in order to get a new session?
        if ( my $session_id = $self->create_new_session($env) ) {

            XIMS::Debug( 6, 'this is a login request, creating a new session' );

            $res = $self->app->($env);
            # all fine, you get a fresh XIMS session cookie
            # TODO: this should find out when to set the cookies secure flag...
            Plack::Util::response_cb(
                $res,
                sub {
                    my $res = shift;
                    push @{ $res->[1] },
                        'Set-Cookie' => "session=$session_id;path=/;httponly;";
                    return;
                }
            );
            return $res;
        }
        else {
            # no session for you, but you certainly may try again ...
            return $self->unauthorized($env, 'mismatch');
        }
    }
    else {
        # you need to log in here (and haven't tried yet).
        return $self->unauthorized($env);
    }

}

# defines how we find out that we have a login-request;
# to be overwritten; default is our form
# we look for POST and dologin=1;
# could also be a CAS-Ticket...
sub is_login_request {
    my ( $self, $env ) = @_;
    XIMS::Debug(5, 'called');
    my $req = Plack::Request->new($env);
    return ($req->method eq 'POST' and $req->param('dologin') == 1) ? 1 : undef;
}

# detto
sub is_logout_request {
    my ( $self, $env ) = @_;
    XIMS::Debug(5, 'called');
    my $req = Plack::Request->new($env);
    return ($req->method eq 'POST' and $req->param('reason') eq 'logout') ? 1 : undef;
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

        # (still) TODO: Think of separately checking for session timeout and
        # display a corresponding message to the user in case
        if (    $session
            and $session->validate( $env->{REMOTE_ADDR} )
            and $self->has_acceptable_authenticator( $session ) )
        {
            XIMS::Debug( 4, "session cookie validated!" );
            $env->{'xims.appcontext'}->session($session);
        }
        else {
            XIMS::Debug( 2, "rejecting session cookie" );
            $session = undef;
        }
    }
    return $session;    # session or undef
}


sub create_new_session {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    my ( $session_id, $login, $user );
    XIMS::Debug( 5, 'called' );

    if ($login
        = $self->authenticate( $req->param('userid'), $req->param('password'),
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
    my ($self, $env, $reason) = @_;
    XIMS::Debug( 5, "called" );
    $env->{HTTP_AUTHORIZATION} = undef;
    HTTP::Throwable::Factory->throw({
             status_code => 302,
             reason      => "Found",
             additional_headers => ['Set-Cookie' => 'session=; path=/; expires=-1Y',
                                    'Location'   => "/login?reason=$reason&r=" . $env->{SCRIPT_NAME} . $env->{PATH_INFO},
                                    'X-Reason'   => $reason ? $reason : 'none' ]
         });
}

sub authenticate {
    my ( $self, $username, $password, $env ) = @_;
    XIMS::Debug(5, 'called');

    return unless ( $username and $password );

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

1;
