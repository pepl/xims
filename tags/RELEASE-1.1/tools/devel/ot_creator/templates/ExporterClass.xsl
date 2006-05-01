<?xml version="1.0" encoding="iso-8859-1" ?>
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
package XIMS::Exporter::<xsl:value-of select="object_type_name"/>;

use strict;
use XIMS::Exporter;
use base qw( <xsl:value-of select="e_isa"/> );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

#
# override here (create, remove, sax filters, ...)
#

1;
</xsl:template>
</xsl:stylesheet>