# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::DepartmentRoot;

use strict;
use vars qw( $VERSION @params @ISA);

use XIMS::CGI::Folder;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI::Folder );

sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          add_portlet
          rem_portlet
          )
        );
}

# parameters recognized by the script
@params = qw( id name title depid symid delforce del);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->expand_bodydeptinfo( $ctxt );
    $self->resolve_content( $ctxt, [ qw( STYLE_ID IMAGE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
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
