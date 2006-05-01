# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::URLLink;

use strict;
use base qw( XIMS::Importer::Object );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub check_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    return $location;
}


1;
