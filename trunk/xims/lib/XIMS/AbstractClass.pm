# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package XIMS::AbstractClass;
use strict;
#use Data::Dumper;

sub data {
    my $self = shift;
    my %args = @_;

    # if we were passed data, load the object from it.
    if ( scalar( keys( %args ) ) > 0 ) {
        foreach my $field ( keys ( %args ) ) {
            my ( $field_method, $r_type ) = reverse ( split /\./, $field );
            $field_method = 'body' if $field_method eq 'binfile';
            $self->$field_method( $args{$field} ) if $self->can( $field_method );
        }
        # this allows the friendly $user = XIMS::User->new->data( %hash ) idiom to work
        # for automated creation.
        return $self;
    }

    # otherwise, spin the public fields out to a hash and return it
    my %data = ();

    my $body_hack = 0;
    if ( $self->isa('XIMS::Object') and $self->content_field and $self->content_field eq 'binfile') {
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

1;
