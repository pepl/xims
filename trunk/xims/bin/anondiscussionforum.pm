# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package anondiscussionforum;

use strict;

use vars qw($VERSION @ISA);

use XIMS::CGI;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( folder );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # not yet reimplemented
    #$ctxt->properties->content->children->addinfo( 1 );

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_default( $ctxt );
}

# override SUPER::events
sub event_publish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

1;
