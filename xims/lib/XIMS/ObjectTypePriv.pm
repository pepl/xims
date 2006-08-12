# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::ObjectTypePriv;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

sub fields {
    return @Fields;
}

sub resource_type {
    return 'ObjectTypePriv';
}

__PACKAGE__->mk_accessors( @Fields );

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys( %args ) ) > 0 ) {
        my $real_privs = $self->data_provider->getObjectTypePriv( %args );
        if ( defined( $real_privs )) {
           $self->data( %{$real_privs} );
        }
        else {
            return undef;
        }
    }
    return $self;
}

sub create {
    my $self = shift;
    my $ret = $self->data_provider->createObjectTypePriv( $self->data());
    return $ret;
}

sub delete {
    my $self = shift;
    my $retval = $self->data_provider->deleteObjectTypePriv( $self->data() );
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
    return $self->data_provider->updateObjectTypePriv( $self->data() );
}

1;
