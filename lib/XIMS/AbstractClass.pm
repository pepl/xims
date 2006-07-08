# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AbstractClass;

use strict;
use XIMS;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub data {
    my $self = shift;
    my %args = @_;

    # if we were passed data, load the object from it.
    if ( scalar( keys( %args ) ) > 0 ) {
        foreach my $field ( keys ( %args ) ) {
            my ( $field_method, $r_type ) = reverse ( split /\./, $field );
            $field_method = 'document_id' if $field_method eq 'id' and $r_type and $r_type eq 'document';
            $field_method = 'body' if $field_method eq 'binfile';
            # location_path is not really writable, to make data() still work, check for it here
            if ( $r_type eq 'document' and $field_method eq 'location_path' ) {
                $self->{location_path} = $args{$field};
            }
            else {
                $self->$field_method( $args{$field} ) if $self->can( $field_method );
            }
        }
        # this allows the friendly $user = XIMS::User->new->data( %hash ) idiom to work
        # for automated creation.
        return $self;
    }

    # otherwise, spin the public fields out to a hash and return it
    my %data = ();

    my $body_hack = 0;
    if ( $self->isa('XIMS::Object') and $self->content_field eq 'binfile') {
        $body_hack++;
    }

    foreach ( $self->fields() ) {
        if ( $_ eq 'body' and $body_hack > 0 ) {
            $data{binfile} = $self->$_;
        }
        else {
            $data{$_} = $self->$_;
        }
    }
    return %data;
}

sub data_provider { XIMS::DATAPROVIDER() }

##
#
# SYNOPSIS
#    XIMS::Foo->new( %args );
#
# PARAMETER
#    %args: If $args{id} or $args{name} is given, a lookup of an already
#           existing object will be tried. Otherwise, an object blessed
#           into the caller's object class with the specific resource
#           type properties given in %args will be returned.
#
# RETURNS
#    $object: XIMS::Foo instance
#
# DESCRIPTION
#    Generic constructor for XIMS resource types which may be looked up
#    by 'id' or 'name'. This method is designed to be inherited by the
#    resource type subclasses.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{name} ) ) {
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

##
#
# SYNOPSIS
#    $object->create();
#
# PARAMETER
#    none
#
# RETURNS
#    $id: id of an newly created object.
#
# DESCRIPTION
#    Generic method for creating objects using XIMS::DataProvider. This
#    method is designed to be inherited by the resource type subclasses.
#
sub create {
    my $self = shift;
    my $rt = ref($self);
    $rt =~ s/.*://;
    my $method = 'create'.$rt;
    my $id = $self->data_provider->$method( $self->data());
    $self->id( $id );
    return $id;
}

##
#
# SYNOPSIS
#    $object->delete();
#
# PARAMETER
#    none
#
# RETURNS
#    1 on success, undef on failure
#
# DESCRIPTION
#    Generic method for deleting objects using XIMS::DataProvider. This
#    method is designed to be inherited by the resource type subclasses.
#
sub delete {
    my $self = shift;
    my $rt = ref($self);
    $rt =~ s/.*://;
    my $method = 'delete'.$rt;
    my $retval = $self->data_provider->$method( $self->data() );
    if ( $retval ) {
        map { $self->$_( undef ) } $self->fields();
        return 1;
    }
    else {
       return undef;
    }
}

##
#
# SYNOPSIS
#    $object->update();
#
# PARAMETER
#    none
#
# RETURNS
#    count of updated rows
#
# DESCRIPTION
#    Generic method for updating objects using XIMS::DataProvider. This
#    method is designed to be inherited by the resource type subclasses.
#
sub update {
    my $self = shift;
    my $rt = ref($self);
    $rt =~ s/.*://;
    my $method = 'update'.$rt;
    return $self->data_provider->$method( $self->data() );
}

1;
