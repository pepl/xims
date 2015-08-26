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

    # # first check if authentication has been externally provided. We use this
    # # for requests that do not need a real session and may not be redirected,
    # # e.g. Shibboleth authenticated intranet search
    # if ( $remote_user = $env->{REMOTE_USER}
    #      and $user = XIMS::User->new( name => $remote_user )
    #      and $user->id() and $user->enabled() eq '1' )
    # {
    #     XIMS::Debug( 6, 'this is a login request, creating a new session' );
        
    #     $env->{'xims.appcontext'}->session(
    #         XIMS::Session->new(
    #             'session_id'  => 'ephemeral',
    #             'user_id'     => $user->id(),
    #             'host'        => $env->{REMOTE_ADDR},
    #             'auth_module' => $env->{AUTH_TYPE}
    #         )
    #         );
    #     return $self->app->($env);
    # }

    # Otherwise proceed with BasicAuth
    
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
