# Copyright (c) 2002-2005 The XIMS Project.
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
#    XIMS::ObjectType->new( %args );
#
# PARAMETER
#    %args: If $args{id} or $args{name} or $args{fullname} is given, a lookup of an already
#           existing object will be tried. Otherwise, an object blessed
#           into the caller's object class with the specific resource
#           type properties given in %args will be returned.
#
# RETURNS
#    $object: XIMS::ObjectType instance
#
# DESCRIPTION
#    Constructor for XIMS object types which may be looked up
#    by 'id', 'name', or 'fullname'. If 'name' is given as look up key and two object types
#    with the same 'name' but a different 'fullname' exist, undef is returned. You will have
#    to use 'fullname' in such cases.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{name} ) or defined( $args{fullname} ) ) {
            $args{name} = ( split /::/, $args{fullname} )[-1] if defined( $args{fullname} );
            my @real_ot = $self->data_provider->getObjectType( %args );
            if ( scalar @real_ot == 1 ) {
                $self->data( %{$real_ot[0]} );
            }
            elsif ( defined( $args{fullname} ) ) {
                my @ids = map { $_->{'objecttype.id'} } @real_ot;
                my @ots = $self->data_provider->object_types( id => \@ids );
                foreach my $ot ( @ots ) {
                    return $ot if $ot->fullname() eq $args{fullname};
                }
            }
            elsif ( scalar @real_ot > 1 and exists $args{name} ) {
                XIMS::Debug( 2, "ambigous object type lookup. try looking up using 'fullname'" );
                return undef;
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
