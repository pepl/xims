<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

<xsl:output method="text"/>
<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document"># Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::<xsl:value-of select="object_type_name"/>;

use strict;
use vars qw( $VERSION @ISA );

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('<xsl:value-of select="o_isa"/>');

use <xsl:value-of select="o_isa"/>;

##
#
# SYNOPSIS
#    XIMS::<xsl:value-of select="object_type_name"/>-&gt;new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $<xsl:value-of select="translate(object_type_name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>: XIMS::<xsl:value-of select="objecttype"/> instance
#
# DESCRIPTION
#    Constructor
#

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    $args{object_type_id} = <xsl:value-of select="object_type_id"/> unless defined( $args{object_type_id} );
    $args{data_format_id} = <xsl:value-of select="data_format_id"/> unless defined( $args{data_format_id} );

    return $class-&gt;SUPER::new( %args );
}

1;
</xsl:template>
</xsl:stylesheet>