# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id $
package docbookxml;

use strict;
use vars qw( $VERSION @ISA);
use xml;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( xml );

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->SUPER::event_exit( $ctxt );
    $ctxt->properties->content->escapebody( 0 ) unless $self->testEvent(); # do not escape body for event_default

    return 0;
}


1;