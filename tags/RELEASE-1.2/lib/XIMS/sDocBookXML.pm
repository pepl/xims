# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::sDocBookXML;

use strict;
use base qw( XIMS::Document );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::sDocBookXML->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $docbookxml: XIMS::sDocBookXML instance
#
# DESCRIPTION
#    Constructor
#

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'sDocBookXML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;

