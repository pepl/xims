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
    <xsl:output method="xml"
                encoding="utf-8"
                media-type="text/html"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                indent="no"/>

    <xsl:variable name="publicationcolumns" select="'3'"/>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header" />
                <xsl:apply-templates select="/document/context/vlpublicationinfo"/>
                <xsl:call-template name="switch_vlib_views_action">
                    <xsl:with-param name="mo" select="'publication'"/>    
                </xsl:call-template>
                <xsl:call-template name="vlib_create_action"/>
                <table align="center" width="98.7%" class="footer">
                    <xsl:call-template name="footer"/>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="vlpublicationinfo">
        <xsl:variable name="sortedpublications">
            <xsl:for-each select="/document/context/vlpublicationinfo/publication">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>

        <table width="600" align="center">
            <tr>
                <th colspan="3">
                    <xsl:value-of select="$i18n_vlib/l/publications"/>
                </th>
            </tr>
            <xsl:apply-templates select="exslt:node-set($sortedpublications)/publication[(position()-1) mod $publicationcolumns = 0]">
                <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>

    <xsl:template match="publication">
        <xsl:call-template name="item">
            <xsl:with-param name="mo" select="'publication'"/>
            <xsl:with-param name="colms" select="$publicationcolumns"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>
