<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_sitemap.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:call-template name="header"/>
        <h1 class="documenttitle">
        <xsl:value-of select="$i18n/l/Treeview_from"/> <xsl:value-of select="$absolute_path"/>
        </h1>
        <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
            <xsl:apply-templates select="/document/objectlist/object[location != '.diff_to_second_last']"/>
        </table>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>
    
<xsl:template name="title">
    <xsl:value-of select="$i18n/l/Treeview_from"/> <xsl:value-of select="location"/>  - XIMS
</xsl:template>

<xsl:template match="/document/objectlist/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr><td>
        <xsl:if test="marked_deleted='1'">
            <xsl:attribute name="style">background:#c6c6c6</xsl:attribute>
        </xsl:if>
        <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="{20*(number(@level)-ceiling(number(/document/objectlist/object/@level)))+1}" height="10"/>
        <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" alt="" width="20" height="18"/>
        <a href="{$goxims_content}?id={@id}"><xsl:value-of select="title"/></a>
    </td></tr>
</xsl:template>

</xsl:stylesheet>
