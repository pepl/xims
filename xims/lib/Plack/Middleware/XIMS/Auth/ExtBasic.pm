package Plack::Middleware::XIMS::Auth::ExtBasic;
use common::sense;
use parent qw(Plack::Middleware::XIMS::Auth);
use XIMS;
use XIMS::User;
use Encode qw(encode);


sub call {
    my ( $self, $env ) = @_;
    my ( $session_id, $login, $user, $remote_user );
    XIMS::Debug( 5, 'called' );

    # Let someone else (say, mod_shibboleth) do the authorisation and trust what
    # they leave in REMOTE_USER for us. For requests that do not need a real
    # session and may not be redirected, e.g. Shibboleth authenticated intranet
    # search; Use Plack::Middleware::XIMS::Auth::Ext to get a real Xims-Session
    if ( $remote_user = $env->{REMOTE_USER}
         and $user = XIMS::User->new( name => $remote_user )
         and $user->id() and $user->enabled() eq '1' )
    {
        XIMS::Debug( 6, 'this is a login request, creating a new session' );
        
        $env->{'xims.appcontext'}->session(
            XIMS::Session->new(
                'session_id'  => 'ephemeral',
                'user_id'     => $user->id(),
                'host'        => $env->{REMOTE_ADDR},
                'auth_module' => $env->{AUTH_TYPE}
            )
            );
        return $self->app->($env);
    }

    return $self->unauthorized;
}


sub unauthorized {
    my ( $self, $env, $reason ) = @_;
    XIMS::Debug( 5, 'called' );

    $env->{REMOTE_USER} = undef;

    HTTP::Throwable::Factory->throw( { status_code => 403,  
                                       reason      => "Forbidden", 
                                     } 
                              );

}



1;
