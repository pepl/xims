# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibPublicationMap;

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

#
# SYNOPSIS
#    my $pubmap = XIMS::VLibPublicationMap->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id of an existing mapping.
#    $args{ document_id }         (optional) :  document_id of a VLibraryItem. To be used together with $args{publication_id} to look up an existing mapping.
#    $args{ publication_id }      (optional) :  id of a VLibPublication. To be used together with $args{document_id} to look up an existing mapping.
#
# RETURNS
#    $pubmap    : Instance of XIMS::VLibPublicationMap
#
# DESCRIPTION
#    Fetches existing mappings or creates a new instance of XIMS::VLibPublicationMap for VLibraryItem <-> VLibPublication mapping.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{document_id}) and defined( $args{publication_id} ) ) ) {
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
