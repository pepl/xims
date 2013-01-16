
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

use strict;

use Locale::Messages qw(bind_textdomain_filter bind_textdomain_codeset turn_utf_8_on);
use Locale::TextDomain ('info.xims');
use POSIX qw(setlocale LC_ALL);
use URI::Escape qw(uri_escape_utf8);

use XIMS;
use XIMS::AppContext;
use XIMS::DataProvider;
use XIMS::Object;
use XIMS::User;
use XIMS::Auth;
use XIMS::Session;
# preload commonly used and publish_gopublic objecttypes
use XIMS::CGI::SiteRoot;
use XIMS::CGI::DepartmentRoot;
use XIMS::CGI::Document;
use XIMS::CGI::Portlet;
use XIMS::CGI::Questionnaire;

use Plack::Request;
use Plack::Builder;
use Plack::App::File;
use Plack::App::Directory;

use Time::Piece;

use Data::Dumper;

my $goxims = sub {
    warn "\n" x 3, '=' x 80, "\n";
    my $env = shift;

    my $ctxt = $env->{'xims.appcontext'};
    my $req = Plack::Request->new($env);

    XIMS::Debug( 5, $env->{script_name}. " called from " . $env->{REMOTE_ADDR} );

    # sprache einstellen

    # public user?


    my $interface_type = getInterface($req);
    HTTP::Exception::404->throw unless $interface_type;

    my $gp = XIMS::GOPUBLIC();
    # TODO: handle public user somewhere else
    if ($req->script_name() =~ /^$gp/) {
        # /gopublic has no interface "user" (n.b. it isn't even mounted)
        if ( $interface_type eq XIMS::PERSONALINTERFACE() ) {
            HTTP::Exception::404->throw();
        }
        # was: set up session for public user
    }
    else {
        # we are coming in via /goxims
        if ( defined $ctxt->session()
             and     $ctxt->session->user->id() ==
                 XIMS::Config::PublicUserID() ) {
            $ctxt->{session}->delete();
            HTTP::Exception::403->throw();
        }
    }

    # set some session information
    my $tp = localtime;
    $ctxt->session->date( $tp->ymd() . ' ' . $tp->hms() );

    # TODO: proxy stuff
    #my $serverurl = XIMS::get_server_url( $r );
    #XIMS::Debug( 6, "setting serverurl to $serverurl" );
    #$ctxt->session->serverurl( $serverurl );

    # now we have a user based skin selection.
    #$ctxt->session->skin( XIMS::DEFAULT_SKIN() );
    if($ctxt->session->user->userprefs){
    	$ctxt->session->skin( $ctxt->session->user->userprefs->skin());
    }
    else{
    	$ctxt->session->skin(XIMS::DEFAULT_SKIN() );
    }

    # Big fork here
    #
    my $app_class    = 'XIMS::CGI::';
    my $object_class = 'XIMS::';

    if ( $interface_type eq 'content' ) {

        # now we know, that we have to get the content-object
        $ctxt->object( getObject( $req ) );
        if ( not( $ctxt->object() and $ctxt->object->id() ) ) {
           HTTP::Exception::404->throw();
       }

        my $ot_fullname = $ctxt->object->object_type->fullname();
        $object_class .= $ot_fullname;

        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ($@) {
            XIMS::Debug( 2, "could not load object class $object_class: $@" );
            HTTP::Exception::500->throw(
                status_message => __x(
                    "Could not load object class {classname}.",
                    classname => $object_class,
                )
            )
        }

        ## use critic
        # rebless the object
        XIMS::Debug( 4, "reblessing object to " . $object_class );
        bless $ctxt->object(), $object_class;

        # find out if we want to create an object!
        # if goxims finds an 'objtype'-param it assumes that it
        # is called to create a new object.
        my $objtype = $req->param('objtype');

        my $prefix;
        if ( defined $objtype and length $objtype ) {
            XIMS::Debug( 6, "we are creating a new $objtype" );
            $app_class .= $objtype;
            $prefix = lc $objtype;
        }
        else {
            $app_class .= $ot_fullname;
            $prefix = lc $ot_fullname;
        }
        $prefix =~ s/::/_/g;
        $ctxt->properties->application->styleprefix($prefix);
    }    # end 'content' case

    # every other interface apart from /content that is configured in xims.psgi
    else {
        $app_class .= $interface_type;
        $ctxt->properties->application->styleprefix($interface_type);
    }

    ##
    # end interface-lookup
    ##
    ## no critic (ProhibitStringyEval)
    eval "require $app_class";
    if ($@) {
        XIMS::Debug( 2, "could not load application-class $app_class: $@" );
        HTTP::Exception::500->throw(
            status_message => __x(
                "Could not load object class {classname}.",
                classname => $app_class,
            )
        );
    }
    ## use critic
    if ( my $appclass = $app_class->new($env) ) {
        XIMS::Debug( 4, "application-class $app_class initiated." );
        $appclass->setStylesheetDir( XIMS::XIMSROOT()
              . '/skins/'
              . $ctxt->session->skin
              . '/stylesheets/'
              . $ctxt->session->uilanguage() );

        return $appclass->run($ctxt);
    }

    HTTP::Exception::500->throw(
        status_message => "Server Error.\n\nYou shouldn't have ended here, sorry!"
    );
};

