# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::Portal;

use strict;
use base qw( XIMS::CGI::Folder );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( SYMNAME_TO_DOC_ID ) ] );

    return $self->SUPER::event_default( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

1;
