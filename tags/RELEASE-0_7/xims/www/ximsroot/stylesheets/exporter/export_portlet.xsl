<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/document">
        <portlet id="{context/object/@id}">
            <title><xsl:value-of select="context/object/title"/></title>
            <baselocation><xsl:value-of select="context/object/location_path"/></baselocation>
            <xsl:apply-templates select="context/object/children/object"/>
        </portlet>
    </xsl:template>

    <xsl:template match="children/object">
        <portlet-item id="{@id}" parent_id="{@parent_id}">
            <xsl:apply-templates/>
        </portlet-item>
    </xsl:template>

    <xsl:template match="children/object//*">
        <xsl:if test="name()!='document_id' and name()!='id'">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
