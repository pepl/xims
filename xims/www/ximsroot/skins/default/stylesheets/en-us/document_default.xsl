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
    
    <!-- firstlevel folders are considered to be 'sites' -->
    <xsl:variable name="site_location"><xsl:choose><xsl:when test="$resolvereltositeroots = 1">/<xsl:value-of select="/document/context/object/parents/object[@parent_id = '1' and @id != '1']/location"/></xsl:when><xsl:otherwise>/</xsl:otherwise></xsl:choose></xsl:variable>

    <xsl:output method="html" encoding="UTF-8"/>
    
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>
    
    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title><xsl:value-of select="title"/> - Document - XIMS</title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
                <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            </head>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
                <!-- poor man's stylechooser -->
                <xsl:choose>
                    <xsl:when test="$printview != '0'">
                        <xsl:call-template name="document-metadata"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="header"/>
                    </xsl:otherwise>
                </xsl:choose>
                <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px; background: #ffffff">
                    <tr>
                        <td colspan="2">
                            <xsl:apply-templates select="body"/>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" width="50%" style="border:1px solid;">
                           <table width="100%" border="0">
                                <tr>
                                    <td width="60%"><b>Document Links</b></td>
                                    <xsl:if test="$m='e' and user_privileges/create">
                                    <td width="40%" colspan="2" align="right">
                                            <a href="{$goxims_content}{$absolute_path}?create=1;parid={@document_id};objtype=URLLink">add link</a>
                                            <xsl:text>&#160;&#160;</xsl:text>
                                    </td>
                                    </xsl:if>
                               </tr>
                               <tr>
                                  <td colspan="3"><xsl:text>&#160;</xsl:text></td>
                               </tr>
                               <xsl:apply-templates select="children/object" mode="link"/>
                            </table>
                        </td>
                        <td valign="top" width="50%" style="border:1px solid;">
                            <table width="100%" border="0">
                                <tr>
                                    <td width="60%"><b>Annotation</b></td>
                                    <td width="40%" colspan="2" align="right">
                                        <xsl:if test="$m='e' and user_privileges/create">
                                            <!--<a href="{$goxims_content}{$absolute_path}?create=1;parid={@document_id};objtype=Annotation">-->add annotation<!--</a>-->
                                            <xsl:text>&#160;&#160;</xsl:text>
                                        </xsl:if>
                                    </td>
                                </tr>
                                <tr>
                                      <td colspan="3"><xsl:text>&#160;</xsl:text></td>
                                </tr>
                                <xsl:apply-templates select="children/object" mode="comment"/>
                            </table>
                        </td>
                    </tr>
                </table>
                <table align="center" width="98.7%" class="footer">
                    <xsl:call-template name="user-metadata"/>
                    <xsl:call-template name="footer">
                        <xsl:with-param name="link_pub_preview">true</xsl:with-param>
                    </xsl:call-template>
                </table>  
                <xsl:choose>
                    <xsl:when test="/document/context/object/user_privileges/write and /document/context/object/locked_time = '' or /document/context/object/locked_by = /document/session/user/@id">
                        <a style="margin-left:10px;" href="{$goxims_content}{$absolute_path}?edit=1;plain=1">Edit without WYSIWYG-Editor</a>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="a">
        <a>
            <xsl:choose>
                <xsl:when test="$printview != '0'">
                    <xsl:value-of select="."/><xsl:text>&#160;</xsl:text>[<xsl:value-of select="@href"/>]
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@href != ''">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="starts-with(@href,'/') and not(starts-with(@href,$goxims_content))">
                                    <xsl:value-of select="concat($goxims_content,$site_location,@href)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@href"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="title">
                        <xsl:choose>
                            <xsl:when test="@title != ''">
                                <xsl:value-of select="@title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="@target != ''">
                        <xsl:attribute name="target">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@name != ''">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@name"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@id != ''">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@class != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="@class"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>

    <xsl:template match="img">
        <img>
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="starts-with(@src,'/') and not(starts-with(@src,$goxims_content))">
                        <xsl:value-of select="concat($goxims_content,$site_location,@src)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@src"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="@title != ''">
                <xsl:attribute name="title">
                    <xsl:value-of select="@title"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@alt != ''">
                <xsl:attribute name="alt">
                    <xsl:value-of select="@alt"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@width != ''">
                <xsl:attribute name="width">
                    <xsl:value-of select="@width"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@height != ''">
                <xsl:attribute name="height">
                    <xsl:value-of select="@height"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@border != ''">
                <xsl:attribute name="border">
                    <xsl:value-of select="@border"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@align != ''">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="@class"/>
                </xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>

</xsl:stylesheet>

