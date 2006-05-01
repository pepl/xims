# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::Binary;

use strict;
use base qw( XIMS::Importer::FileSystem );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location );

    my $data = $self->get_binref( $location );
    $object->body( $$data );
    undef $data;

    return $object;
}

sub get_binref {
    my $self = shift;
    my $file = shift;
    open(FILE, $file) || die "could not open $file: $!";
    # switch off perls auto encoding
    binmode(FILE);
    my $contents;
    while (read(FILE, my $buff, 16 * 2**10)) {
      $contents .= $buff;
    }
    close FILE;
    return \$contents
}
