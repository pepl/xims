<?xml version="1.0"?>
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
<xsl:import href="../../../../stylesheets/text_common.xsl"/>
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td colspan="2">
                        <xsl:apply-templates select="body"/>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <tr>
                    <td>
                        <xsl:choose>
                            <xsl:when test="$pre = '0'">
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=1;m={$m}">Show body pre-formatted</a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?m={$m}">Show body default-formatted</a>
                            </xsl:otherwise>
                        </xsl:choose>
                        |
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?parse_css=1" target="_new">Validate CSS</a>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

