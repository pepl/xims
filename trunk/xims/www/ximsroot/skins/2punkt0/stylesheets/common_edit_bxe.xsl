<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_edit_bxe.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit_bxe"/>
    <body onload="bxe_start('{$goxims_content}?id={@id};bxeconfig=1');">
        <div id="main" bxe_xpath="{./attributes/bxexpath}" />
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="head-edit_bxe">
    <head>
        <title><xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}bxe/css/editor.css" type="text/css" />
        <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
        <script src="{$ximsroot}bxe/bxeLoader.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

</xsl:stylesheet>
