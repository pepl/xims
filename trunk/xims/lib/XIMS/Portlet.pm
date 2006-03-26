# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::Portlet;

use strict;
use base qw( XIMS::SymbolicLink );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# the following functions are dummy functions, so we have an interface
# for filters in the future :)

sub testCondition {
    my ( $self, $condition ) = @_;
    my $retval = 0;

    return $retval unless defined $condition and length $condition;

    # This function should test a condition to be valid. the algorithm
    # may get used to implement the filter itself. the function should
    # parse the condition and if the condition is ok, it should return
    # TRUE! (1)

    return $retval;
}

# the following three functions place/remove a filter into the body.

sub applyFilter {
    my ( $self, $name, $condition ) = @_;
    my $retval = 0;

    return $retval unless $self->body;

    if ( defined $name and defined $condition ) {

    }
    else {
        XIMS::Debug( 4, "incomplete parameter" );
    }

    return $retval;
}

sub removeFilter {
    my ( $self, $name ) = @_;
    my $retval = 0;

    return $retval unless $self->body;

    if ( defined $name ) {

    }
    else {
        XIMS::Debug( 4, "incomplete parameter" );
    }

    return $retval
}

sub updateFilter {
    my ( $self, $name, $condition ) = @_;
    my $retval = 0;

    return $retval unless $self->body;

    if ( defined $name and defined $condition ) {

    }
    else {
        XIMS::Debug( 4, "incomplete parameter" );
    }

    return $retval
}

1;
