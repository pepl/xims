# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::Binary;

use XIMS::Importer::FileSystem;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem);

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location );

    my $data = $self->get_binref( $location );
    $object->body( $$data );

    return $object;
}

sub get_binref {
    my $self = shift;
    my $file = shift;
    open(FILE, $file) || die "could not open $file: $!";
    # switch off perls auto encoding
    binmode(FILE);
    while (read(FILE, my $buff, 16 * 2**10)) {
      $contents .= $buff;
    }
    close FILE;
    return \$contents
}
