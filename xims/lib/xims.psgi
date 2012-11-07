
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


use XIMS;
use XIMS::AppContext;
use XIMS::DataProvider;
use XIMS::Object;
use XIMS::User;
use XIMS::Auth;
use XIMS::Session;


use Plack::Request;
use Plack::Builder;
use Plack::App::File;
use Plack::App::Directory;

use Time::Piece;

use Data::Dumper;

my $goxims = sub {
    my $env = shift;
    my $ctxt = $env->{'xims.appcontext'};

    XIMS::Debug( 5, $env->{script_name}. " called from " . $env->{REMOTE_ADDR} );

    # sprache einstellen

    # public user?


    # interface: user, users, content, bookmark, defaultbookmark, search_intranet
    # oder: not_found
    my $interface_type = getInterface($env);
    HTTP::Exception::404->throw unless $interface_type;

    if ($env->{SCRIPT_NAME} eq 'gopublic') {
        # /gopublic has no interface "user"
        if ( $interface_type eq 'user' ) {
            HTTP::Exception::404->throw();
        }
        # todo: set up session for public user
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

    # set UILanguage
    #$ctxt->session->uilanguage( $langpref );
    $ctxt->session->uilanguage( 'de-at' );
    #
    # Big fork here
    #

    my $app_class    = 'XIMS::CGI::';
    my $object_class = 'XIMS::';

    if ( $interface_type eq 'content' ) {

        # now we know, that we have to get the content-object
        $ctxt->object( getObject( $env ) );
        if ( not( $ctxt->object() and $ctxt->object->id() ) ) {

            # in this case we could pass the user to a more informative
            # page, where one can select the defaultbookmark!!

            # emulate default 404 log entry
     #       $r->log->warn(
     #           "File does not exist: " . $r->document_root() . $r->uri() );
           HTTP::Exception::404->throw();
       }

        my $ot_fullname = $ctxt->object->object_type->fullname();
        $object_class .= $ot_fullname;

        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ($@) {
            XIMS::Debug( 2, "could not load object class $object_class: $@" );
            # $r->custom_response( SERVER_ERROR,
            #                      XIMS::PUBROOT_URL()
            #                    . '/500.xsp?reason='
            #                    . uri_escape_utf8(
            #                        __x("Could not load object class {classname}.",
            #                            classname => $object_class,
            #                        )
            #                      )
            # );
            # return SERVER_ERROR;
            HTTP::Exception::500->throw();
        }

        ## use critic
        # rebless the object
        XIMS::Debug( 4, "reblessing object to " . $object_class );
        bless $ctxt->object(), $object_class;

        # find out if we want to create an object!
        # if goxims finds an 'objtype'-param it assumes that it
        # is called to create a new object.
        my %args    = $env->{args};
        my $objtype = $args{objtype};

        # my $objtype = $apr->param('objtype');
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

    # TODO: think of XIMS::REGISTEREDINTERFACES() here
    elsif ( $interface_type =~ /users?|bookmark|defaultbookmark|search_intranet/ ) {
        $app_class .= $interface_type;
        $ctxt->properties->application->styleprefix($interface_type);
    }
    else {
        HTTP::Exception::404->throw();
    }

    ##
    # end interface-lookup
    ##
    ## no critic (ProhibitStringyEval)
    eval "require $app_class";
    if ($@) {
        # XIMS::Debug( 2, "could not load application-class $app_class: $@" );
        # $r->custom_response( SERVER_ERROR,
        #                      XIMS::PUBROOT_URL()
        #                    . '/500.xsp?reason='
        #                    . uri_escape_utf8(
        #                        __x("Could not load application class {classname}.",
        #                            classname => $app_class,
        #                        )
        #                      )
        # );
        # return SERVER_ERROR;
        HTTP::Exception::500->throw();
    }
    ## use critic
    if ( my $appclass = $app_class->new() ) {
        XIMS::Debug( 4, "application-class $app_class initiated." );
        $appclass->setStylesheetDir( XIMS::XIMSROOT()
              . '/skins/'
              . $ctxt->session->skin
              . '/stylesheets/'
              . $ctxt->session->uilanguage() );
        my $rv = $appclass->run($ctxt);
        XIMS::Debug( 4, "application-class $app_class successfully run" ) if $rv;
        # return OK; 
        #print "boo!", Dumper($rv);
        #return [ 200, [ 'Content-Type' => 'text/plain' ], [ "Hello from " . $env->{SCRIPT_NAME} ." \n" . Dumper($env) ]];
        return $rv;
    }

    return [404, [ 'Content-Type' => 'text/plain' ], [ "B0rk from " . $env->{SCRIPT_NAME} ." \n" . Dumper($env)]];




    # eval require $app_class
    # instantiere $appclass
    # appclass run($env->{'xims.appcontext'});
      # ok
    # oder not_found;
    

   # return [ 200, [ 'Content-Type' => 'text/plain' ], [ "Hello from " . $env->{SCRIPT_NAME} ." \n" . Dumper($env) ] ];
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


# change to Plack::App::File for prod
my $ximsroot = Plack::App::File->new(root => "$ENV{XIMS_HOME}/www/ximsroot");
my $ximspubroot = Plack::App::File->new(root => "$ENV{XIMS_HOME}/www/ximspubroot");

builder {

    mount "/goxims" => builder {
        enable "Plack::Middleware::ErrorDocument",
            500 => '/ximspubroot/500.xsp',
            404 => '/ximspubroot/404.xsp',
            401 => '/ximspubroot/access.xsp',
            subrequest => 1;
        enable "XIMSAppContext";
        enable "Auth::Basic", authenticator => \&auth_cb; # bis es was besseres gibt…
        # enable "Auth::CAS";
        $goxims;
    };

    mount "/gopublic" => builder {
        enable "Plack::Middleware::ErrorDocument",
            500 => '/ximspubroot/500.xsp',
            404 => '/ximspubroot/404.xsp',
            401 => '/ximspubroot/access.xsp',
            subrequest => 1;
        enable "XIMSAppContext";
        # enable "Auth::PublicUser";
        # enable "Caching::Would::Be::Nice"
        $gopublic;
    };

    mount "/gobaxims" => builder {
        # enable "Plack::Middleware::ErrorDocument",
        #     500 => '/ximspubroot/500.xsp',
        #     404 => '/ximspubroot/404.xsp',
        #     401 => '/ximspubroot/access.xsp',
        #     subrequest => 1;
        enable "XIMSAppContext";
        enable "Auth::Basic", authenticator => \&auth_cb;
        #enable "XIMS::Session"
        $gobaxims;
    };

    # WebDAV
    mount "/godav" => $godav;

    # static files
    mount "/ximsroot" => $ximsroot;
};


sub auth_cb{
    my ($username, $password, $env) = @_;

    my $login = XIMS::Auth->new( Username => $username, Password => $password )->authenticate();
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
    my $env = shift;

    # check to see if we are editing managed content or seeking
    # one of the meta or admin interfaces
    my $interface_type;
    my $pathinfo = $env->{PATH_INFO};

    if ( $pathinfo =~ s/^(\/)(\w*)// ) {
        $interface_type = $2;
        XIMS::Debug( 6, "Using interface type: " . $interface_type );
    }
    elsif ( not length $pathinfo or $pathinfo eq "/" ) {

        # if the user only types in '/goxims' or '/goxims/' we don't want to
        # give a 404. instead we redirect to the default bookmark. i think
        # this is ok, since the users types in /goxims for login. through this
        # a user will have the chance to return to the page the system started
        # with.
        #
        # this should not happen, if one types in the interface name but
        # leaves a required path empty.
        #
        $interface_type = "user";
    }

    $env->{PATH_INFO}=($pathinfo);
    return $interface_type;
}

=head2    getObject($r)

=head3 Parameter

    $r:    request-object      (mandatory)

=head3 Returns

    $retval: object

=head3 Description

Watch out: language is hardcoded to de-at here!

=cut

sub getObject {
    my $env  = shift;
    my $user = $env->{'xims.appcontext'}->session->user();

    my $retval = undef;

    if ( $env and $user ) {
        my %id_or_path = ( language => 2 );    # de-at ... hardcode == nogood
        my $pathinfo = $env->{PATH_INFO} || '/';
        my %args     = $env->{args};
        my $id       = $args{id};
        if ( defined $id and $id > 0 ) {
            $id_or_path{id} = $id;
        }
        else {
            $id_or_path{path} = $pathinfo;
        }
        $retval = XIMS::Object->new( %id_or_path, User => $user );
    }

    return $retval;
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

