# Copyright (c) 2002-2003 The XIMS Project.
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


sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{name} ) ) {
            my $real_ot = $self->data_provider->getObjectType( %args );
            if ( defined( $real_ot )) {
               $self->data( %{$real_ot} );
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

sub create {
    my $self = shift; 
    my $id = $self->data_provider->createObjectType( $self->data());
    $self->id( $id );
    return $id;
}

sub delete {
    my $self = shift;
    my $retval = $self->data_provider->deleteObjectType( $self->data() );
    if ( $retval ) {
        map { $self->$_( undef ) } $self->fields(); 
        return 1;
    }
    else {
       return undef;
    }
}
            
sub update {
    my $self = shift;
    return $self->data_provider->updateObjectType( $self->data() );
}
1;
