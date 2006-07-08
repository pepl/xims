# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::sDocBookXML;

use strict;
use base qw( XIMS::CGI::Document );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    $ctxt->properties->application->style( "create" );

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $ctxt->properties->content->escapebody( 1 );

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    $ctxt->properties->application->style( "edit" );
    return 0;
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->SUPER::event_exit( $ctxt );
    $ctxt->properties->content->escapebody( 0 ) unless $self->testEvent(); # do not escape body for event_default

    return 0;
}


1;