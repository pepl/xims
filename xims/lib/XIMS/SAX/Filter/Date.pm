# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::Date;

##
# DESCRIPTION:
# This SAX Filter expands a datetime string to a nodeset.

# use warnings;
use strict;

use XML::SAX::Base;
@XIMS::SAX::Filter::Date::ISA = qw(XML::SAX::Base);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    # this has to be adapted to the current format we get the datetime in
    $self->{timestamp_regex} = qr/^(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)$/;
    return $self;
}

sub start_element {
    my ($self, $element) = @_;

    # how am i happy when we got the naming cleaned up...
    if ( $element->{LocalName} =~ /\_time$/i
         || $element->{LocalName} =~ /\_timestamp$/i
         || $element->{LocalName} eq "date"
         || $element->{LocalName} eq "lastaccess" ) {
        $self->{got_date} = 1;
    }

    $self->SUPER::start_element($element);
}

sub end_element {
    my $self = shift;

    if ( defined $self->{got_date} and defined $self->{date} ) {
        my ( $year, $month, $day, $hour, $min, $sec ) = ( $self->{date} =~ $self->{timestamp_regex} );

        $self->SUPER::start_element( {Name => "day", LocalName => "day", Prefix => "", NamespaceURI => undef, Attributes => {}} );
        $self->SUPER::characters( {Data => $day} );
        $self->SUPER::end_element();

        $self->SUPER::start_element( {Name => "month", LocalName => "month", Prefix => "", NamespaceURI => undef, Attributes => {}} );
        $self->SUPER::characters( {Data => $month} );
        $self->SUPER::end_element();

        $self->SUPER::start_element( {Name => "year", LocalName => "year", Prefix => "", NamespaceURI => undef, Attributes => {}} );
        $self->SUPER::characters( {Data => $year} );
        $self->SUPER::end_element();

        $self->SUPER::start_element( {Name => "hour", LocalName => "hour", Prefix => "", NamespaceURI => undef, Attributes => {}} );
        $self->SUPER::characters( {Data => $hour} );
        $self->SUPER::end_element();

        $self->SUPER::start_element( {Name => "minute", LocalName => "minute", Prefix => "", NamespaceURI => undef, Attributes => {}} );
        $self->SUPER::characters( {Data => $min} );
        $self->SUPER::end_element();

        $self->SUPER::start_element( {Name => "second", LocalName => "second", Prefix => "", NamespaceURI => undef, Attributes => {}} );
        $self->SUPER::characters( {Data => $sec} );
        $self->SUPER::end_element();

        $self->{date} = undef;
    }

    $self->{got_date} = undef;
    $self->SUPER::end_element(@_);
}

sub characters {
    my ( $self, $string ) = @_;

    if ( defined $string->{Data} and defined $self->{got_date} ) {
        $self->{date} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
    }
}

1;
