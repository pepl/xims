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
   
    <xsl:template name="footer">
        <xsl:param name="link_pub_preview">false</xsl:param>
        <xsl:variable name="dataformat">
            <xsl:value-of select="/document/context/object/data_format"/>
        </xsl:variable>
        
        <tr>
            <td colspan="2">
                <xsl:choose>
                    <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='Container'">
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?sitemap=1">Tree view</a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$printview != '0'">
                                <a href="{$goxims_content}{$absolute_path}?m={$m}">Default view</a>
                                <xsl:if test="$link_pub_preview='true'">
                                    &#160;
                                    <a href="javascript:previewWindow('{$xims_box}{$goxims_content}{$absolute_path}?pub_preview=1')">
                                        Publishing preview
                                    </a>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$goxims_content}{$absolute_path}?m={$m};printview=1">Print view</a>
                                <xsl:if test="$link_pub_preview='true'">
                                    &#160;
                                    <a href="javascript:previewWindow('{$xims_box}{$goxims_content}{$absolute_path}?pub_preview=1')">
                                        Publishing preview
                                    </a>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td align="right">
                <!--<a href="{$xims_box}{$goxims_content}/xims/xims-doku/">-->Systeminfo<!--</a>-->
            </td>
        </tr>
    </xsl:template>
    
</xsl:stylesheet>