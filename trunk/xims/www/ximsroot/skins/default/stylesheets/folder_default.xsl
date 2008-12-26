<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2008 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="container_common.xsl"/>

<xsl:variable name="deleted_children"><xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])" /></xsl:variable>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="createwidget">true</xsl:with-param>
                </xsl:call-template>
    
                <xsl:call-template name="childrentable"/>
    
                <xsl:call-template name="pagenavtable"/>
    
                <table align="center" width="98.7%" class="footer">
                    <xsl:call-template name="deleted_objects"/>
                    <xsl:call-template name="footer"/>
                </table>
    
                <xsl:call-template name="script_bottom"/>
                <xsl:call-template name="create_menu_js"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="head_default">
        <head>
            <title><xsl:call-template name="title"/></title>
            <xsl:call-template name="css"/>
            <xsl:call-template name="create_menu_css"/>
            <xsl:call-template name="script_head"/>
        </head>
    </xsl:template>
    

    <xsl:template name="deleted_objects">
        <xsl:choose>
            <xsl:when test="$hd=0 and $deleted_children > 0">
                <tr><td colspan="3">
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=1">Hide deleted Objects</a>
                </td></tr>
            </xsl:when>
            <xsl:when test="$deleted_children > 0">
                <tr><td colspan="3">
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=0">Show the  <xsl:value-of select="$deleted_children"/> deleted Object(s) in this Container</a>
                </td></tr>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

</xsl:stylesheet>
