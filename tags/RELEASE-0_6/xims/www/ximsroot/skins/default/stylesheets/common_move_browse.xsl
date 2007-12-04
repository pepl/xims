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
<xsl:variable name="target_path"><xsl:call-template name="targetpath"/></xsl:variable>

<xsl:template match="/document/context/object">
<html>
  <head>
    <title><xsl:value-of select="$i18n/l/Move_object"/> <xsl:value-of select="location"/> - XIMS</title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
  </head>
  <body>
    <xsl:call-template name="header"/>
    <div class="edit">
    <form action="{$xims_box}{$goxims_content}" method="GET">
        <xsl:value-of select="$i18n/l/Move_object"/> '<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/from"/> '<xsl:value-of select="$parent_path"/>'
        <xsl:value-of select="$i18n/l/to"/>:
        <input type="text" size="60" name="to">
            <xsl:choose>
                <xsl:when test="$target_path != $absolute_path">
                    <xsl:attribute name="value"><xsl:value-of select="$target_path"/></xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </input>
        <xsl:text> </xsl:text><input type="submit" value="{$i18n/l/Move_object}" class="control"/><br/><br/>
            <xsl:value-of select="$i18n/l/browse_target"/>:
            <br/>&#xa0;
            <xsl:apply-templates select="targetparents/object[@document_id !=1]"/>
            <xsl:apply-templates select="target/object"/>

            <table>
                <xsl:apply-templates select="targetchildren/object[@id != /document/context/object/@id]">
                    <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                </xsl:apply-templates>
            </table>
        <input type="hidden" name="id" value="{@id}"/>
        <input type="hidden" name="move" value="1"/>
    </form>
    <br/>
    <xsl:call-template name="canceledit"/>
    </div>
  </body>

</html>
</xsl:template>


<xsl:template match="targetparents/object|target/object">
      / <a class="" href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};move_browse=1;to={@id}"><xsl:value-of select="location"/></a>
</xsl:template>

<xsl:template match="targetchildren/object">
    <tr><td>
        <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="{10*@level}" height="10"/>
        <img src="{$ximsroot}images/icons/list_Container.gif" alt="Container" width="20" height="18"/><a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};move_browse=1;to={@id}"><xsl:value-of select="title"/></a>
    </td></tr>
</xsl:template>

</xsl:stylesheet>