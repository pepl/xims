# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SimpleDBMemberPropertyValue;

use strict;
use warnings;

use base qw( XIMS::AbstractClass );

our $VERSION;
our @Fields;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

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
#    my $simpledbmemberpropertyvalue = XIMS::SimpleDBMemberPropertyValue->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id.
#    $args{ property_id }         (optional) :  property_id of the SimpleDBMemberPropertyValue.
#    $args{ member_id }           (optional) :  member_id of the SimpleDBMemberPropertyValue.
#
# RETURNS
#    $simpledbmemberpropertyvalue    : Instance of XIMS::SimpleDBMemberPropertyValue
#
# DESCRIPTION
#    Fetches existing property values or creates a new instance of XIMS::SimpleDBMemberPropertyValue.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{property_id} ) and defined( $args{member_id} ) ) ) {
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
