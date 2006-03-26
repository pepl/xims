# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Exporter::VLibrary;

use strict;
use XIMS::Exporter;
use base qw( XIMS::Exporter::Folder );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    $self->{AppContext}->properties->content->childrenbybodyfilter( 1 );

    XIMS::Debug( 5, "done" );
    return $self->SUPER::create( @_ );
}

1;

