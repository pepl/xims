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

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit_bxe"/>
    <body onload="bxe_start('{$goxims_content}?id={@id};bxeconfig=1');">
        <div id="main" bxe_xpath="{./attributes/bxexpath}" />
    </body>
</html>
</xsl:template>

<xsl:template name="head-edit_bxe">
    <head>
        <title><xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}bxe/css/editor.css" type="text/css" />
        <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
        <script src="{$ximsroot}bxe/bxeLoader.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

</xsl:stylesheet>
