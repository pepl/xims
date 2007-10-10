# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::RefLibReferencePropertyMap;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

sub fields {
    return @Fields;
}

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

__PACKAGE__->mk_accessors( @Fields );

##
#
# SYNOPSIS
#    my $propertymap = XIMS::RefLibReferencePropertyMap->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id of an existing mapping.
#    $args{ property_id }         (optional) :  id of a RefLibReferenceProperty. To be used together with $args{reference_type_id} to look up an existing mapping.
#    $args{ reference_type_id }   (optional) :  id of a ReflibReference. To be used together with $args{property_id} to look up an existing mapping.
#
# RETURNS
#    $propertymap    : Instance of XIMS::RefLibAuthorMap
#
# DESCRIPTION
#    Fetches existing mappings or creates a new instance of XIMS::RefLibReferencePropertyMap.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{property_id}) and defined( $args{reference_type_id} ) ) ) {
            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get'.$rt;
            my $data = $self->data_provider->$method( %args );
            if ( defined( $data )) {
               $self->data( %{$data} );
            }
            else {
                return;
            }
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}

1;
