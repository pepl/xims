package Plack::Middleware::XIMS::Auth::Ext;
use common::sense;
use parent qw(Plack::Middleware::XIMS::Auth);
use XIMS;
use XIMS::User;
use Encode qw(encode);

# Let someone else (say, mod_shibboleth) do the autorisation and trust what they
# leave in REMOTE_USER for us. We try to set up a session from this.
sub call {
    my ( $self, $env ) = @_;
    my ($user, $remote_user);
    XIMS::Debug( 5, 'called' );

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
    elsif ( $remote_user = $env->{REMOTE_USER}
            and $user = XIMS::User->new( name => $remote_user )
            and $user->id() and $user->enabled() eq '1' )
    {
        $env->{'xims.appcontext'}->session(
            XIMS::Session->new(
                'user_id'     => $user->id(),
                'host'        => $env->{REMOTE_ADDR},
                'auth_module' => $env->{AUTH_TYPE}
            )
            );

        my $res = $self->app->($env);
        # TODO: this should find out when to set the cookies secure flag...
        if (my $session_id = $env->{'xims.appcontext'}->session->session_id ) {
            push @{ $res->[1] },
            'Set-Cookie' => "session=$session_id;path=/;httponly;secure;";
        } 
        return $res;   
    }
    
    return $self->unauthorized;
}

sub logout {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    XIMS::Debug( 4, "Logout user '" . $env->{'xims.appcontext'}->session->user->name . "'" );

    # so we void your XIMS session
    $env->{'xims.appcontext'}->session()->void();
    
    # congratulation, you have logged out
    $env->{'xims.appcontext'}->{reason} = 'logout';

    my $msg;
    my $path = $self->sanitize_redirect($env, $req->param('redirect'));
    
    if ($env->{'Shib_Session_ID'}) {
        $msg = qq(However, you likely still have a valid Session from Shibboleth Single Sign On. You can
                <ul>
                  <li><a href="/Shibboleth.sso/Logout">Log off Shibboleth</a> as well.</li> 
                  <li><a href="$path">Start over</a> with a new Session in XIMS.</li>
                  <li>or just <a href="#" onclick="close_window();return false;">close this tab/window</a> to leave things as they are.</li>
                <ul>);
    }
    else {
        
        q(However, your authentication provider might still have you down so 
          that you will be automatically logged on XIMS again unless you take 
          an extra step to log off there. 
          Depending on your setup, closing the browser might help.);
    }
    
    my $body = <<LOGOUT;
<!DOCTYPE html>    
<html>
  <head>
    <title>XIMS session terminated</title>
    <link rel="stylesheet" media="screen" type="text/css" href="/ximsroot/stylesheets/login.css"/>
  </head>
  <body>
   <body>
    <div id="main">
      <div id="header">
        <h1 class="university">My Organization</h1>
        <div id="emotionimage">
          <a title="XIMS" href="http://xims.info">
            <img alt="XIMS Logo" title="XIMS" width="44px" height="44px" src="/ximsroot/images/xims_logo_44x44.png"/>
          </a>
        </div>
      </div>
      <h2>
          <span class="infotext">XIMS session terminated</span>
        </h2>
       
      $msg
    </div>
  </body>
</html>
LOGOUT
     

    
    return [200, ['Content-Type' => 'text/html;charset=UTF-8',
                  'Set-Cookie' => 'session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT'], 
            [encode('UTF-8', $body)]]
   
}


sub unauthorized {
    my ( $self, $env, $reason ) = @_;
    XIMS::Debug( 5, 'called' );

    HTTP::Throwable::Factory->throw(
        {   status_code        => 403,
            reason             => 'You are not entitled to use this system. Go away!',
            additional_headers => [
                'X-Reason' => $reason ? $reason : 'none'
            ]
        }
    );
}

1;
