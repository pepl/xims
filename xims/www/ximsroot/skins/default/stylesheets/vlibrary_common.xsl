<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml"
                encoding="utf-8"
                media-type="text/html"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                indent="no"/>

    <xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>

    <xsl:param name="mo" select="'subject'"/>
    <xsl:param name="colms" select="3"/>

    <xsl:template name="head_default">
        <head>
            <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
            <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
    </xsl:template>

    <xsl:template name="item">
        <tr>
            <td>
                <xsl:call-template name="item_div">
                    <xsl:with-param name="mo" select="$mo"/>
                </xsl:call-template>
            </td>
            <xsl:for-each select="following-sibling::node()[position() &lt; $colms]">
                <td>
                    <xsl:call-template name="item_div">
                        <xsl:with-param name="mo" select="$mo"/>
                    </xsl:call-template>
                </td>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:template name="item_div">
        <div id="{$mo}">
            <xsl:choose>
                <xsl:when test="$mo = 'author'">
                    <div>
                        <xsl:call-template name="author_link"/>
                    </div>
                    <div>
                        <xsl:call-template name="decide_plural"/>
                    </div>
                </xsl:when>
                <xsl:when test="$mo = 'publication'">
                    <div>
                        <xsl:call-template name="publication_link"/>
                    </div>
                    <div>
                        <xsl:call-template name="decide_plural"/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div id="subject">
                        <div>
                            <xsl:call-template name="subject_link"/>
                        </div>
                        <div>
                            <xsl:call-template name="decide_plural"/>
                            <xsl:value-of select="$i18n_vlib/l/last_modified_at"/>
                            <xsl:text> </xsl:text>
                            <xsl:apply-templates select="last_modification_timestamp" mode="datetime" />
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="decide_plural">
        <xsl:value-of select="object_count"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="number(object_count) = 1">
                <xsl:value-of select="$i18n_vlib/l/item"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$i18n_vlib/l/items"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="switch_vlib_views_action">
        <ul>
            <xsl:if test="$mo != 'subject'">
                <li>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}">
                        <xsl:value-of select="$i18n_vlib/l/subject_list"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$mo != 'author'">
                <li>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?authors=1">
                        <xsl:value-of select="$i18n_vlib/l/author_list"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$mo != 'publication'">
                <li>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?publications=1">
                        <xsl:value-of select="$i18n_vlib/l/publication_list"/>
                    </a>
                </li>
            </xsl:if>
        </ul>
    </xsl:template>


    <xsl:template name="vlib_create_action">
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype=VLibraryItem::sDocBookXML">
        <xsl:value-of select="$i18n_vlib/l/create_new_vlibraryitem"/>
        </a>
    </xsl:template>

    <xsl:template name="author_link">
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?author=1;author_id={id};author_name={firstname} {lastname}">
        <xsl:value-of select="firstname"/><xsl:text> </xsl:text><xsl:value-of select="lastname"/></a>
    </xsl:template>


    <xsl:template name="publication_link">
        <xsl:variable name="publication_url" select="concat($xims_box,$goxims_content,$absolute_path,'?publication=1;publication_id=',id,';publication_name=',name,' (',volume,')')"/>
        <a href="{$publication_url}">
            <xsl:value-of select="name"/> (<xsl:value-of select="volume"/>)
        </a>
    </xsl:template>

    <xsl:template name="subject_link">
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?subject=1;subject_id={id}">
            <xsl:value-of select="name"/>
        </a>
    </xsl:template>

</xsl:stylesheet>
