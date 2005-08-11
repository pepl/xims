<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="name" /> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/userpages.css" type="text/css"/>
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>


</xsl:stylesheet>
