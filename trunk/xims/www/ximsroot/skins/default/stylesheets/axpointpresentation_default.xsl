<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:param name="msie" select="0"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body onload="stringHighlight(getParamValue('hls'))" background="{$skimages}body_bg.png">
            <xsl:call-template name="header"/>
            <xsl:call-template name="toggle_hls"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td bgcolor="#ffffff" colspan="2">
                        <span id="body">
                            <xsl:choose>
                                <xsl:when test="$msie=0">
                                    <xsl:apply-templates select="body"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <pre>
                                        <xsl:apply-templates select="body"/>
                                    </pre>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="axpointpresentation-options"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:call-template name="title"/></title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/axpointpresentation.css" type="text/css"/>
    </head>
</xsl:template>

<xsl:template name="axpointpresentation-options">
    <tr>
        <td colspan="3">
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?download_pdf=1"><xsl:value-of select="$i18n/l/Download_PDF"/></a>
            (<a href="{$xims_box}{$goxims_content}{$absolute_path}?download_pdf=1;printmode=1"><xsl:value-of select="$i18n/l/print_version"/></a>)
        </td>
    </tr>
</xsl:template>

<xsl:template name="footer">
    <tr>
        <td colspan="3" align="right">
            <a href="http://xims.info/documentation/" target="_blank">Systeminfo</a>
        </td>
    </tr>
</xsl:template>

<xsl:template match="background|email|metadata|organisation|point|slide|slideset|slideshow|speaker|subtitle|text|logo|source-code|source_code|i|b|colour|color|table|row|col|line|rect|circle|ellipse">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<!-- display images -->
<xsl:template match="image">
    <img xmlns:xlink="http://www.w3.org/1999/xlink" src="{text()|@xlink:href}" alt="{text()|@xlink:href}"/>
</xsl:template>

<!-- rename the two elements conflicting with HTML to slide* -->
<xsl:template match="link">
    <slidelink>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </slidelink>
</xsl:template>

<xsl:template match="title">
    <slidetitle>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </slidetitle>
</xsl:template>

</xsl:stylesheet>
