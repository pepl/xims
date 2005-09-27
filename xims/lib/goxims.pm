# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
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

# preload commonly used and publish_gopublic objecttypes
use XIMS::CGI::SiteRoot;
use XIMS::CGI::DepartmentRoot;
use XIMS::CGI::Document;
use XIMS::CGI::Portlet;
use XIMS::CGI::Questionnaire;
use XIMS::CGI::AnonDiscussionForum;
use XIMS::CGI::AnonDiscussionForumContrib;

#use Data::Dumper;
#use Time::HiRes;

##
#
# SYNOPSIS
#    handler();
#
# PARAMETERS
#    none
#
# RETURNVALUES
#    none
#
# DESCRIPTION
#    none yet
#
sub handler {
    my $r = shift;

    #$XIMS::T0 = [Time::HiRes::gettimeofday()];

    XIMS::via_proxy_test($r) unless $r->pnotes('PROXY_TEST');
    XIMS::Debug( 5, "goxims called from " .  $r->connection->remote_ip() );

    #my $apr = Apache::Request->new($r);
    my $ctxt = XIMS::AppContext->new( apache => $r );

    # set default 500 error document
    $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/500.xsp");

    my $publicuser = $r->dir_config('ximsPublicUserName');
    if ( not $publicuser ) {
        # we have non-public authentification
        my $sessioninfo = readNotes( $r );

        # if we have a cookiestring, we'll set it to the context
        if ( defined $sessioninfo->{cookie} and length $sessioninfo->{cookie} ) {
            $ctxt->cookie( $sessioninfo->{cookie} );
        }

        return SERVER_ERROR unless ( $sessioninfo->{provider} and $ctxt->data_provider( $sessioninfo->{provider} ) );
        return SERVER_ERROR unless ( $sessioninfo->{session} and $ctxt->session( $sessioninfo->{session} ) );
    }
    else {
        # using the ximsPublic role
        unless ( $ctxt->data_provider() ) {
            $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/500.xsp?reason=A%20database%20connection%20problem%20occured.");
            return SERVER_ERROR;
        }

        XIMS::Debug( 6, "setting user to $publicuser" );
        my $sessionid  = Apache::AuthXIMS::get_session_cookie( $r );
        my $session;
        my $public = XIMS::User->new( name => $publicuser );
        if ( defined $sessionid and length $sessionid ) {
            $session = XIMS::Session->new( session_id => $sessionid );
            if ( defined $session ) {
                XIMS::Debug( 4, "found existing session cookie, user already logged in" );
                # fake session user's id to public user's id, so that actions happen in the context of the
                # public user and the currently logged-in user does not need to logout while coming in via /gopublic/
                $session->user_id( $public->id() );
            }
        }

        if ( not defined $session ) {
            $session = XIMS::Session->new( 'user_id' => $public->id(),
                                           'host'    => $r->connection->remote_ip() );
            XIMS::Debug( 4, "setting session cookie for $publicuser" );
            Apache::AuthXIMS::set_session_cookie( $r, $session->session_id() );
        }

        unless ( $session and $ctxt->session( $session ) ) {
            $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/500.xsp?reason=Could%20not%20create%20session.");
            return SERVER_ERROR;
        }
    }

    # set some session information
    my $tp = localtime;
    $ctxt->session->date( $tp->ymd() . ' ' . $tp->hms() );

    # test if we are called through a proxy, set serverurl accordingly
    my $uri = Apache::URI->parse( $r );
    my $hostname = length $r->headers_in->{'X-Forwarded-Host'}?$r->headers_in->{'X-Forwarded-Host'}:$uri->hostinfo();
    XIMS::Debug( 6, "setting serverurl to $hostname" );
    $ctxt->session->serverurl( $uri->scheme . '://' . $hostname);

    # for now there is no user/browser based skin selection. the default values are used.
    $ctxt->session->skin( XIMS::DEFAULT_SKIN() );

    # set UILanguage
    $ctxt->session->uilanguage( getLanguagePref($r) );

    # getting interface
    my $interface_type = getInterface( $r );
    return NOT_FOUND unless $interface_type;
    # The public user should not have the interface 'user'
    if ( $interface_type eq 'user' and $publicuser ) {
        return NOT_FOUND;
    }

    #
    # Big fork here
    #

    my $app_class = 'XIMS::CGI::';
    my $object_class = 'XIMS::';

    if ( $interface_type eq 'content' ) {
        # now we know, that we have to get the content-object
        $ctxt->object( getObject( $r, $ctxt->session->user() ) );
        if ( not ($ctxt->object() and $ctxt->object->id()) ) {
            # in this case we could pass the user to a more informative
            # page, where one can select the defaultbookmark!!

            # emulate default 404 log entry
            $r->log->warn("File does not exist: " . $r->document_root() . $r->uri());
            return NOT_FOUND;
        }

        my $ot_fullname = $ctxt->object->object_type->fullname();
        $object_class .= $ot_fullname;

        # load the object class
        eval "require $object_class;" if $object_class;
        if ( $@ ) {
            XIMS::Debug( 2, "could not load object class $object_class: $@" );
            $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/500.xsp?reason=Could%20not%20load%20object%20class%20$object_class.");
            return SERVER_ERROR;
        }

        # rebless the object
        XIMS::Debug( 4, "reblessing object to " . $object_class );
        bless $ctxt->object(), $object_class;

        # find out if we want to create an object!
        # if goxims finds an 'objtype'-param it assumes that it
        # is called to create a new object.
        my %args = $r->args();
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
        $ctxt->properties->application->styleprefix( $prefix );
    }# end 'content' case
    # think of XIMS::REGISTEREDINTERFACES() here
    elsif ( $interface_type =~ /users?|bookmark|defaultbookmark/ ) {
        $app_class .= $interface_type;
        $ctxt->properties->application->styleprefix( $interface_type );
    }
    else {
        return NOT_FOUND;
    }

    ##
    # end interface-lookup
    ##

    eval "require $app_class";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load application-class $app_class: $@" );
        $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/access.xsp?reason=Could%20not%20load%20application%20class%20$app_class.");
        return SERVER_ERROR;
    }

    if ( my $appclass = $app_class->new() ) {
        XIMS::Debug( 4, "application-class $app_class initiated." );
        $appclass->setStylesheetDir( XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/' . $ctxt->session->uilanguage() );
        my $rv = $appclass->run( $ctxt );
        XIMS::Debug( 4, "application-class $app_class successfully run") if $rv;
        return OK;
    }

    return NOT_FOUND;
}


