=head1 NAME

xims.psgi -- start over ... and port XIMS to PSGI

=head1 VERSION

$Id: $

=head1 SYNOPSIS

    plackup xims.psgi

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

use common::sense;

use Plack::Builder;
use Plack::App::File;
use Plack::App::Directory;
use HTTP::Throwable::Factory qw(http_exception);

use goxims;
use godav;

builder {
    enable "ConditionalGET";
    enable SizeLimit => (
           max_unshared_size_in_kb => '500000',
           check_every_n_requests => 4 );
    #enable "ErrorDocument", 401 => XIMS::PUBROOT() . '/access.html';
    enable "ContentLength";
    enable "HTTPExceptions";

    enable_if { length(XIMS::TRUSTPROXY()) }
        "Plack::Middleware::XForwardedFor", trust => [split( /,/, XIMS::TRUSTPROXY() )];

    # /goxims
    mount '/login' => \&goxims::login_screen;
    mount XIMS::GOXIMS() => builder {
        #enable 'Profiler::NYTProf';
        enable 'XIMS::AppContext';
        enable 'XIMS::Auth';
        enable 'XIMS::UILang';
        mount XIMS::CONTENTINTERFACE()        => \&goxims::handler; # /content
        mount XIMS::PERSONALINTERFACE()       => \&goxims::handler; # /user
        mount XIMS::USERMANAGEMENTINTERFACE() => \&goxims::handler; # /users
        mount '/userprefs'                    => \&goxims::handler;
        mount '/bookmark'                     => \&goxims::handler;
        mount '/defaultbookmark'              => \&goxims::handler;
        mount '/search_intranet'              => \&goxims::handler;
        mount '/' => http_exception(Found => { location => XIMS::GOXIMS() . XIMS::PERSONALINTERFACE() });
    };

    # /gopublic
    mount XIMS::GOPUBLIC() => builder {
        enable "XIMS::AppContext";
        enable "XIMS::Auth::Public";
        enable 'XIMS::UILang';
        mount XIMS::CONTENTINTERFACE() => \&goxims::handler; # /content
        mount '/' => http_exception('NotFound');
    };

    # this shortcuts a lot of things: no real sessions, just public/published
    # objects, and a 304 response as cheap as possible ... aims to replace
    # Apache::AxKit::Provider::XIMSGoPublic
    mount '/public-content' => builder {
        enable "XIMS::AppContext";
        enable 'XIMS::MockSession';
        enable 'XIMS::UILang';
        enable "XIMS::ConditionalGET";
        mount '/' => \&goxims::quick_handler;
    };

    # /gobaxims
    # mount XIMS::GOBAXIMS() => builder {
    #     enable "XIMS::AppContext";
    #     enable "XIMS::Auth::Basic";
    #     enable 'XIMS::UILang';
    #     mount XIMS::CONTENTINTERFACE()        => builder {$goxims}; # /content
    #     mount XIMS::PERSONALINTERFACE()       => builder {$goxims}; # /user
    #     mount XIMS::USERMANAGEMENTINTERFACE() => builder {$goxims}; # /users
    #     mount '/userprefs'                    => builder {$goxims};
    #     mount '/bookmark'                     => builder {$goxims};
    #     mount '/defaultbookmark'              => builder {$goxims};
    #     mount '/search_intranet'              => builder {$goxims};
    #     mount '/' => http_exception(Found => { location => XIMS::GOBAXIMS() . XIMS::PERSONALINTERFACE() });
    # };

    # WebDAV
    mount XIMS::GODAV() => builder {
        enable "XIMS::AppContext";
        enable "XIMS::Auth::Basic";
        mount '/' => \&godav::handler;
    };

    # static files
    mount XIMS::XIMSROOT_URL()    =>  Plack::App::File->new( root => XIMS::XIMSROOT() );
    mount XIMS::PUBROOT_URL()     =>  Plack::App::File->new( root => XIMS::PUBROOT() );
    mount '/favicon.ico' => Plack::App::File->new(file => XIMS::XIMSROOT() . '/images/xims_favicon.ico');
    mount '/robots.txt'  => Plack::App::File->new(file => XIMS::XIMSROOT() . '/robots.txt');

    # Redirect / -> /goxims
    mount '/' => http_exception(Found => { location => XIMS::GOXIMS() . '/' });
};

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

=head1 BUGS AND LIMITATION

Language-preference handling does not comply to RFC 2616.

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

See the file F<LICENSE> for information and conditions for use,
reproduction, and distribution of this work, and for a DISCLAIMER OF ALL
WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :



