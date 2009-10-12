<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>
<xsl:template match="/document">
    <xsl:if test="string-length(context/object/style_id)">
        <xsl:processing-instruction name="xml-stylesheet"> type="application/x-xsp" href="." </xsl:processing-instruction>
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