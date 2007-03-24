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

<xsl:variable name="deleted_children"><xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])" /></xsl:variable>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
            <xsl:call-template name="header">
                <xsl:with-param name="createwidget">true</xsl:with-param>
            </xsl:call-template>

            <xsl:call-template name="childrentable"/>

            <xsl:call-template name="pagenavtable"/>

            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="deleted_objects"/>
                <xsl:call-template name="footer"/>
            </table>
        </body>
    </html>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - <xsl:call-template name="department_title"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>

        <script src="{$ximsroot}skins/{$currentskin}/scripts/create_menu_expander.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/create_menu_setup.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/create_menu_style.css" type="text/css" />
    </head>
</xsl:template>

</xsl:stylesheet>
