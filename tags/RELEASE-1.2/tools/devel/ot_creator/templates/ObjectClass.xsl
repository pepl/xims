<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

<xsl:output method="text"/>
<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document"># Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::<xsl:value-of select="object_type_name"/>;

use strict;
use base qw( <xsl:value-of select="o_isa"/> );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::<xsl:value-of select="object_type_name"/>-&gt;new( %args )
#
# PARAMETER
#    $args{ User }                  (optional) :  XIMS::User instance
#    $args{ path }                  (optional) :  Location path to a XIMS Object, For example: '/xims'
#    $args{ $object_property_name } (optional) :  Object property like 'id', 'document_id', or 'title'.
#                                                 To fetch existing objects either 'path', 'id' or 'document_id' has to be specified.
#                                                 Multiple object properties can be specified in the %args hash.
#                                                 For example: XIMS::<xsl:value-of select="object_type_name"/>->new( id => $id )
##
# RETURNS
#    $<xsl:value-of select="translate(object_type_name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>: Instance of XIMS::<xsl:value-of select="object_type_name"/>
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::<xsl:value-of select="object_type_name"/> for object creation.
#

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => '<xsl:value-of select="data_format_name"/>' )->id() unless defined $args{data_format_id};
    }

    return $class-&gt;SUPER::new( %args );
}

1;
</xsl:template>
</xsl:stylesheet>