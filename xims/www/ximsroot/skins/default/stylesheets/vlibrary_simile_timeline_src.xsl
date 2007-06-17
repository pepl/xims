<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_export_mods.xsl 1654 2007-03-27 11:12:21Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exslt="http://exslt.org/common"
                extension-element-prefixes="exslt date"
                >

    <xsl:import href="common.xsl"/>

    <xsl:output method="xml"/>

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

    <xsl:template match="date_from_timestamp|date_to_timestamp" mode="RFC822">
        <xsl:variable name="datetime">
            <xsl:value-of select="./year"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="./month"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="./day"/>
            <xsl:text>T</xsl:text>
            <xsl:value-of select="./hour"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="./minute"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="./second"/>
            <!--<xsl:value-of select="./tzd"/>-->
        </xsl:variable>
        <xsl:variable name="hour" select="hour"/>
        <xsl:variable name="gmtdiff" select="'1'"/>
        <xsl:variable name="gmthour">
            <xsl:choose>
                <xsl:when test="number($hour)-number($gmtdiff) &lt; 0"><xsl:value-of select="number($hour)-number($gmtdiff)+24"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="number($hour)-number($gmtdiff)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="substring(date:day-name($datetime),1,3)"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="./day"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="date:month-abbreviation($datetime)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="./year"/>
        <xsl:text> </xsl:text>
        <xsl:if test="string-length($gmthour)=1">0</xsl:if><xsl:value-of select="$gmthour"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./minute"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./second"/>
        <xsl:text> GMT</xsl:text>
    </xsl:template>

</xsl:stylesheet>
