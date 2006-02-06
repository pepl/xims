<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/document/context/object">
<html>
  <head>
    <title><xsl:value-of select="$i18n/l/Treeview_from"/> <xsl:value-of select="location"/>  - XIMS</title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
  </head>
  <body>
    <xsl:call-template name="header"/>
    <h1 class="documenttitle">
    <xsl:value-of select="$i18n/l/Treeview_from"/> <xsl:value-of select="$absolute_path"/>
    </h1>
    <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
        <xsl:apply-templates select="/document/objectlist/object[location != '.diff_to_second_last']"/>
    </table>
  </body>

</html>
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
