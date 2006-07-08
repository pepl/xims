<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../anondiscussionforumcontrib_default.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:output method="xml" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template name="head_default">
    <head>
        <xsl:call-template name="meta"/>
        <title><xsl:value-of select="title"/> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
        <script src="{$ximsroot}scripts/anondiscussionforum.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

<xsl:template match="/document/objectlist/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr>
        <td class="10left">
            <img src="{$ximsroot}images/spacer_white.gif"
                alt="spacer"
                width="{20*(number(@level)-ceiling(number(/document/objectlist/object/@level)))+1}"
                height="10"
            />
            <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif"
                alt=""
                width="20"
                height="18"
            />
            <a href="{$goxims_content}?id={@id}"><xsl:value-of select="title"/></a>
            (<xsl:choose>
                <xsl:when test="attributes/email">
                    <a href="mailto:{attributes/email}"><xsl:value-of select="attributes/author"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="attributes/author"/>
                </xsl:otherwise>
            </xsl:choose>
            ,
            <xsl:apply-templates select="creation_timestamp" mode="datetime"/>)
        </td>
        <td valign="bottom" height="25">
            <xsl:if test="/document/context/object/user_privileges/delete">
                <a href="{$goxims_content}?id={@id};delete_prompt=1;">
                    <img src="{$skimages}option_delete.png" border="0" width="37" height="19" title="{$i18n/l/delete}" alt="{$i18n/l/delete}"/>
                </a>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
