# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Exporter::Text;

use strict;
use XIMS::Exporter;
use base qw( XIMS::Exporter::Binary );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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
        return;
    }

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );

    return 1;
}


1;

