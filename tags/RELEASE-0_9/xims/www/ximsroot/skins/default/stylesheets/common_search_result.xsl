<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="container_common.xsl"/>
<xsl:param name="page" select="1" />
<xsl:variable name="pagesperpagenav" select="10" />

<xsl:variable name="objectitems_count">
    <xsl:value-of select="/document/context/session/searchresultcount"/>
</xsl:variable>
<xsl:variable name="totalpages" select="ceiling($objectitems_count div $searchresultrowlimit)"/>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Search_for"/> '<xsl:value-of select="$s"/>' - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
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

            <xsl:if test="$totalpages &gt; 1">
                <table style="margin-left:5px; margin-right:10px; margin-top: 10px; margin-bottom: 10px; width: 99%; padding: 3px; border: thin solid #C1C1C1; background: #F9F9F9 font-size: small;" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <xsl:call-template name="pagenav">
                                <xsl:with-param name="totalitems" select="/document/context/session/searchresultcount"/>
                                <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
                                <xsl:with-param name="currentpage" select="$page"/>
                                <xsl:with-param name="url"
                                                select="concat($xims_box,$goxims_content,$absolute_path,'?s=',$s,';search=1;start_here=',$start_here,';m=',$m)"/>
                            </xsl:call-template>
                        </td>
                    </tr>
                </table>
            </xsl:if>
        </body>
    </html>
</xsl:template>

<xsl:template name="pagenav">
    <xsl:param name="totalitems"/>
    <xsl:param name="itemsperpage"/>
    <xsl:param name="currentpage"/>
    <xsl:param name="url"/>

    <xsl:if test="$totalpages &gt; 1">
        <div id="pagenav">
            <div>
                <xsl:if test="$currentpage &gt; 1">
                    <a href="{$url};page={number($currentpage)-1}">&lt; <xsl:value-of select="$i18n/l/Previous_page"/></a>
                </xsl:if>
                <xsl:if test="$currentpage &gt; 1 and $currentpage &lt; $totalpages">
                    |
                </xsl:if>
                <xsl:if test="$currentpage &lt; $totalpages">
                    <a href="{$url};page={number($currentpage)+1}">&gt; <xsl:value-of select="$i18n/l/Next_page"/></a>
                </xsl:if>
            </div>
            <div>
                <xsl:call-template name="pageslinks">
                    <xsl:with-param name="page" select="1"/>
                    <xsl:with-param name="current" select="$currentpage"/>
                    <xsl:with-param name="total" select="$totalpages"/>
                    <xsl:with-param name="url" select="$url"/>
                </xsl:call-template>
            </div>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="pageslinks">
    <xsl:param name="page"/>
    <xsl:param name="current"/>
    <xsl:param name="total"/>
    <xsl:param name="url"/>

    <xsl:choose>
        <xsl:when test="$page = $current">
            <strong><a href="{$url};page={$page}"><xsl:value-of select="$page" /></a></strong>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$url};page={$page}"><xsl:value-of select="$page" /></a>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:text> </xsl:text>

    <xsl:if test="$page &lt; $total and $page &lt; ($current + $pagesperpagenav)">
        <xsl:call-template name="pageslinks">
            <xsl:with-param name="page" select="$page + 1" />
            <xsl:with-param name="current" select="$current" />
            <xsl:with-param name="total" select="$total" />
            <xsl:with-param name="url" select="$url" />
        </xsl:call-template>
    </xsl:if>

    <xsl:if test="$page = ($current + $pagesperpagenav)">
    ...
    </xsl:if>

</xsl:template>


<xsl:template name="tableheader">
    <tr>
<!-- status -->
    <td width="86">
        <img src="{$skimages}{$currentuilanguage}/status.png"
                width="86"
                height="20"
                border="0"
                alt="{$i18n/l/Status}"
                title="{$i18n/l/Status}"
                />
    </td>
