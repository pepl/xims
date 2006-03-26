# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::XML;

use strict;
use base qw( XIMS::Object );
use XIMS::DataFormat;
use XIMS::Entities;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $xml = XIMS::XML->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from XIMS::Object::new()
#
# RETURNS
#    $xml: instance of XIMS::XML
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::XML for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    my $body = $xml->body();
#    my $boolean = $xml->body( $body [, %args] );
#
# PARAMETER
#    $body                  (optional) :  Body string to save
#
# RETURNS
#    $body    : Body string from object
#    $boolean : True or False for storing back body to object
#
# DESCRIPTION
#    Overrides XIMS::Object::body(). Only sets $body if it is a well-formed XML string.
#
sub body {
    XIMS::Debug( 5, "called");
    my $self = shift;
    my $body = shift;
    my $retval;

    return $self->SUPER::body() unless $body;

    # we only want the default XML-entities to be present
    $body = XIMS::Entities::decode( $body );

    if ( $self->balanced_string( $body, nochunk => 1 ) ) {
        $self->SUPER::body( $body );
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "body is not well formed" );
    }

    return $retval;
}

1;
