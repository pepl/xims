# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package urllink;

use strict;
use vars qw( $VERSION @ISA );

use XIMS::CGI;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( XIMS::CGI );

# the names of pushbuttons in forms or symbolic internal handler
# each application should register the events required, even if they are
# defined in XIMS::CGI. This is for having a chance to
# deny certain events for the script.
#
# only dbhpanic and access_denied are set by XIMS::CGI itself.
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
                                 qw(
                                    create
                                    edit
                                    store
                                    delete
                                    delete_prompt
                                    publish
                                    publish_prompt
                                    unpublish
                                    obj_acllist
                                    obj_aclgrant
                                    obj_aclrevoke
                                    cancel
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
