package Plack::Middleware::XIMS::Auth::Public;
use common::sense;
use parent qw(Plack::Middleware::XIMS::Auth);
use XIMS::Auth::Public;
use HTTP::Throwable::Factory;

# automatically
sub is_login_request  { 1 }

# never
sub is_logout_request { 0 }

# use XIMS::Auth::Public
sub authenticate {
    # validation is implicit
    return XIMS::Auth::Public->new()
}

sub login {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    XIMS::Debug( 5, 'called' );

    if( my $session_id = $self->create_new_session($env) ) {
        XIMS::Debug( 6, 'creating a new session' );
        my  $res = $self->app->($env);
        push @{ $res->[1] }, 'Set-Cookie' => "session=$session_id;path=/;httponly;";
        return $res;   
    }
 
    HTTP::Throwable::Factory->throw({
        status_code => 500,
        reason      => "Failed to create session for public user",
        additional_headers => ['Set-Cookie' => 'session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT',] 
    });
}

sub unauthorized {
    my ($self, $env) = @_;
    XIMS::Debug( 5, "called" );
    
    $env->{HTTP_AUTHORIZATION} = undef;

    # remove cookie and redirect to self
    HTTP::Throwable::Factory->throw({
             status_code => 302,
             reason      => "Found",
             additional_headers => ['Set-Cookie' => 'session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT',
                                    'Location'   => $env->{REQUEST_URI},
                                   ]
    });
}


    
# accept public authentication only
sub has_acceptable_authenticator {
    my ($self, $session) = @_;
    return $session->auth_module() eq 'XIMS::Auth::Public' ? 1 : 0;
}


1;
