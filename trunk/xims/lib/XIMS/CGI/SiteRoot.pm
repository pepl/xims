# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::SiteRoot;

use strict;
use vars qw($VERSION @ISA);

use XIMS::CGI::DepartmentRoot;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::CGI::DepartmentRoot );

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
