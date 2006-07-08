# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::Attributes;

#
# This SAX Filter expands semicolon-separated key=value pairs to a nodeset.
#

use strict;
use base qw( XML::SAX::Base );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::SAX::Filter::Attributes->new();
#
# PARAMETERS
#    ?
#
# RETURNS
#    $self : a XIMS::SAX::Filter::Attributes instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}


##
#
# SYNOPSIS
#    $filter->start_element( $element );
#
# PARAMETERS
#    $element : hashref
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    none yet
#
sub start_element {
    my ($self, $element) = @_;

    if ( defined $element->{LocalName} and $element->{LocalName} eq 'attributes' ) {
        $self->{got_attributes} = 1;
    }

    $self->SUPER::start_element($element);
}


##
#
# SYNOPSIS
#    $filter->end_element( $element );
#
# PARAMETERS
#    $element :
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    none yet
#
sub end_element {
    my $self = shift;

    if ( defined $self->{got_attributes} and defined $self->{attributes} ) {
        my %attribs = ( $self->{attributes} =~ /([^;\=]+)\=([^\;]+)/g );
        foreach ( keys %attribs ) {
            $self->SUPER::start_element( { Name => $_, LocalName => $_, Prefix => "", NamespaceURI => undef, Attributes => {} } );
            $self->SUPER::characters( { Data => $attribs{$_} } );
            $self->SUPER::end_element();
        }

        $self->{attributes} = undef;
    }

    $self->{got_attributes} = undef;
    $self->SUPER::end_element(@_);
}


##
#
# SYNOPSIS
#    $filter->characters( $string );
#
# PARAMETERS
#    $string : hashref
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    none yet
#
sub characters {
    my ( $self, $string ) = @_;

    if ( defined $string->{Data} and defined $self->{got_attributes} ) {
        $self->{attributes} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
    }
}

1;
