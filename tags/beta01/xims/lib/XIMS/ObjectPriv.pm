# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::ObjectPriv;

use strict;
use XIMS::AbstractClass;
use vars qw($VERSION @Fields @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::AbstractClass );

#use Data::Dumper;

sub resource_type {
    return 'ObjectPriv';
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
        if ( scalar( keys( %args ) ) > 0 ) {
            my $real_privs = $self->data_provider->getObjectPriv( %args );
            if ( defined( $real_privs )) {
               $self->data( %{$real_privs} );
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
    my $ret = $self->data_provider->createObjectPriv( $self->data());
    return $ret;
}

sub delete {
    my $self = shift;
    my $retval = $self->data_provider->deleteObjectPriv( $self->data() );
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
    return $self->data_provider->updateObjectPriv( $self->data() );
}

1;