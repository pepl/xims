<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common">

    <xsl:param name="vls"/>

    <xsl:output method="xml"
                encoding="utf-8"
                media-type="text/html"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                indent="no"/>

    <xsl:variable name="subjectcolumns" select="'3'"/>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header" />
                <h1><xsl:value-of select="title"/></h1>
                <xsl:apply-templates select="/document/context/vlsubjectinfo"/>
                <xsl:call-template name="switch_vlib_views_action">
                    <xsl:with-param name="mo" select="'subject'"/>
                </xsl:call-template>

                <div>
                    <xsl:call-template name="vlib_create_action"/>
                </div>

                <div>
                    <xsl:call-template name="vlib_search_action"/>
                </div>

                <table align="center" width="98.7%" class="footer">
                    <xsl:call-template name="footer"/>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="vlsubjectinfo">
        <xsl:variable name="sortedsubjects">
            <xsl:for-each select="/document/context/vlsubjectinfo/subject">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>

        <table width="600" align="center">
            <tr><th colspan="{$subjectcolumns}"><xsl:value-of select="$i18n_vlib/l/subjects"/></th></tr>
            <xsl:apply-templates select="exslt:node-set($sortedsubjects)/subject[(position()-1) mod $subjectcolumns = 0]">
                <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>

    <xsl:template match="subject">
        <xsl:call-template name="item">
            <xsl:with-param name="mo" select="'subject'"/>
            <xsl:with-param name="colms" select="$subjectcolumns"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="vlib_search_action">
        <xsl:variable name="Search" select="$i18n/l/Search"/>
        <form style="margin-bottom: 0;" action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" name="vlib_search">
            <table border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td nowrap="nowrap">
                        <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" type="text" name="vls" size="17" maxlength="200">
                        <xsl:choose>
                            <xsl:when test="$vls != ''">
                                <xsl:attribute name="value"><xsl:value-of select="$vls"/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value">[<xsl:value-of select="$Search"/>]</xsl:attribute>
                                <xsl:attribute name="onfocus">document.vlib_search.vls.value=&apos;&apos;;</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        </input>
                        <xsl:text>&#160;</xsl:text>
                        <input type="image"
                                src="{$sklangimages}search.png"
                                name="submit"
                                width="65"
                                height="14"
                                alt="{$Search}"
                                title="{$Search}"
                                border="0"
                        />
                        <input type="hidden" name="start_here" value="1"/>
                        <input type="hidden" name="vlsearch" value="1"/>
                    </td>
                </tr>
            </table>
        </form>
    </xsl:template>

</xsl:stylesheet>
