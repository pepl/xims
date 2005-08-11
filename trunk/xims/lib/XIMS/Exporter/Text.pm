# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Exporter::Text;

use strict;
use XIMS::Exporter;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Binary );

sub create {
    XIMS::Debug( 5, "called" );

    my ( $self, %param ) = @_;
    my $document_path =  $self->{Exportfile} || $self->{Basedir} . '/' . $self->{Object}->location;

    XIMS::Debug( 4, "trying to write the object to $document_path" );

    # create the item on disk
    my $document_fh = IO::File->new( $document_path, 'w' );
    if ( defined $document_fh ) {
        print $document_fh XIMS::xml_unescape( $self->{Object}->body() );
        $document_fh->close;
        XIMS::Debug( 4, "document written" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$document_path': $!" );
        return undef;
    }

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );

    return 1;
}


1;

