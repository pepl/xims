package Plack::Middleware::XIMS::Auth::Public;
use common::sense;
use parent qw(Plack::Middleware::XIMS::Auth);
use XIMS::Auth::Public;

# automatically
sub is_login_request  { 1 }

# never
sub is_logout_request { 0 }

# use XIMS::Auth::Public
sub authenticate {
    # validation is implicit
    return XIMS::Auth::Public->new()
}


# accept public authentication only
sub has_acceptable_authenticator {
    my ($self, $session) = @_;
    return $session->auth_module() eq 'XIMS::Auth::Public' ? 1 : 0;
}


1;
