# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::defaultbookmark;

use strict;
use base qw( XIMS::CGI );
use XIMS::Object;
use Apache::URI();

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

sub selectStylesheet { return 1; };

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

# this is basically like an NPH script in that it returns no data
# to the client, but rather just redirects them to their default
# bookmark.
#
# we might consider moving this to a more generic
# redir-to-bookmark-and-fallback-to-default script, but...

sub event_init {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    # important! otherwise redirect will not work!
    $self->skipSerialization( 1 );

    $self->redirToDefault( $ctxt );

    XIMS::Debug( 5, "done");
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

##
#
# SYNOPSIS
#    redirToDefault($ctxt);
#
# PARAMETERS
#    $ctxt : appcontext object
#
# RETURNVALUES
#    none
#
# DESCRIPTION
#    redirect to the user's defaultbookmark unless a specific path is requested via path_info

sub redirToDefault {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $uri = Apache::URI->parse( $ctxt->apache );
    my $path = $uri->path();

    my $contentinterface = XIMS::CONTENTINTERFACE();
    if ( $path =~ 'defaultbookmark' or $path !~ /\Q$contentinterface\E/ ) {
        my $bookmark = $ctxt->session->user->default_bookmark();
        if ( $ctxt->session->user->default_bookmark ) {
            XIMS::Debug( 6, "bookmarked path: $bookmark" );
            $bookmark =  XIMS::Object->new( id => $bookmark->content_id() )->location_path();
        }
        else {
            # use fallback start path if user has got no bookmark set
            XIMS::Debug( 6, "using fallback start path" );
            $bookmark = XIMS::FALLBACKSTARTPATH();
        }

        $path = XIMS::GOXIMS() . $contentinterface . $bookmark;
        $uri->path($path);
    }

    # get rid of user login information in the querystring
    my $query = $uri->query();
    $query =~ s/userid|password//;
    $uri->query($query);

    XIMS::Debug( 6, "redirecting to " . $uri->unparse() );
    $self->redirect( $uri->unparse() );
    return 0;
}

1;
