<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

    <xsl:import href="common.xsl"/>
    <xsl:import href="container_common.xsl"/>

    <xsl:variable name="deleted_children"><xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])" /></xsl:variable>

    <xsl:output method="html" encoding="ISO-8859-1"/>

    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        
        <html>
            <xsl:call-template name="head_default"/>
            
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
            
                <xsl:call-template name="header">
                    <xsl:with-param name="createwidget">true</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="childrentable"/>

                <table align="center" width="98.7%" class="footer">
                    <xsl:choose>
                        <xsl:when test="$hd=0">
                            <tr>
                                <td>
                                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};hd=1">Hide deleted objects</a>
                                </td>
                            </tr>
                        /xsl:when>
                        <xsl:when test="$deleted_children > 0">
                            <tr>
                                <td>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};hd=0">Show the <xsl:value-of select="$deleted_children"/> deleted object(s) in this container</a>
                                </td>
                            </tr>
                        </xsl:when>
                        <xsl:otherwise>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:call-template name="footer"/>
                </table>
            </body>
        /html>
    </xsl:template>

</xsl:stylesheet>
