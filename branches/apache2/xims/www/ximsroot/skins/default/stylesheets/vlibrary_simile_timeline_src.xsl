<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_export_mods.xsl 1654 2007-03-27 11:12:21Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

    <xsl:import href="common.xsl"/>
    <xsl:import href="vlibrary_common.xsl"/>

    <xsl:output method="xml" media-type="text/xml" standalone="yes" omit-xml-declaration="yes" doctype-public="" doctype-system=""/>

    <xsl:template match="/document/context/object">
        <data>
            <xsl:apply-templates select="children/object">
                <xsl:sort select="concat(meta/date_from_timestamp/year,meta/date_from_timestamp/month,meta/date_from_timestamp/day,meta/date_from_timestamp/hour,meta/date_from_timestamp/minute,meta/date_from_timestamp/second)" order="ascending"/>
            </xsl:apply-templates>
        </data>
    </xsl:template>

    <xsl:template match="/document/context/object/children/object">
        <xsl:variable name="start"><xsl:apply-templates select="meta/date_from_timestamp" mode="RFC822" /></xsl:variable>
        <xsl:variable name="end"><xsl:apply-templates select="meta/date_to_timestamp" mode="RFC822" /></xsl:variable>
        <event
            start="{$start}"
            title="{title}"
            >
            <xsl:if test="$start != $end">
                <xsl:attribute name="isDuration">true</xsl:attribute>
                <xsl:attribute name="end"><xsl:value-of select="$end"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="abstract"/>
            <!--image="uri"-->
        </event>
    </xsl:template>

</xsl:stylesheet>
