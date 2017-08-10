<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_bodyonly.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="../../../stylesheets/text_common.xsl"/>

<xsl:param name="pre"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <span id="body">
                <xsl:apply-templates select="body"/>
            </span>
        </body>
    </html>
</xsl:template>

<xsl:template match="body">
    <xsl:choose>
        <xsl:when test="$pre = '1'">
            <pre>
                <xsl:apply-templates/>
            </pre>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>

