# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::Portlet;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::SymbolicLink;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::SymbolicLink');

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
