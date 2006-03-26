# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibPublication;

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
#    my $publication = XIMS::VLibPublication->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id of an existing publication.
#    $args{ name }                (optional) :  name of a VLibPublication. To be used together with $args{volume} to look up an existing publication.
#    $args{ volume }              (optional) :  volume of a VLibPublication. To be used together with $args{name} to look up an existing publication.
#    $args{ isbn }                (optional) :  isbn of an existing VLibPublication.
#    $args{ issn }                (optional) :  issn of an existing VLibPublication.
#
# RETURNS
#    $publication    : Instance of XIMS::VLibPublication
#
# DESCRIPTION
#    Fetches existing publications or creates a new instance of XIMS::VLibPublication.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{name} ) and defined( $args{volume} ) ) or defined( $args{isbn} ) or defined( $args{issn} ) ) {
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
