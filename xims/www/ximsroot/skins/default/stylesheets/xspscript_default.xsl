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

<xsl:import href="xspscript_common.xsl"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body background="{$skimages}body_bg.png">
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td bgcolor="#ffffff" colspan="2">
                        <pre>
                            <xsl:apply-templates select="body"/>
                        </pre>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <tr>
                    <td>
                        <xsl:call-template name="processxsp_switcher"/>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:param name="process_xsp" select="'0'"/>
<xsl:template name="processxsp_switcher">
    <xsl:choose>
        <xsl:when test="$process_xsp = '0'">
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?process_xsp=1;m={$m}">Show body XSP processed</a>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?do_not_process_xsp=1;m={$m}">Do not XSP process body</a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
