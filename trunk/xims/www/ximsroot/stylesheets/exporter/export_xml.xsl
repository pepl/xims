<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="ISO-8859-1"/>
<xsl:template match="/document">
        <xsl:if test="string-length(context/object/style_id)">
            <xsl:processing-instruction name="xml-stylesheet"> type="text/xsl" href="<xsl:apply-templates select="context/object/style_id"/>" </xsl:processing-instruction>
        </xsl:if>
    <xsl:apply-templates select="context/object/body"/>
</xsl:template>
<xsl:template match="/document/context/object/body//*">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>
</xsl:stylesheet>
