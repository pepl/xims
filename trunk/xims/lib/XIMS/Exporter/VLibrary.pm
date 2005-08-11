# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Exporter::VLibrary;

use strict;
use XIMS::Exporter;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Folder );




sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    $self->{AppContext}->properties->content->childrenbybodyfilter( 1 );

    XIMS::Debug( 5, "done" );
    return $self->SUPER::create( @_ );
}

1;

