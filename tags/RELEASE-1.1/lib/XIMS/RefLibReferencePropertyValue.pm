# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::RefLibReferencePropertyValue;

use strict;
use base qw( XIMS::AbstractClass );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields;

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names( resource_type() )};
}

use Class::MethodMaker
        get_set       => \@Fields;

##
#
# SYNOPSIS
#    my $reflibreferencepropertyvalue = XIMS::RefLibReferencePropertyValue->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id.
#    $args{ property_id }         (optional) :  property_id of the RefLibReferencePropertyValue, to be used together with reference_id.
#    $args{ reference_id }        (optional) :  reference_id of the RefLibReferencePropertyValue, to be used together with property_id.
#
# RETURNS
#    $reflibreferencepropertyvalue    : Instance of XIMS::RefLibReferencePropertyValue
#
# DESCRIPTION
#    Fetches existing property values or creates a new instance of XIMS::RefLibReferencePropertyValue.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{property_id} ) and defined( $args{reference_id} ) ) ) {
            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get'.$rt;
            my $data = $self->data_provider->$method( %args );
            if ( defined( $data )) {
               $self->data( %{$data} );
            }
            else {
                return undef;
            }
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}

1;
