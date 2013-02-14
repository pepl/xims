package Plack::Middleware::Auth::XIMSPublicUser;
use common:sense;
use parent qw(Plack::Middleware);
# use Plack::Util::Accessor qw( realm authenticator );
# use Scalar::Util;
# use MIME::Base64;
use XIMS::Auth::Public;

sub prepare_app {}

sub call {
    my($self, $env) = @_;

    my $auth = $env->{HTTP_AUTHORIZATION}
        or return $self->unauthorized;

    my $login = XIMS::Auth::Public->new();
    my $user = $login->getUserInfo();

    if ( $user and $user->id() ) {
        $env->{'xims.appcontext'}->session( XIMS::Session->new() );
        $env->{'xims.appcontext'}->session->user_id( $user->id() );
        $env->{'xims.appcontext'}->session->auth_module( ref($login) );
        $env->{REMOTE_USER} = $user->name();
        return $self->app->($env);
    }

    return $self->unauthorized;
}

sub unauthorized {
    my $self = shift;
    my $body = 'Authorization required';
    return [
        401,
        [ 'Content-Type' => 'text/plain',
          'Content-Length' => length $body],
        [ $body ],
    ];
}





=head2 get_session_cookie($r)

=head3 Parameters

    $r: request-object.

=head3 Returns

Session handle if successful, empty string otherwise.

=cut

sub get_session_cookie {
    XIMS::Debug( 5, "called" );
    my $env = shift;

    my $cookiename = 'session';    # should this get from the config
    my $session;


    my %cookies = Plack::Request->new( $env )->cookies();
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
    my ($env, $session) = @_;

    my $retval = 0;

    if ( length $session ) {
        XIMS::Debug( 4, "session string found: $session" );
        my $cookiename = 'session';    # should this get from the config

        XIMS::Debug( 6,
            "setting client cookie '$cookiename' to value '$session'" );

        # need expires? if it not set, the cookie gets lost after
        # browser shutdown
        $env->res->cookies->{$cookiename} = {
            value => $session,
            path  => '/'
        };
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
    my $env          = shift;
    my $cookiename = "session";    # should this get from the config

    XIMS::Debug( 6, "removing client cookie '$cookiename'" );
    $env->res->cookies->{$cookiename} = {
            #value => $session,
            path  => '/',
            expires => '-1Y'
        };

    XIMS::Debug( 5, "done" );
    return 1;
}


1;
