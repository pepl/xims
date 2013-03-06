package Plack::Middleware::Auth::XIMS;
use common::sense;
use parent qw(Plack::Middleware);
use Plack::Request;
use XIMS::Auth;
use HTTP::Throwable::Factory;

sub prepare_app {}

sub call {
    my ( $self, $env ) = @_;
    my $res;

    XIMS::Debug( 5, 'called' );

    # have you got a good session cookie?
    if ( $self->get_session_from_cookie($env) ) {
        XIMS::Debug( 6, 'got session from cookie' );
        $res = $self->app->($env);

        # but you want to logout?
        if ( $self->is_logout_request($env) ) {
            XIMS::Debug( 4, "Logout user '" . $env->{'xims.appcontext'}->session->user->name . "'" );

            # so we void your XIMS session
            $env->{'xims.appcontext'}->session()->delete();

            # congratulation, you have logged out
            $res = $self->unauthorized($env, 'logout');
        }

        return $res;
    }

    # no, so you might want to login and get a new session?
    elsif ( $self->is_login_request($env)
        and my $session_id = $self->create_new_session($env) )
    {
        XIMS::Debug( 6, 'this is a login request, creating a new session' );

        $res = $self->app->($env);
        # all fine, you get a fresh XIMS session cookie
        # XXX should find out, when to set the secure-flag...
        Plack::Util::response_cb(
            $res,
            sub {
                my $res = shift;
                push @{ $res->[1] },
                    'Set-Cookie' => "session=$session_id; path=/";
                return;
            }
        );
        return $res;
    }
    # otherwise, you certainly may try again…
    else {
        return $self->unauthorized($env, 'mismatch');
    }

}

# how to find out, we have a login-request.
# to be overwritten; default is our form
# we look for POST and dologin=1;
# could also be a CAS-Ticket…
sub is_login_request {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    return ($req->method eq 'POST' and $req->param('dologin') == 1) ? 1 : undef;
}

# detto
sub is_logout_request {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    return ($req->method eq 'GET' and $req->param('reason') eq 'logout') ? 1 : undef;
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
        if ( $session and $session->validate( $env->{REMOTE_ADDR} ) ) {
            XIMS::Debug( 4, "session cookie validated!" );
            $env->{'xims.appcontext'}->session($session);
        }
        else {
            XIMS::Debug( 2, "rejecting session cookie" );
            $session = undef;
        }
    }
    return $session; # session or undef
}




sub create_new_session {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    my ( $session_id, $login, $user );

    XIMS::Debug( 5, "called" );

    if ( $login = $self->authenticate($env)
        and $user = $login->getUserInfo()
        and $user->id()
       )
    {
        $env->{'xims.appcontext'}->session(
            XIMS::Session->new(
                'user_id'   => $user->id(),
                'user_name' => $user->name(),
                'host'      => $env->{REMOTE_ADDR}
            )
        );
        $env->{'xims.appcontext'}->session->auth_module( ref($login) );
        $env->{REMOTE_USER} = $user->name();
        $session_id = $env->{'xims.appcontext'}->session->session_id;
    }

    return $session_id; # session-id or undef
}

sub unauthorized {
    my ($self, $env, $reason) = @_;
    XIMS::Debug( 5, "called" );

    HTTP::Throwable::Factory->throw({
             status_code => 401,
             reason      => 'Unauthorized',
             additional_headers => ['Set-Cookie' => 'session=; path=/; expires=-1Y',
                                    'X-Reason' => $reason ]
         });

}


# use generic XIMS::Auth
sub authenticate {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    return XIMS::Auth->new->authenticate( Username => $req->param('userid'),
                                          Password => $req->param('password'))
}

1;
