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

<xsl:variable name="sfe"><xsl:if test="/document/context/object/schema_id != '' and contains(/document/context/object/attributes, 'sfe=1')">1</xsl:if></xsl:variable>

<xsl:variable name="bxe"><xsl:if test="/document/context/object/schema_id != '' and /document/context/object/css_id != '' 
                                       and contains(/document/context/object/attributes, 'bxeconfig_id')
                                       and contains(/document/context/object/attributes, 'bxexpath')
                                       and contains(/document/context/object/attributes, 'sfe=1')">1</xsl:if></xsl:variable>

<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body onload="stringHighlight(getParamValue('hls'))" background="{$skimages}body_bg.png">
            <xsl:call-template name="header"/>
            <xsl:call-template name="toggle_hls"/>
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
                <xsl:if test="$sfe = '1' or $bxe = '1'">
                    <tr>
                        <td colspan="2">
                            <xsl:if test="$sfe = '1'">
                                <a href="{$xims_box}{$goxims_content}?id={@id};simpleformedit=1">
                                    <xsl:value-of select="$i18n_xml/l/Edit_with_SFE"/>
                                </a>
                                <xsl:text> </xsl:text>
                            </xsl:if>

                            <xsl:if test="$bxe = '1'">
                                <a href="{$xims_box}{$goxims_content}?id={@id};edit=bxe">
                                    <xsl:value-of select="$i18n_xml/l/edit_with_BXE"/>
                                </a>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
