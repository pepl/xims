# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::CSS;

use strict;
use base qw( XIMS::CGI::Text );
use CSS::Tiny;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub registerEvents {
    $_[0]->SUPER::registerEvents( qw( parse_css ) );
}

sub event_parse_css {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    my $body = $ctxt->object->body();
    my $css = CSS::Tiny->read_string( $body );
    if ( $CSS::Tiny::errstr ) {
        $ctxt->session->error_msg( "Parse failure" );
        $ctxt->session->verbose_msg( $CSS::Tiny::errstr );
    }
    else {
        $ctxt->session->message( "Parse ok. Parsed CSS:" );
        $ctxt->session->verbose_msg( $css->write_string() );
    }

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "message_window_plain" );

    return 0;
}

1;
