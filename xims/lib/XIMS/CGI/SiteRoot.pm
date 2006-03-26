# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::SiteRoot;

use strict;
use base qw( XIMS::CGI::DepartmentRoot );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# RUNTIME EVENTS

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # we do not want to touch the provided location and are trusting the admins who are creating siteroots to provide a
    # valid DNS name here
    $ctxt->properties->application->preservelocation( 1 );
    return $self->SUPER::event_store( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################
1;
