package Plack::Middleware::XIMS::Auth::Basic;
use common::sense;
use parent qw(Plack::Middleware::XIMS::Auth);
use MIME::Base64;

# WARNING: may contain traces of Plack::Middleware::Auth::Basic :-)

#  Do BasicAuths
sub call {
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
                    'session_id'  => 'ephemeral',
                    'user_id'     => $user->id(),
                    'host'        => $env->{REMOTE_ADDR},
                    'auth_module' => ref($login)
                )
            );

            $env->{REMOTE_USER} = $user->name();

            return $self->app->($env);
        }
    }

    return $self->unauthorized;
}


sub unauthorized {
    my ( $self, $env, $reason ) = @_;
    XIMS::Debug( 5, 'called' );

    $env->{HTTP_AUTHORIZATION} = undef;

    HTTP::Throwable::Factory->throw(
        {   status_code        => 401,
            reason             => 'Unauthorized',
            additional_headers => [
                'WWW-Authenticate' => 'Basic realm="Login to XIMS"',
                'X-Reason' => $reason ? $reason : 'none'
            ]
        }
    );
}



1;
