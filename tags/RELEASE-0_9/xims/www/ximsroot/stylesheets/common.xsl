<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="config.xsl"/>

<xsl:variable name="currentuilanguage"><xsl:value-of select="/document/context/session/uilanguage"/></xsl:variable>
<xsl:variable name="skimages" select="concat($ximsroot,'skins/',$currentskin,'/images/')"/>
<xsl:variable name="sklangimages" select="concat($skimages,$currentuilanguage,'/')"/>

<xsl:variable name="absolute_path"><xsl:call-template name="pathinfoinit"/></xsl:variable>
<xsl:variable name="absolute_path_nosite"><xsl:call-template name="pathinfoinit_nosite"/></xsl:variable>
<xsl:variable name="parent_path"><xsl:call-template name="pathinfoparent" /></xsl:variable>
<xsl:variable name="parent_path_nosite"><xsl:call-template name="pathinfoparent_nosite" /></xsl:variable>

<xsl:variable name="publishingroot">
    <xsl:choose>
        <xsl:when test="/document/context/object/parents/object[@parent_id = '1']/title">
            <xsl:value-of select="/document/context/object/parents/object[@parent_id = '1']/title"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="/document/context/object/title"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:param name="sb" select="'position'"/>
<xsl:param name="order" select="'asc'"/>
<xsl:param name="m" select="'e'"/>

<xsl:param name="printview" select="'0'"/>
<xsl:param name="default"/>
<xsl:param name="edit"/>
<xsl:param name="objtype"/>
<xsl:param name="create.x"/>
<xsl:param name="create"/>
<xsl:param name="s"/>
<xsl:param name="start_here"/>
<xsl:param name="hls"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template name="pathinfoinit">
    <xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each><xsl:if test="/document/context/object/@document_id != 1"><xsl:text>/</xsl:text><xsl:value-of select="/document/context/object/location"/></xsl:if>
</xsl:template>

<xsl:template name="pathinfoinit_nosite">
    <xsl:for-each select="/document/context/object/parents/object[@parent_id &gt; 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each><xsl:if test="/document/context/object[@parent_id &gt; 1]"><xsl:text>/</xsl:text><xsl:value-of select="/document/context/object/location"/></xsl:if>
</xsl:template>

<xsl:template name="pathinfoparent">
    <xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="pathinfoparent_nosite">
    <xsl:for-each select="/document/context/object/parents/object[@parent_id &gt; 1]">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="parentpath">
    <xsl:for-each select="preceding-sibling::object[@document_id != 1]"><xsl:text>/</xsl:text><xsl:value-of select="location"/></xsl:for-each>
</xsl:template>

<!-- is used in common_move.xsl, common_contentbrowse.xsl, common_contentbrowse_ewebeditimage.xsl -->
<xsl:template name="targetpath">
    <xsl:for-each select="/document/context/object/targetparents/object[@document_id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>/<xsl:value-of select="/document/context/object/target/object/location"/>
</xsl:template>

<xsl:template match="/document/context/object/parents/object">
    <xsl:param name="no_navigation_at_all">false</xsl:param>
    <xsl:variable name="thispath"><xsl:call-template name="parentpath"/></xsl:variable>
    <xsl:if test="$no_navigation_at_all = 'false'">
        / <a class="" href="{$goxims_content}{$thispath}/{location}?m={$m}"><xsl:value-of select="location"/></a>
    </xsl:if>
</xsl:template>

<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6    |i|u|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|
    dl|dt|dd|li|ol|ul|
    a|
    img|map|area|
    caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|
    button|fieldset|form|label|legend|input|option|optgroup|select|textarea|
    applet|object|param|embed|script">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp" mode="time">
    <xsl:value-of select="./hour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp" mode="ISO8601">
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
</xsl:template>

<xsl:template name="userfullname">
    <xsl:value-of select="firstname"/><xsl:text> </xsl:text><xsl:value-of select="lastname"/>
</xsl:template>

<xsl:template name="creatorfullname">
    <xsl:value-of select="created_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="created_by_lastname"/>
</xsl:template>

<xsl:template name="modifierfullname">
    <xsl:value-of select="last_modified_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="last_modified_by_lastname"/>
</xsl:template>

<xsl:template name="publisherfullname">
    <xsl:value-of select="published_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="published_by_lastname"/>
</xsl:template>

<xsl:template name="lastpublisherfullname">
    <xsl:value-of select="last_published_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="last_published_by_lastname"/>
</xsl:template>

<xsl:template name="ownerfullname">
    <xsl:value-of select="owned_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="owned_by_lastname"/>
</xsl:template>

<xsl:template name="lockerfullname">
    <xsl:value-of select="locked_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="locked_by_lastname"/>
</xsl:template>

<xsl:template name="message">
    <xsl:choose>
        <xsl:when test="/document/context/session/error_msg != ''">
            <span class="error_msg">
                <xsl:value-of select="/document/context/session/error_msg"/>
            </span>
        </xsl:when>
        <xsl:when test="/document/context/session/warning_msg != ''">
            <span class="warning_msg">
                <xsl:value-of select="/document/context/session/warning_msg"/>
            </span>
        </xsl:when>
        <xsl:when test="/document/context/session/message != ''">
            <span class="message">
                <xsl:value-of select="/document/context/session/message"/>
            </span>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>&#160;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="br-replace">
    <xsl:param name="word"/>
    <xsl:variable name="cr"><xsl:text>
</xsl:text></xsl:variable>
    <xsl:choose>
        <xsl:when test="contains($word,$cr)">
            <xsl:value-of select="substring-before($word,$cr)"/>
            <br/>
            <xsl:call-template name="br-replace">
                <xsl:with-param name="word" select="substring-after($word,$cr)"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$word"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="body">
    <xsl:apply-templates select="/document/context/object/body"/>
</xsl:template>

</xsl:stylesheet>
