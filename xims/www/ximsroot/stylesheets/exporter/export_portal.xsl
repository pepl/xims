<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/document">
        <xsl:if test="string-length(context/object/style_id)">
        <xsl:processing-instruction name="xml-stylesheet"> type="text/xsl" href="<xsl:apply-templates select="context/object/style_id"/>" </xsl:processing-instruction>
        </xsl:if>
        <portal>
            <title><xsl:apply-templates select="context/object/title"/></title>
            <xsl:if test="context/object/image_id != ''">
                <image url="{context/object/image_id}"/>
            </xsl:if>
            <stylesheet><xsl:apply-templates select="context/object/style_id"/></stylesheet>
            <xsl:apply-templates select="/document/context/object/children/object"/>
        </portal>
    </xsl:template>

    <xsl:template match="children/object">
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{symname_to_doc_id}"/>
    </xsl:template>
</xsl:stylesheet>
