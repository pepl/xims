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

<xsl:param name="page" select="0" />
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                Search for '<xsl:value-of select="$s"/>' - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
            <xsl:call-template name="header">
                <xsl:with-param name="nooptions">true</xsl:with-param>
                <xsl:with-param name="nostatus">true</xsl:with-param>
            </xsl:call-template>

            <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                <xsl:call-template name="tableheader"/>
                <xsl:apply-templates select="/document/objectlist/object">
                    <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
                </xsl:apply-templates>

            </table>

            <xsl:if test="number($page) &gt; 0 or count(/document/objectlist/object) &gt;= $searchresultrowlimit">
                <table style="margin-left:5px; margin-right:10px; margin-top: 10px; width: 99%; padding: 3px; border: thin solid #C1C1C1; background: #F9F9F9 font-size: small;" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <xsl:if test="number($page) &gt; 0">
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?s={$s};search=1;m={$m};page={number($page)-1}">&lt; Previous Page</a>
                            </xsl:if>
                            <xsl:if test="number($page) &gt; 0 and count(/document/objectlist/object) &gt;= $searchresultrowlimit">
                                |
                            </xsl:if>
                            <!-- sth like /document/context/session/searchresultcount is needed instead of count(/document/objectlist/object) here to avoid a next link if hit count == rowlimit-->
                            <xsl:if test="count(/document/objectlist/object) &gt;= $searchresultrowlimit">
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?s={$s};search=1;m={$m};page={number($page)+1}">&gt; Next Page</a>
                            </xsl:if>
                        </td>
                    </tr>
                </table>
            </xsl:if>
        </body>
    </html>
</xsl:template>


<xsl:template name="tableheader">
    <tr>
<!-- status -->
    <td width="86">
        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                width="86"
                height="20"
                border="0"
                alt="Status"
                title="Status Information"
        />
    </td>
<!-- score -->
    <!--
    <td width="47">
            <img src="{$ximsroot}skins/{$currentskin}/images/score.png"
                    width="47"
                    height="20"
                    border="0"
                    alt="Score"
                    title="Score: higher numbers represent a better match for your query"
            />
    </td>
    -->
<!-- title -->
    <td width="51">
        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title.png" width="45" height="20" border="0" />
    </td>
    <td width="100%" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg.png">
        <img src="{$ximsroot}images/spacer_white.gif"
                width="50"
                height="1"
                border="0"
                alt="Title"
                title="Title"
        />
    </td>
    <td width="23">
        <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner.png"
                width="23"
                height="20"
                alt=""
        />
    </td>
<!-- last modified -->
    <td width="124">
        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified.png"
                width="124"
                height="20"
                border="0"
                alt="Last modified"
                title="Last modified"
        />
    </td>
<!-- size -->
    <td width="80">
        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                width="80"
                height="20"
                border="0"
                alt="Size"
                title="Size in kB"
        />
    </td>
    </tr>
</xsl:template>

<xsl:template match="objectlist/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>

    <tr height="20">
<!-- status -->
        <td width="86">
            <img src="{$ximsroot}images/spacer_white.gif" width="6" height="20" border="0" alt="" />
            <xsl:choose>
                <xsl:when test="marked_new= '1'">
                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status_markednew.png"
                            border="0"
                            width="26"
                            height="19"
                            alt="New"
                            title="This object is marked as new."
                    />
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$ximsroot}images/spacer_white.gif"
                            width="26"
                            height="19"
                            border="0"
                            alt=""
                    />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="published = '1'">
                    <img
                        border="0"
                        width="26"
                        height="19"
                        alt="Published"
                        >
                        <xsl:choose>
                            <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                                <xsl:attribute name="title">This object has last been published at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> by <xsl:call-template name="lastpublisherfullname"/></xsl:attribute>
                                <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub.png</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="title">This object has been modified since the last publication by <xsl:call-template name="lastpublisherfullname"/> at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>.</xsl:attribute>
                                <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub_async.png</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$ximsroot}images/spacer_white.gif"
                            width="26"
                            height="19"
                            border="0"
                            alt=""
                    />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="locked_time != '' and locked_by = /document/session/user/@id">
                    <img src="{$ximsroot}skins/{$currentskin}/images/status_locked.png"
                            width="26"
                            height="19"
                            border="0"
                            alt="Unlock">
                        <xsl:attribute name="title">This object has been locked by you at <xsl:apply-templates select="locked_time" mode="datetime"/>.</xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:when test="locked_time != ''">
                    <img src="{$ximsroot}skins/{$currentskin}/images/status_locked.png"
                            width="26"
                            height="19"
                            border="0"
                            alt="Locked">
                        <xsl:attribute name="title">This object has been locked at <xsl:apply-templates select="locked_time" mode="datetime"/> by <xsl:call-template name="lockerfullname"/>.</xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$ximsroot}images/spacer_white.gif"
                            width="26"
                            height="19"
                            border="0"
                            alt=""
                    />
                </xsl:otherwise>
            </xsl:choose>
        </td>
<!-- score -->
<!--
        <td width="47" align="right">
                <xsl:value-of select="score_1__s"/>
        </td>
-->
<!-- dataformat icon -->
        <td width="34" bgcolor="#eeeeee">
            <img src="{$ximsroot}images/spacer_white.gif" width="12" height="20" border="0" alt="" />
            <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif"
                    border="0"
                    alt="{/document/data_formats/data_format[@id=$dataformat]/name}"
                    title="{/document/data_formats/data_format[@id=$dataformat]/name}"
            />
        </td>

<!-- title -->
        <td colspan="2" bgcolor="#eeeeee" background="{$ximsroot}skins/{$currentskin}/images/containerlist_bg.gif">
            <a>
                <xsl:choose>
                    <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='Container'">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($goxims_content,'?id=',@id,';sb=',$sb,';order=',$order,';m=',$m)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat(location,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m)"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="title" />
            </a>
            <br/>
            <xsl:value-of select="abstract"/>
        </td>

<!-- last modification -->
        <td>
            <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
            <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
        </td>

<!-- size -->
        <td align="right">
            <!-- we may put /document/data_formats/data_format[@id=$dataformat]/name into a var or
            find a better way to do this (OT property "hasloblength" for example)
            -->
            <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/mime_type!='application/x-container'
                    and /document/data_formats/data_format[@id=$dataformat]/name!='URL'
                    and /document/data_formats/data_format[@id=$dataformat]/name!='SymbolicLink' ">
                <xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
                <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
            </xsl:if>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
