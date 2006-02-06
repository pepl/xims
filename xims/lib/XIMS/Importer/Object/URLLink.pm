# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::URLLink;

use XIMS::Importer::Object;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::Object);

sub check_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    return $location;
}


1;
