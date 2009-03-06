# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::ContentIDPathResolver;

##
#
# GENERAL
# This SAX Filter expands an id or document_id to its corresponding location_path string.
# Note: This version does not touch the element name and therefore we got path-string in *_id elements!

use warnings;
use strict;

use XML::SAX::Base;
use XIMS::Object;

@XIMS::SAX::Filter::ContentIDPathResolver::ISA = qw(XML::SAX::Base);

sub new {
    my $class = shift;
    return $class->SUPER::new(@_);
}

sub start_element {
    my ($self, $element) = @_;

    if ( defined $element->{LocalName}
         and grep { /^$element->{LocalName}$/i } @{$self->{ResolveContent}} ) {
        $self->{got_to_resolve} = 1;
    }

    $self->SUPER::start_element($element);
}

sub end_element {
    my ($self, $element) = @_;

    if ( defined $self->{got_to_resolve} and defined $self->{document_id} and $self->{document_id} =~ /^[0-9]+$/ ) {
        # replace the document_id contained in the current element with the corresponding path
        my $id;
        if ( $element->{LocalName} eq 'document_id'
             or $element->{LocalName} eq 'department_id'
             or $element->{LocalName} eq 'parent_id'
             or $element->{LocalName} eq 'symname_to_doc_id' ) {
            $id = 'document_id';
        }
        else {
            $id = 'id';
        }
        my $path;
        if ( exists $self->{NonExport} ) {
            # Used for resolving document_ids in the management interface, like DepartmentRoot event edit for example
            $path = $self->{Provider}->location_path( $id => $self->{document_id} );
        }
        else {
            # Used to resolve the document_ids during exports
            my $object = XIMS::Object->new( $id => $self->{document_id} );
            if ( $object and $object->id() ) {
                if ( XIMS::RESOLVERELTOSITEROOTS() ) {
                    $path = $object->location_path_relative();
                }
                else {
                    $path = XIMS::PUBROOT_URL() . $object->location_path();
                }
            }
        }
        $self->SUPER::characters( { Data => $path } );
        $self->{document_id} = undef;
    }

    $self->{got_to_resolve} = undef;
    $self->SUPER::end_element(@_);
}

sub characters {
    my ( $self, $string ) = @_;

    if ( defined $string->{Data}
         and defined $self->{got_to_resolve}
         and $self->{got_to_resolve} == 1 ) {
        $self->{document_id} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
    }
}

1;