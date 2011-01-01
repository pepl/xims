<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../common.xsl"/>
<xsl:import href="../../../../../ximspubroot/stylesheets/include/common.xsl"/>
<xsl:import href="../../../../../ximspubroot/stylesheets/include/default_header.xsl"/>
<xsl:import href="../../../../stylesheets/config.xsl"/>

<xsl:output method="xml"
    encoding="utf-8"
    media-type="text/html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    indent="no"/>

<!-- overwrite goxims_content -->
<xsl:variable name="goxims_content" select="'/gopublic/content'" />

<xsl:template name="head_default">
    <head>
        <xsl:call-template name="meta"/>
        <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}stylesheets/default.css" type="text/css"/>
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
    </head>
</xsl:template>

<xsl:template name="meta">
    <xsl:variable name="dataformat">
        <xsl:value-of select="/document/context/object/data_format"/>
    </xsl:variable>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <link rel="schema.DC" href="http://purl.org/DC/elements/1.0/"/>
    <meta name="DC.Title" content="{title}"/>
    <meta name="DC.Creator">
        <xsl:attribute name="content"><xsl:call-template name="ownerfullname"/></xsl:attribute>
    </meta>
    <meta name="DC.Subject" content="{keywords}"/>
    <meta name="DC.Description" content="{abstract}"/>
    <meta name="DC.Publisher" content="Foo Inc."/>
    <meta name="DC.Contributor">
        <xsl:attribute name="content"><xsl:call-template name="modifierfullname"/></xsl:attribute>
    </meta>
    <meta name="DC.Date.Created" scheme="W3CDTF">
        <xsl:attribute name="content"><xsl:apply-templates select="creation_timestamp" mode="datetime"/></xsl:attribute>
    </meta>
    <meta name="DC.Date.Modified" scheme="W3CDTF">
        <xsl:attribute name="content"><xsl:apply-templates select="last_modification_timestamp" mode="datetime"/></xsl:attribute>
    </meta>
    <meta name="DC.Format" content="{/document/data_formats/data_format[@id=$dataformat]/name}"/>
    <meta name="DC.Language" content="{/document/context/session/uilanguage}"/>
</xsl:template>

<xsl:template name="modifierfullname">
    <xsl:value-of select="last_modified_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="last_modified_by_lastname"/>
</xsl:template>

<xsl:template name="ownerfullname">
    <xsl:value-of select="owned_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="owned_by_lastname"/>
</xsl:template>

<xsl:template name="parentpath_nosite">
    <xsl:for-each select="preceding-sibling::object[@parent_id &gt; 1]"><xsl:text>/</xsl:text><xsl:value-of select="location"/></xsl:for-each>
</xsl:template>

<xsl:template match="/document/context/object/parents/object">
    <xsl:variable name="parentpath"><xsl:call-template name="parentpath"/></xsl:variable>
    <xsl:variable name="parentpathnosite"><xsl:call-template name="parentpath_nosite"/></xsl:variable>
    <xsl:variable name="object_type_id">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="/document/object_types/object_type[@id=$object_type_id]/publish_gopublic=1">
            / <a class="nodeco" href="{$goxims_content}{$parentpath}/{location}"><xsl:value-of select="location"/></a>
        </xsl:when>
        <xsl:otherwise>
            / <a class="nodeco" href="{$publishingroot}{$parentpathnosite}/{location}"><xsl:value-of select="location"/></a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="pathinfo">
    <xsl:apply-templates select="/document/context/object/parents/object[@parent_id &gt; 1]"/>
    <xsl:choose>
        <xsl:when test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/publish_gopublic=1">
            / <a class="nodeco" href="{$goxims_content}{$absolute_path}"><xsl:value-of select="location"/></a>
        </xsl:when>
        <xsl:otherwise>
            / <a class="nodeco" href="{$publishingroot}{$absolute_path_nosite}"><xsl:value-of select="location"/></a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- for compatibility -->
<xsl:template name="pathnavigation">
    <xsl:call-template name="pathinfo"/>
</xsl:template>

<xsl:template name="deptlinks">
</xsl:template>

<xsl:template match="link">
    <a href="{@url}"><xsl:value-of select="text()"/></a><br/>
</xsl:template>

</xsl:stylesheet>
