# Copyright (c) 2002-2003 The XIMS Project.
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
#use Data::Dumper;
use Time::Piece;
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
    XIMS::Debug( 1, "goxims called from " . $r->get_remote_host );

    #my $apr = Apache::Request->new($r);
    my $ctxt = XIMS::AppContext->new( apache => $r );
    
    $ctxt->properties->application->nocache( 1 );

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
        $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/access.xsp?reason=DataProvider%20could%20not%20be%20instantiated.%20There%20may%20be%20a%20database%20connection%20problem.");
        return SERVER_ERROR unless $ctxt->data_provider();

        XIMS::Debug(6, "Setting user to $publicuser");
        my $public = XIMS::User->new( name => $publicuser );
        my $session = XIMS::Session->new( 'user_id' => $public->id(),
                                          'host'    => $r->get_remote_host() );

        $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/access.xsp?reason=Could%20not%20create%20session.");
        return SERVER_ERROR unless ( $session and $ctxt->session( $session ) );
    }

    # set some session information
    my $tp = localtime;
    $ctxt->session->date( $tp->dmy('.') . ' ' . $tp->hms );
    my $uri = Apache::URI->parse( $r );
    $ctxt->session->serverurl( $uri->scheme . '://' . $uri->hostinfo() );

    # for now there is no user/browser based skin or ui-language selection. the default values are used.
    $ctxt->session->skin( XIMS::DEFAULT_SKIN() );
    $ctxt->session->uilanguage( XIMS::UIFALLBACKLANG() );

    # getting interface
    my $interface_type = getInterface( $r );
    return NOT_FOUND unless $interface_type;

    #
    # Big fork here
    #

    my ($app_pm, $cms_pm);

    if ( $interface_type eq 'content' ) {
        # now we know, that we have to get the content-object
        $ctxt->object( getObject( $r, $ctxt->session->user() ) );
        if ( not $ctxt->object->id() ) {
            # in this case we should pass the user to a more informative
            # page, where one can select the defaultbookmark!!
            XIMS::Debug( 2, "unable to get object from request" );
            return NOT_FOUND;
        }

        $cms_pm = "XIMS::" . $ctxt->object->object_type->name();

        # load the object class
        eval "require $cms_pm;" if $cms_pm;
        if (  $@ ) {
            XIMS::Debug( 2, "could not load object class $cms_pm: $@" );
            $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/access.xsp?reason=Could%20not%20load%20object%20class%20$cms_pm.");
            return SERVER_ERROR;
        }

        # rebless the object
        XIMS::Debug( 4, "reblessing object to " . $cms_pm );
        bless $ctxt->object(), $cms_pm;

        # find out if we want to create an object!
        # if goxims finds an 'objtype'-param it assumes that it
        # is called to create a new object. 
        my %args = $r->args();
        my $objtype = $args{objtype};
        # my $objtype = $apr->param('objtype');
        if ( defined $objtype and length $objtype ) {
            XIMS::Debug( 4, "we are creating a new $objtype" );
            $app_pm = lc( $objtype );
        }
        else {
            $app_pm = lc( $ctxt->object->object_type->name() );
        }
    }# end 'content' case
    else {
        $app_pm = $interface_type;
        $ctxt->properties->application->styleprefix( $interface_type );
    }

    ##
    # end interface-lookup
    ##

    eval "require $app_pm";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load application-class $app_pm: $@" );
        $r->custom_response(SERVER_ERROR, XIMS::PUBROOT_URL() . "/access.xsp?reason=Could%20not%20load%20application%20class%20$app_pm.");
        return SERVER_ERROR;
    }

    #instance the application class
    #if ( my $appclass = $app_pm->new( $r ) ) {
    if ( my $appclass = $app_pm->new() ) {
        XIMS::Debug( 4, "application-class $app_pm initiated." );
        $appclass->setStylesheetDir( XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/' . $ctxt->session->uilanguage() );
        my $rv = $appclass->run( $ctxt );
        XIMS::Debug( 4, "application-class $app_pm sucessfully run") if $rv;
        XIMS::Debug( 4, "goxims finished" );
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

    if ($pathinfo =~ s/^(\/)(content|users?|defaultbookmark)//) {
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
        $interface_type = "defaultbookmark";
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
        my $pathinfo = $r->path_info();
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

1;
