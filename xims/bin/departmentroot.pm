# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package departmentroot;

use strict;
use vars qw( $VERSION @params @ISA);

use folder;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

# the names of pushbuttons in forms or symbolic internal handler
# each application should register the events required, even if they are
# defined in XIMS::CGI. This should be, so a programmer has the chance to
# deny certain events for his script.
#
# only dbhpanic and access_denied are set by XIMS::CGI itself.
sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          add_portlet
          rem_portlet
          cancel
          test_wellformedness
          )
        );
}

# parameters recognized by the script
@params = qw( id parid name title depid symid delforce del);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $ctxt->properties->content->getformatsandtypes( 1 );

    return 0;
}

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $self->expand_attributes( $ctxt );
    $self->expand_bodydeptinfo( $ctxt );
    $self->resolve_content( $ctxt, [ qw( STYLE_ID IMAGE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}


sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();
    my $autoindex  = $self->param( 'autoindex' );
    if ( defined $autoindex ) {
        XIMS::Debug( 6, "autoindex: $autoindex" );
        if ( $autoindex eq 'true' ) {
            $object->attribute( autoindex => '1' );
        }
        elsif ( $autoindex eq 'false' ) {
            $object->attribute( autoindex => '0' );
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

# hmmm, really needed?
sub event_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return $self->event_edit( $ctxt );
}

sub event_add_portlet {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $path = $self->param( "portlet" );
    if ( defined $path ) {
        if ( not ($object->add_portlet( $path ) and $object->update() ) ) {
            $self->sendError( $ctxt, "Could not add portlet." );
            return 0;
        }
    }
    else {
        $self->sendError( $ctxt, "Path to portlet-target needed." );
        return 0;
    }

    return $self->event_edit( $ctxt );
}

sub event_rem_portlet {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $portlet_id = $self->param( "portlet_id" );
    if ( defined $portlet_id and $portlet_id > 0 ) {
        if ( not ( $object->remove_portlet( $portlet_id ) and $object->update() ) ) {
            $self->sendError( $ctxt, "Could not remove portlet." );
            return 0;
        }
    }
    else {
        $self->sendError( $ctxt, "Which portlet should be removed?" );
        return 0;
    }

    return $self->event_edit( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

sub expand_bodydeptinfo {
    my $self = shift;
    my $ctxt = shift;

    eval "require XIMS::SAX::Filter::DepartmentExpander;";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load department-expander: $@" );
        return 0;
    }
    my $filter = XIMS::SAX::Filter::DepartmentExpander->new( Object   => $ctxt->object(),
                                                             User     => $ctxt->session->user(), );
    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
    push @{$ctxt->sax_filter()}, $filter;
}

1;
