<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../common.xsl"/>

<xsl:template name="metafooter">
    <p class="metafooter">
        Für das Dokument verantwortlich: <xsl:call-template name="ownerfullname"/><br />
        Zuletzt geändert am <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/> von <xsl:call-template name="modifierfullname"/>
    </p>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp" mode="date">
    <xsl:value-of select="./day"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./month"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./year"/>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|descendant_last_modification_timestamp" mode="datetime">
    <xsl:value-of select="./day"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./month"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./year"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./hour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
</xsl:template>

</xsl:stylesheet>
