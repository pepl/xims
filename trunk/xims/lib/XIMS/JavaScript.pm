# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::JavaScript;

use strict;
use base qw( XIMS::Text );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::JavaScript->new( %args )
#
# PARAMETER
#    $args{ User }                  (optional) :  XIMS::User instance
#    $args{ path }                  (optional) :  Location path to a XIMS Object, For example: '/xims'
#    $args{ $object_property_name } (optional) :  Object property like 'id', 'document_id', or 'title'.
#                                                 To fetch existing objects either 'path', 'id' or 'document_id' has to be specified.
#                                                 Multiple object properties can be specified in the %args hash.
#                                                 For example: XIMS::JavaScript->new( id => $id )
##
# RETURNS
#    $javascript: Instance of XIMS::JavaScript
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::JavaScript for object creation.
#

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'ECMA' )->id() unless defined $args{data_format_id};
    }
    return $class->SUPER::new( %args );
}

1;
