# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::Text;

use XIMS::Importer::FileSystem::Binary;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem::Binary);

use XIMS;

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