my $gopublic = sub {
    my $env = shift;
    return &$goxims($env);
};


my $gobaxims = sub {
    my $env = shift;
    return &$goxims($env);
};

my $godav = sub {
    my $env = shift;
    return &$goxims($env);
};


builder {
    # enable "ErrorDocument",
    #     500 => '/ximspubroot/500.xsp',
    #     404 => '/ximspubroot/404.xsp',
    #     401 => '/ximspubroot/access.xsp',
    #     subrequest => 1;
    # lästig beim debuggen…
    # enable "HTTPExceptions", rethrow => 1;
    enable "ConditionalGET";

    enable_if { length(XIMS::TRUSTPROXY()) }
        "Plack::Middleware::XForwardedFor", trust => [split( /,/, XIMS::TRUSTPROXY() )];

    # /goxims
    mount XIMS::GOXIMS() => builder {
        enable 'XIMSAppContext';
        #enable 'Session';
        enable 'Auth::Basic', authenticator => \&auth_cb;
        #'Auth::Form', authenticator => \&auth_cb;

        enable 'XIMSUILang';
        # bis es was besseres gibt…
        # enable "Auth::CAS" ;-)
        mount XIMS::CONTENTINTERFACE()        => builder {$goxims}; # /content
        mount XIMS::PERSONALINTERFACE()       => builder {$goxims}; # /user
        mount XIMS::USERMANAGEMENTINTERFACE() => builder {$goxims}; # /users
        mount '/userprefs'                    => builder {$goxims};
        mount '/bookmark'                     => builder {$goxims};
        mount '/defaultbookmark'              => builder {$goxims};
        mount '/search_intranet'              => builder {$goxims};
    };

    mount XIMS::GOPUBLIC() => builder {
        enable "XIMSAppContext";
        enable "Auth::XIMSPublicUser";
        enable 'XIMSUILang';
        # enable "Caching::Would::Be::Nice"

        mount XIMS::CONTENTINTERFACE() => builder {$goxims};
    };

    mount XIMS::GOBAXIMS() => builder {
        enable "XIMSAppContext";
        enable "Auth::Basic", authenticator => \&auth_cb;
        enable 'XIMSUILang';
        #enable "XIMS::Session"
        #$gobaxims;

        mount XIMS::CONTENTINTERFACE()        => builder {$goxims};
        mount XIMS::PERSONALINTERFACE()       => builder {$goxims};
        mount XIMS::USERMANAGEMENTINTERFACE() => builder {$goxims};
        mount '/userprefs'                    => builder {$goxims};
        mount '/bookmark'                     => builder {$goxims};
        mount '/defaultbookmark'              => builder {$goxims};
        mount '/search_intranet'              => builder {$goxims};
    };

    # WebDAV
    mount XIMS::GODAV() => $godav;

    # static files
    mount XIMS::XIMSROOT_URL()    =>  Plack::App::File->new( root => XIMS::XIMSROOT() );
    mount XIMS::PUBROOT_URL()     =>  Plack::App::File->new( root => XIMS::PUBROOT() );
};


sub auth_cb{
    my ($username, $password, $env) = @_;

    my $login = XIMS::Auth->new( Username => $username, Password => $password )->authenticate();
    return 0 unless defined $login;

    my $user = $login->getUserInfo();
    if ( $user and $user->id() ) {
        $env->{'xims.appcontext'}->session( XIMS::Session->new() );
        $env->{'xims.appcontext'}->session->user_id( $user->id() );
        $env->{'xims.appcontext'}->session->auth_module( ref($login) );
        return 1;
    }
    return 0;
}

sub getInterface {
    my $req = shift;

    my $script_name = $req->script_name();
    $script_name =~ s!.*/([^/]+)$!$1!;

    return $script_name;
}

=head2    getObject($req)

=head3 Parameter

    $req:    Plack::Request object      (mandatory)

=head3 Returns

    $retval: a XIMS::Object

=head3 Description

Watch out: language is hardcoded to de-at here!

=cut

sub getObject {
    my $req  = shift;
    my $user = $req->env->{'xims.appcontext'}->session->user();
    my %args;

    if ( $req and $user ) {
        my $pathinfo = $req->path();

        my $id = $req->param('id');
        if ( defined $id and $id > 0 ) {
            $args{id} = $id;
        }
        else {
            $args{path} = $pathinfo;
        }
        return XIMS::Object->new( %args, User => $user, language => 2);
    }

    return undef;
}



__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

=head1 BUGS AND LIMITATION

Language-preference handling does not comply to RFC 2616.

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

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

