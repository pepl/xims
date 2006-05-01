# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::XSLStylesheet;

use strict;
use base qw( XIMS::XML );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $xslstylesheet = XIMS::XSLStylesheet->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from XIMS::Object::new()
#
# RETURNS
#    $xslstylesheet: instance of XIMS::XSLStylesheet
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::XSLStylesheet for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XSLT' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
