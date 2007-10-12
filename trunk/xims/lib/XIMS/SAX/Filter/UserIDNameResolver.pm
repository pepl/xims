# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::UserIDNameResolver;

##
# DESCRIPTION:
# This SAX Filter expands a user id to its corresponding name.

use strict;
use base qw( XIMS::SAX::Filter::DataCollector );
use XIMS::User;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    return $self;
}

sub start_element {
    my ( $self, $element ) = @_;

    if ( defined $element->{LocalName}
        and grep {/^$element->{LocalName}$/i} @{ $self->{ResolveUser} } )
    {
        $self->{got_to_resolve} = 1;
    }

    $self->SUPER::start_element($element);

    return;
}

sub end_element {
    my $self = shift;

    if (    defined $self->{got_to_resolve}
        and defined $self->{user_id}
        and $self->{user_id} =~ /^[0-9]+$/ )
    {
        my $name = XIMS::User->new( id => $self->{user_id} )->name();
        $self->SUPER::characters( { Data => $name } );
        $self->{user_id} = undef;
    }

    $self->{got_to_resolve} = undef;
    $self->SUPER::end_element(@_);

    return;
}

sub characters {
    my ( $self, $string ) = @_;

    if (    defined $string->{Data}
        and defined $self->{got_to_resolve}
        and $self->{got_to_resolve} == 1 )
    {
        $self->{user_id} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
    }

    return;
}

1;
