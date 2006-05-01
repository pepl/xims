# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::Text;

use strict;
use base qw( XIMS::Importer::FileSystem::Binary );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location );

    my $data = $self->get_binref( $location );
    $object->body( XIMS::xml_escape( $$data ) );

    return $object;
}

1;
