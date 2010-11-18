
=head1 NAME

goxims -- XIMS' main mod_perl handler

=head1 VERSION

$Id$

=head1 SYNOPSIS

    SetHandler  perl-script
    PerlHandler goxims

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package goxims;
use Apache::Constants qw(:common);
use strict;
use Apache;
use Apache::Request;
use Apache::URI;
use XIMS;
use XIMS::AppContext;
use XIMS::DataProvider;
use XIMS::Object;
use XIMS::User;
use XIMS::Session;
use Apache::AuthXIMS;
use Time::Piece;
use POSIX qw(setlocale LC_ALL);

# preload commonly used and publish_gopublic objecttypes
use XIMS::CGI::SiteRoot;
use XIMS::CGI::DepartmentRoot;
use XIMS::CGI::Document;
use XIMS::CGI::Portlet;
use XIMS::CGI::Questionnaire;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

#use Data::Dumper;
#use Time::HiRes;

=head2 handler

=head3 Parameter

    none

=head3 Returns

'SERVER_ERROR', 'NOT_FOUND', 'FORBIDDEN', or 'OK'.

=head3 Description

none yet

=cut

sub handler {
    my $r = shift;

    #$XIMS::T0 = [Time::HiRes::gettimeofday()];

    XIMS::via_proxy_test($r) unless $r->pnotes('PROXY_TEST');
    XIMS::Debug( 5, "goxims called from " . $r->connection->remote_ip() );

    #my $apr = Apache::Request->new($r);
    my $ctxt = XIMS::AppContext->new( apache => $r );

    # set default 500 error document
    $r->custom_response( SERVER_ERROR, XIMS::PUBROOT_URL() . "/500.xsp" );

    my $langpref = getLanguagePref($r);

    # XXX temporary solution
    if ( $langpref eq 'de-at' ) {
        setlocale( LC_ALL, "de_AT.UTF-8" );
    }
    else {
        setlocale( LC_ALL, "en_US.UTF-8" );
    }

    my $publicuser = $r->dir_config('ximsPublicUserName');

    # getting interface
    my $interface_type = getInterface($r);
    return NOT_FOUND unless $interface_type;

    # The public user should not have the interface 'user'
    if ( $interface_type eq 'user' and $publicuser ) {
        return NOT_FOUND;
    }

    if ( not $publicuser ) {

        # we are coming in via /goxims
        my $sessioninfo = readNotes($r);

        if ( defined $sessioninfo->{session}
            and $sessioninfo->{session}->user->id() ==
            XIMS::Config::PublicUserID() )
        {

            # Drop session if the public user is not coming in via /gopublic...
            $sessioninfo->{session}->delete();
            return FORBIDDEN;
        }

        # if we have a cookiestring, we'll set it to the context
        if ( defined $sessioninfo->{cookie} and length $sessioninfo->{cookie} )
        {
            $ctxt->cookie( $sessioninfo->{cookie} );
        }

        return SERVER_ERROR
          unless ( $sessioninfo->{provider}
            and $ctxt->data_provider( $sessioninfo->{provider} ) );
        return SERVER_ERROR
          unless ( $sessioninfo->{session}
            and $ctxt->session( $sessioninfo->{session} ) );
    }
    else {

        # using the ximsPublic role
        unless ( $ctxt->data_provider() ) {
            $r->custom_response( SERVER_ERROR,
                XIMS::PUBROOT_URL()
                  . "/500.xsp?reason=A%20database%20connection%20problem%20occured."
            );
            return SERVER_ERROR;
        }

        XIMS::Debug( 6, "setting user to $publicuser" );
        my $sessionid = Apache::AuthXIMS::get_session_cookie($r);
        my $session;
        my $public = XIMS::User->new( name => $publicuser );
        if ( defined $sessionid and length $sessionid ) {
            $session = XIMS::Session->new( session_id => $sessionid );
            if ( defined $session ) {
                XIMS::Debug( 4,
                    "found existing session cookie, user already logged in" );

                # fake session user's id to public user's id, so that
                # actions happen in the context of the public user and
                # the currently logged-in user does not need to logout
                # while coming in via /gopublic/
                $session->user_id( $public->id() );
            }
        }

        if ( not defined $session ) {
            $session = XIMS::Session->new(
                'user_id' => $public->id(),
                'host'    => $r->connection->remote_ip()
            );
            XIMS::Debug( 4, "setting session cookie for $publicuser" );
            Apache::AuthXIMS::set_session_cookie( $r, $session->session_id() );
        }

        unless ( $session and $ctxt->session($session) ) {
            $r->custom_response( SERVER_ERROR,
                XIMS::PUBROOT_URL()
                  . "/500.xsp?reason=Could%20not%20create%20session." );
            return SERVER_ERROR;
        }
    }

    # set some session information
    my $tp = localtime;
    $ctxt->session->date( $tp->ymd() . ' ' . $tp->hms() );

    my $serverurl = XIMS::get_server_url( $r );
    XIMS::Debug( 6, "setting serverurl to $serverurl" );
    $ctxt->session->serverurl( $serverurl );

    # now we have a user based skin selection.
    #$ctxt->session->skin( XIMS::DEFAULT_SKIN() );
    if($ctxt->session->user->userprefs){
    	$ctxt->session->skin( $ctxt->session->user->userprefs->skin());
    }
    else{
    	$ctxt->session->skin(XIMS::DEFAULT_SKIN() );
    }

    # set UILanguage
    $ctxt->session->uilanguage( $langpref );

    #
    # Big fork here
    #

    my $app_class    = 'XIMS::CGI::';
    my $object_class = 'XIMS::';

    if ( $interface_type eq 'content' ) {

        # now we know, that we have to get the content-object
        $ctxt->object( getObject( $r, $ctxt->session->user() ) );
        if ( not( $ctxt->object() and $ctxt->object->id() ) ) {

            # in this case we could pass the user to a more informative
            # page, where one can select the defaultbookmark!!

            # emulate default 404 log entry
            $r->log->warn(
                "File does not exist: " . $r->document_root() . $r->uri() );
            return NOT_FOUND;
        }

        my $ot_fullname = $ctxt->object->object_type->fullname();
        $object_class .= $ot_fullname;

        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ($@) {
            XIMS::Debug( 2, "could not load object class $object_class: $@" );
            $r->custom_response( SERVER_ERROR,
                XIMS::PUBROOT_URL()
                  . "/500.xsp?reason=Could%20not%20load%20object%20class%20$object_class."
            );
            return SERVER_ERROR;
        }
        ## use critic
        # rebless the object
        XIMS::Debug( 4, "reblessing object to " . $object_class );
        bless $ctxt->object(), $object_class;

        # find out if we want to create an object!
        # if goxims finds an 'objtype'-param it assumes that it
        # is called to create a new object.
        my %args    = $r->args();
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
        return NOT_FOUND;
    }

    ##
    # end interface-lookup
    ##
    ## no critic (ProhibitStringyEval)
    eval "require $app_class";
    if ($@) {
        XIMS::Debug( 2, "could not load application-class $app_class: $@" );
        $r->custom_response( SERVER_ERROR,
            XIMS::PUBROOT_URL()
              . "/500.xsp?reason=Could%20not%20load%20application%20class%20$app_class."
        );
        return SERVER_ERROR;
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
        XIMS::Debug( 4, "application-class $app_class successfully run" )
          if $rv;
        return OK;
    }

    return NOT_FOUND;
}

