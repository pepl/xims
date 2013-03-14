package Plack::Middleware::XIMS::Auth::Basic;
use common::sense;
use parent qw(Plack::Middleware::XIMS::Auth);
use Plack::Util::Accessor qw( realm );
use MIME::Base64;

# WARNING: may contain parts of Plack::Middleware::Auth::Basic :-)

# automatically
sub is_login_request  { 1 }

#  Do BasicAuths
sub create_new_session {
    my ( $self, $env ) = @_;
    my ( $session_id, $login, $user );
    XIMS::Debug( 5, 'called' );

    my $auth = $env->{HTTP_AUTHORIZATION}
        or return $self->unauthorized;

    # note the 'i' on the regex, as, accoring to RFC2617 this is a
    # "case-insensitive token to identify the authentication scheme"
    if ( $auth =~ /^Basic (.*)$/i ) {
        my ( $ba_user, $ba_pass ) = split /:/,
            ( MIME::Base64::decode($1) || ":" ), 2;
        $ba_pass = '' unless defined $ba_pass;

        if (    $login = $self->authenticate( $ba_user, $ba_pass, $env )
            and $user = $login->getUserInfo()
            and $user->id() )
        {
            $env->{'xims.appcontext'}->session(
                XIMS::Session->new(
                    'user_id'     => $user->id(),
                    'user_name'   => $user->name(),
                    'host'        => $env->{REMOTE_ADDR},
                    'auth_module' => ref($login)
                )
            );

            $env->{REMOTE_USER} = $user->name();
            $session_id = $env->{'xims.appcontext'}->session->session_id;
        }
    }
    return $session_id;    # session-id or undef
}

sub unauthorized {
    my ( $self, $env, $reason ) = @_;
    XIMS::Debug( 5, 'called' );

    $env->{HTTP_AUTHORIZATION} = undef;

    HTTP::Throwable::Factory->throw(
        {   status_code        => 401,
            reason             => 'Unauthorized',
            additional_headers => [
                'Set-Cookie'       => 'session=; path=/; expires=-1Y',
                'WWW-Authenticate' => 'Basic realm="Login to XIMS"',
                'X-Reason' => $reason ? $reason : 'none'
            ]
        }
    );
}

1;