##
#
# SYNOPSIS
#    readNotes($r);
#
# PARAMETERS
#    $r: request-object
#
# RETURNVALUES
#     $retval: hash-ref of notes, keys: 'session', 'provider'
#
# DESCRIPTION
#    Fetches values of a couple of named entries in the Apache "pnotes" table.
#    Namely values of 'ximsSession' and 'ximsProvider' are read,
#    provided they exist.
#
sub readNotes {
    my $r = shift;
    my $retval = {};

    # Authentication modules have to set the session and user id.
    # goxims simply requests that information from the server and because
    # authentication has already finished at this stage, no extra session
    # or user validation is neccesary.

    if ( $r ) {
        $retval->{session}    =  $r->pnotes( 'ximsSession' );
        $retval->{provider}   =  $r->pnotes( 'ximsProvider' );
    }
    else {
        XIMS::Debug( 2, "no request found" );
    }

    return $retval;
}

##
#
# SYNOPSIS
#    getInterface($r)
#
# PARAMETERS
#    $r:    request-object      (mandatory)
#
# RETURN VALUES
#    $retval: $interface_type
#
# DESCRIPTION
#    Snip the context (first level URI path step) from the request string to determine
#    what type of interface we are loading.
#
sub getInterface {
    my $r = shift;
    # check to see if we are editing managed content or seeking
    # one of the meta or admin interfaces
    my $interface_type;
    my $pathinfo = $r->path_info();

    if ($pathinfo =~ s/^(\/)(\w*)//) {
        $interface_type = $2;
        XIMS::Debug(6, "Using interface type: " . $interface_type )
    }
    elsif ( not length $pathinfo or $pathinfo eq "/") {
        #
        # if the user only types in '/goxims' or '/goxims/' we don't
        # want to give a 404. instead we redirect to the default bookmark.
        # i think this is ok, since the users types in /goxims for login.
        # through this a user will have the chance to return to the page
        # the system started with.
        #
        # this should not happen, if one types in the interface name but
        # leaves a required path empty.
        #
        $interface_type = "user";
    }

    $r->path_info($pathinfo);
    return $interface_type;
}

##
#
# SYNOPSIS
#    getObject($r)
#
# PARAMETERS
#    $r:    request-object      (mandatory)
#
# RETURNVALUES
#    $retval: object
#
# DESCRIPTION
#    Watch out: language is hardcoded to de-at here!
#
sub getObject {
    my $r = shift;
    my $user = shift;

    my $retval = undef;

    if ( $r and $user ) {
        my %id_or_path = ( language => 2 ); # de-at ... hardcode == nogood
        my $pathinfo = $r->path_info() || '/';
        my %args = $r->args();
        my $id = $args{id};
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


##
#
# SYNOPSIS
#    getLanguage($r)
#
# PARAMETERS
#    $r:    request-object      (mandatory)
#
# RETURN VALUES
#    $retval: interface language (string)
#
# DESCRIPTION
#    loose implementation of what is described in:
#    http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
#
sub getLanguagePref {
    my $r = shift;
    my $langrex = qr/(\w{1,8}(?:-\w{1,8})?)(?:;q=([0|1](?:\.\d{1,3})?))?/;
    my %langprefs;
    my %havelangs = XIMS::UILANGUAGES();

    # parse Header
    foreach my $pref_field (split(/,/, $r->header_in( "Accept-Language" ))) {
        my $qvalue;
        $pref_field =~ $langrex;
        $qvalue = $2 or $qvalue = "1";
        push @{$langprefs{$qvalue}}, $1;
    }

    # compare
    foreach my $wantlang (reverse sort keys(%langprefs)) {
        foreach my $langpref ( keys %havelangs ) {
            map { $_ =~ $havelangs{$langpref} ? return $langpref : next;} @{$langprefs{$wantlang}};
        }
    }

    return XIMS::UIFALLBACKLANG();
}

1;