=head2    readNotes($r);

=head3 Parameter

    $r: request-object

=head3 Returns

     $retval: hash-ref of notes, keys: 'session', 'provider'

=head3 Description

Fetches values of a couple of named entries in the Apache "pnotes" table.
Namely values of 'ximsSession' and 'ximsProvider' are read, provided they
exist.

=cut

sub readNotes {
    my $r      = shift;
    my $retval = {};

    # Authentication modules have to set the session and user id. goxims
    # simply requests that information from the server and because
    # authentication has already finished at this stage, no extra session or
    # user validation is neccesary.

    if ($r) {
        $retval->{session}  = $r->pnotes('ximsSession');
        $retval->{provider} = $r->pnotes('ximsProvider');
    }
    else {
        XIMS::Debug( 2, "no request found" );
    }

    return $retval;
}

=head2    getInterface($r)

=head3 Parameter

    $r:    request-object      (mandatory)

=head3 Returns

    $retval: $interface_type

=head3 Description

Snip the context (first level URI path step) from the request string to
determine what type of interface we are loading.

=cut

sub getInterface {
    my $r = shift;

    # check to see if we are editing managed content or seeking
    # one of the meta or admin interfaces
    my $interface_type;
    my $pathinfo = $r->path_info();

    if ( $pathinfo =~ s/^(\/)(\w*)// ) {
        $interface_type = $2;
        XIMS::Debug( 6, "Using interface type: " . $interface_type );
    }
    elsif ( not length $pathinfo or $pathinfo eq "/" ) {

        #
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

    $r->path_info($pathinfo);
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
    my $r    = shift;
    my $user = shift;

    my $retval = undef;

    if ( $r and $user ) {
        my %id_or_path = ( language => 2 );    # de-at ... hardcode == nogood
        my $pathinfo = $r->path_info() || '/';
        my %args     = $r->args();
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

=head2    getLanguagePref($r)

=head3 Parameter

    $r:    request-object      (mandatory)

=head3 Returns

    $retval: interface language (string)

=head3 Description

loose implementation of what is described in:
http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4

=cut

sub getLanguagePref {
    my $r       = shift;
    my $langrex = qr/(\w{1,8}(?:-\w{1,8})?)(?:;q=([0|1](?:\.\d{1,3})?))?/;
    my %langprefs;
    my %havelangs = XIMS::UILANGUAGES();

    # parse Header
    foreach my $pref_field ( split( /,/, $r->header_in("Accept-Language") ) ) {
        my $qvalue;
        $pref_field =~ $langrex;
        $qvalue = $2 or $qvalue = "1";
        push @{ $langprefs{$qvalue} }, $1;
    }

    # compare
    foreach my $wantlang ( reverse sort keys(%langprefs) ) {
        foreach my $langpref ( keys %havelangs ) {
            map { $_ =~ $havelangs{$langpref} ? return $langpref : next; }
              @{ $langprefs{$wantlang} };
        }
    }

    return XIMS::UIFALLBACKLANG();
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

=head1 BUGS AND LIMITATION

Language-preference handling does not comply to RFC 2616.

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2009 The XIMS Project.

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

