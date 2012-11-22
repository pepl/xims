package Plack::Middleware::Auth::XIMSPublicUser;
use strict;
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

1;
