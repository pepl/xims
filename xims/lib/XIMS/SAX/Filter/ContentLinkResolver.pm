# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::ContentLinkResolver;

##
# DESCRIPTION:
#
#This SAX Filter expands a content-id (major_id) to its corresponding
#path-string.  Note: This version does not touch the element name and
#therefore we got path-string in *_id elements!

use strict;
use base qw( XML::SAX::Base );
use XIMS;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{goximscontent} = XIMS::GOXIMS() . XIMS::CONTENTINTERFACE();

    return $self;
}

sub start_element {
    my ( $self, $element ) = @_;

    if ( defined $element->{LocalName} ) {
        my $goximscontent = $self->{goximscontent};
        if ( $element->{LocalName} eq 'a' ) {
            if ( $element->{Attributes}->{"{}href"}->{Value} ) {
                $element->{Attributes}->{"{}href"}->{Value}
                    =~ s/^$goximscontent\/[^\/]+//
                    ;    # leave the path relative to the site
            }
        }
        elsif ( $element->{LocalName} eq 'img' ) {
            if ( $element->{Attributes}->{"{}src"}->{Value} ) {
                $element->{Attributes}->{"{}src"}->{Value}
                    =~ s/^$goximscontent\/[^\/]+//
                    ;    # leave the path relative to the site
            }
        }
    }

    $self->SUPER::start_element($element);

    return;
}

1;
