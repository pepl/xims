<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:template name="footer">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>

        <tr>
            <td colspan="2">
                <xsl:choose>
                    <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type='application/x-container'">
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?sitemap=1"><xsl:value-of select="$i18n/l/Treeview"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$printview != '0'">
                                <a href="{$goxims_content}{$absolute_path}?m={$m}"><xsl:value-of select="$i18n/l/Defaultview"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$goxims_content}{$absolute_path}?m={$m};printview=1"><xsl:value-of select="$i18n/l/Printview"/></a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td align="right">
                <a href="http://xims.info/documentation/" target="_blank">Systeminfo</a>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
