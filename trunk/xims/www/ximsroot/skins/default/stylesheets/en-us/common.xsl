<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../common.xsl"/>

    <xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp|valid_from_timestamp|valid_to_timestamp|status_checked_timestamp" mode="date">
    <xsl:value-of select="./month"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="./day"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="./year"/>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp|valid_from_timestamp|valid_to_timestamp|status_checked_timestamp" mode="datetime">
    <xsl:value-of select="./month"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="./day"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="./year"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./hour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
</xsl:template>

<xsl:template name="marked_mandatory">
    Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!
</xsl:template>

</xsl:stylesheet>
