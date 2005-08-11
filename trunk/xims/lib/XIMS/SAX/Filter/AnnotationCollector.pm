# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::AnnotationCollector;

use XML::SAX::Base;
use XML::Generator::PerlData;

use vars qw(@ISA);

@ISA = qw( XML::SAX::Base );

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
