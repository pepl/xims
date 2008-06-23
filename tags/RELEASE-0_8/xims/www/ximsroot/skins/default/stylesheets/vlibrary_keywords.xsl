<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004The XIMS Project.
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

    <xsl:variable name="keywordcolumns" select="'3'"/>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body onLoad="setBg('vliteminfo');">
                <xsl:call-template name="header" >
                    <xsl:with-param name="nooptions" select="true"/>
                </xsl:call-template>

                <div id="vlbody">
                    <h1><xsl:value-of select="title"/></h1>
                    <div>
                        <xsl:apply-templates select="abstract"/>
                    </div>
                    <xsl:call-template name="search_switch">
                        <xsl:with-param name="mo" select="'subject'"/>
                    </xsl:call-template>

                    <xsl:apply-templates select="/document/context/vlkeywordinfo"/>

                    <xsl:if test="$m='e' and /document/context/object/user_privileges/create">
                        <div class="vlitemcreate">
                            <xsl:call-template name="vlib_create_action"/>
                        </div>
                     </xsl:if>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="vlkeywordinfo">
        <xsl:variable name="sortedkeywords">
            <xsl:for-each select="/document/context/vlkeywordinfo/keyword">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>

        <table width="600" border="0" align="center" id="vlpropertyinfo">
            <tr><th colspan="{$keywordcolumns}"><xsl:value-of select="$i18n_vlib/l/keywords"/></th></tr>
            <xsl:apply-templates select="exslt:node-set($sortedkeywords)/keyword[(position()-1) mod $keywordcolumns = 0]">
                <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>

    <xsl:template match="keyword">
        <xsl:call-template name="item">
            <xsl:with-param name="mo" select="'keyword'"/>
            <xsl:with-param name="colms" select="$keywordcolumns"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>