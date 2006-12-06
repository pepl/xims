# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::URLLink;

use strict;
use base qw( XIMS::CGI );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
                                 qw(
                                    create
                                    edit
                                    store
                                    publish
                                    publish_prompt
                                    unpublish
                                    obj_acllist
                                    obj_aclgrant
                                    obj_aclrevoke
                                   )
                                );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # this handles absolute URLs only for now
    $self->redirect( $ctxt->object->location() );

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    # check URL;
    $ctxt->object->check();
    $ctxt->properties->application->preservelocation( 1 );

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    return $self->SUPER::event_store( $ctxt );
}

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;

    $ctxt->session->warning_msg( "URLLink objects are only FLAGGED published!" );

    $self->SUPER::event_publish_prompt( $ctxt );

    return 0;
}

sub event_exit {
    my ( $self, $ctxt ) = @_;

    $self->resolve_content( $ctxt, [ qw( SYMNAME_TO_DOC_ID ) ] );

    return $self->SUPER::event_exit( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

1;