<!-- score -->
    <!--
    <td width="47">
            <img src="{$skimages}score.png"
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
        <img src="{$skimages}{$currentuilanguage}/title.png" width="45" height="20" border="0" />
    </td>
    <td width="100%" background="{$skimages}titlecolumn_bg.png">
        <img src="{$ximsroot}images/spacer_white.gif"
                width="50"
                height="1"
                border="0"
                alt="{$i18n/l/Title}"
                title="{$i18n/l/Title}"
        />
    </td>
    <td width="23">
        <img src="{$skimages}titlecolumn_rightcorner.png"
                width="23"
                height="20"
                alt=""
        />
    </td>
<!-- last modified -->
    <td width="124">
        <img src="{$skimages}{$currentuilanguage}/last_modified.png"
                width="124"
                height="20"
                border="0"
                alt="{$i18n/l/Last_modified}"
                title="{$i18n/l/Last_modified}" />
    </td>
<!-- size -->
    <td width="80">
        <img src="{$skimages}{$currentuilanguage}/size.png"
                width="80"
                height="20"
                border="0"
                alt="{$i18n/l/Size}"
                title="{$i18n/l/Size} {$i18n/l/in} kB"
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
                    <img src="{$skimages}{$currentuilanguage}/status_markednew.png"
                            border="0"
                            width="26"
                            height="19"
                            title="{$i18n/l/Object_marked_new}"
                            alt="{$i18n/l/New}"
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
                        alt="{$i18n/l/Published}"
                    >
                        <xsl:choose>
                            <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                                <xsl:attribute name="title"><xsl:value-of select="$i18n/l/Object_last_published"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$i18n/l/by"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$i18n/l/at_place"/>&#160;<xsl:value-of select="concat($publishingroot,$absolute_path)"/></xsl:attribute>
                                <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub.png</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="title"><xsl:value-of select="$i18n/l/Object_modified"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$i18n/l/changed"/>.</xsl:attribute>
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
                <xsl:when test="locked_by_id != '' and locked_time != '' and locked_by_id = /document/context/session/user/@id">
                    <img src="{$skimages}status_locked.png"
                            width="26"
                            height="19"
                            border="0"
                            alt="{$i18n/l/Unlock}"
                            title="{$i18n/l/Release_lock}."
                    />
                </xsl:when>
                <xsl:when test="locked_by_id != '' and locked_time != ''">
                    <img src="{$skimages}status_locked.png"
                            width="26"
                            height="19"
                            border="0"
                            alt="{$i18n/l/Locked}"
                    >
                        <xsl:attribute name="title"><xsl:value-of select="$i18n/l/Object_locked"/> <xsl:apply-templates select="locked_time" mode="datetime"/> <xsl:value-of select="$i18n/l/by"/> <xsl:call-template name="lockerfullname"/> <xsl:value-of select="$i18n/l/locked"/>.</xsl:attribute>
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
        <td width="34">
            <xsl:call-template name="cttobject.dataformat"/>
        </td>
<!-- title -->
        <td colspan="2" bgcolor="#eeeeee" background="{$skimages}containerlist_bg.gif">
            <span>
                <xsl:attribute name="title">id: <xsl:value-of select="@id"/>, <xsl:value-of select="$i18n/l/location"/>: <xsl:value-of
        select="location"/>, <xsl:value-of select="$i18n/l/created_by"/>: <xsl:call-template name="creatorfullname"/>, <xsl:value-of select="$i18n/l/owned_by"/> <xsl:call-template name="ownerfullname"/></xsl:attribute>
                <a>
                <xsl:choose>
                    <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='Container'">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($goxims_content,'?id=',@id,';sb=',$sb,';order=',$order,';m=',$m,';hls=',$s)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat(location,'?sb=',$sb,';order=',$order,';m=',$m,';hls=',$s)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m,';hls=',$s)"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="title" />
            </a>
            </span>
            <br/>
            <xsl:value-of select="abstract"/>
        </td>
<!-- last modification -->
        <td>
            <xsl:call-template name="cttobject.last_modified"/>
        </td>
<!-- size -->
        <td align="right">
            <xsl:call-template name="cttobject.content_length"/>
            <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt=" " />
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
