# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package newsitem;

use strict;
use vars qw( $VERSION @ISA );

use document;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( document );

sub event_default {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # replace image id with image path
    $self->resolve_content( $ctxt, [ qw( IMAGE_ID ) ] );

    return $self->SUPER::event_default( $ctxt );
}

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $self->resolve_content( $ctxt, [ qw( IMAGE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

1;
