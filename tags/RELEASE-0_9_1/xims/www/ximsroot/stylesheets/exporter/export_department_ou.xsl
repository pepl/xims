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

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/document">
        <ou>
            <title><xsl:apply-templates select="context/object/title"/></title>
            <xsl:if test="context/object/image_id != ''">
                <image url="{context/object/image_id}"/>
            </xsl:if>
            <stylesheet><xsl:apply-templates select="context/object/style_id"/></stylesheet>
            <path>
                <xsl:choose>
                    <xsl:when test="$resolvereltositeroots = 1">
                        <xsl:value-of select="$absolute_path_nosite"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$absolute_path"/>
                    </xsl:otherwise>
                </xsl:choose>
            </path>
            <xsl:apply-templates select="/document/objectlist/object"/>
        </ou>
    </xsl:template>

    <xsl:template match="objectlist/object">
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{location_path}"/>
    </xsl:template>
</xsl:stylesheet>
