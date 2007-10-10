# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::RefLibSerial;

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
#    my $reflibserial = XIMS::RefLibSerial->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id.
#    $args{ title }               (optional) :  title of the serial.
#    $args{ stitle }              (optional) :  short title of the serial.
#    $args{ issn }                (optional) :  issn of the serial.
#
# RETURNS
#    $reflibserial    : Instance of XIMS::RefLibSerial
#
# DESCRIPTION
#    Fetches existing serials or creates a new instance of XIMS::RefLibSerial.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{title} ) or defined( $args{stitle} ) or defined( $args{issn} ) ) {
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
