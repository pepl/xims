# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::ContentIDPathResolver;

##
# DESCRIPTION:
# This SAX Filter expands a content-id (major_id) to its corresponding path-string.
# Note: This version does not touch the element name and therefore we got path-string in *_id elements!

use warnings;
use strict;

use XML::SAX::Base;

@XIMS::SAX::Filter::ContentIDPathResolver::ISA = qw(XML::SAX::Base);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    if ( not exists $self->{RelToSite} ) {
        $self->{RelToSite} = XIMS::RESOLVERELTOSITEROOTS() eq '1' ? 1 : 0;
    }

    return $self;
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
        if ( $element->{LocalName} eq 'id' or $element->{LocalName} eq 'content_id' ) {
            $id = 'id';
        }
        else {
            $id = 'document_id';
        }
        my $path;
        if ( $self->{RelToSite} ) {
            # If you have symlinks from Apache's docroot to the corresponding objects below XIMS::PUBROOT_URL()
            # see Config.pm for more info
            $path = $self->{Provider}->location_path_relative( $id => $self->{document_id} );
        }
        elsif ( exists $self->{NonExport} ) {
            # Used for resolving document_ids in the management interface, like DepartmentRoot event edit for example
            $path = $self->{Provider}->location_path( $id => $self->{document_id} );
        }
        else {
            # Used to resolve the document_ids during exports
            $path = XIMS::PUBROOT_URL() . $self->{Provider}->location_path( $id => $self->{document_id} );
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
