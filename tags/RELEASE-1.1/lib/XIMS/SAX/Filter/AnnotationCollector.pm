# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::AnnotationCollector;

use strict;
use base qw( XML::SAX::Base );
use XML::Generator::PerlData;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub end_element {
    my $self = shift;
    my $elem = shift;

    if ( $elem->{LocalName} eq "children" ) {
        my $object  = $self->{Object};
        my @objects = $object->descendants_granted( User => $object->User,
                                                    object_type_id => [ XIMS::ObjectType->new( name => 'Annotation' )->id() ] );

        if ( @objects and scalar @objects ) {
            XIMS::Debug( 6, "found " . scalar( @objects ) );
            my $generator = XML::Generator::PerlData->new( Handler => $self->{Handler} );
            $generator->attrmap( {object => ['id', 'document_id', 'parent_id', 'level']} );
            $generator->parse_chunk( {object => [@objects]} );
        }
        else {
            XIMS::Debug( 4, "no annotations found" );
        }
    }

    $self->SUPER::end_element( $elem );
}

1;
