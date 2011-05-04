<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_localized.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

<!-- This is dirty, better ideas? -->
<xsl:template name="marked_mandatory">
    <xsl:choose>
        <xsl:when test="$currentuilanguage = 'de-at'">
            <img src="{$ximsroot}images/spacer_white.gif" alt="Mit *"/> <span style="color:maroon">Markierte</span> Felder sind obligatorisch!
        </xsl:when>
        <xsl:otherwise>
            Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

    <xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date|status_checked_timestamp" mode="date">
    <xsl:choose>
        <xsl:when test="$currentuilanguage = 'de-at'">
            <xsl:value-of select="./day"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="./month"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="./year"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="./month"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="./day"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="./year"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date|status_checked_timestamp" mode="datetime">
    <xsl:choose>
        <xsl:when test="$currentuilanguage = 'de-at'">
            <xsl:value-of select="./day"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="./month"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="./year"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./hour"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="./minute"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="./month"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="./day"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="./year"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./hour"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="./minute"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date|status_checked_timestamp" mode="datetime-ISO-8601">
            <xsl:value-of select="./year"/>
            <xsl:text>-</xsl:text>
			<xsl:value-of select="./month"/>
            <xsl:text>-</xsl:text>
			<xsl:value-of select="./day"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./hour"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="./minute"/>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date|status_checked_timestamp" mode="date-ISO-8601">
            <xsl:value-of select="./year"/>
            <xsl:text>-</xsl:text>
			<xsl:value-of select="./month"/>
            <xsl:text>-</xsl:text>
			<xsl:value-of select="./day"/>
</xsl:template>

</xsl:stylesheet>
