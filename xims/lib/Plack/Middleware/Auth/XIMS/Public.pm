package Plack::Middleware::Auth::XIMS::Public;
use common::sense;
use parent qw(Plack::Middleware::Auth::XIMS);
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

1;
