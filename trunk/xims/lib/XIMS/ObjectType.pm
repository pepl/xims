# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::ObjectType;

use strict;
use vars qw($VERSION @Fields @ISA);

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use XIMS;
use XIMS::AbstractClass;
@ISA = qw( XIMS::AbstractClass );
#use Data::Dumper;

sub resource_type {
    return 'ObjectType';
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
#    my $fullname = $objecttype->fullname();
#
# PARAMETER
#    none
#
# RETURNS
#    $fullname : '::'-separated fullname of the objectype including
#                the names of its ancestors
#
# DESCRIPTION
#    Returns the fullname of the object type, separated by '::' including
#    the names of the object type's ancestors.
#
sub fullname {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my @ancestors = @{$self->ancestors()};
    if ( scalar @ancestors ) {
        @ancestors = map { $_->name } @ancestors;
        return join('::', @ancestors) . '::' . $self->name();
    }
    else {
        return $self->name();
    }
}


##
#
# SYNOPSIS
#    my $ancestors = $objecttype->ancestors();
#
# PARAMETER
#    none
#
# RETURNS
#    $ancestors : Reference to Array of XIMS::ObjectTypes
#
# DESCRIPTION
#    Returns ancestor object types.
#
sub ancestors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $objecttype = (shift || $self);
    my @ancestors = @_;
    if ( $objecttype->parent_id() and $objecttype->id() != $objecttype->parent_id() ) {
        my $parent = XIMS::ObjectType->new( id => $objecttype->parent_id() );
        push @ancestors, $parent;
        $self->ancestors( $parent, @ancestors );
    }
    else {
        return [reverse @ancestors];
    }
}


1;
