# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::NewsItem;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::Document;
use XIMS::Importer::Object;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Document');

sub add_image {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $img_object = shift;

    my $obj_importer = XIMS::Importer::Object->new( User => $img_object->User(), Parent => $img_object->parent() );
    my $id = $obj_importer->import( $img_object );
    if ( defined( $id ) ) {
        $self->image_id( $id );
    }
    else {
        XIMS::Debug( 3, "could not create new image object. Perhaps it already exists." );
    }
    return 1;
}

1;
