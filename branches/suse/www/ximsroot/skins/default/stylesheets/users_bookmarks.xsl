<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-200% The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:param name="name"/>

<xsl:variable name="stdhome">
    <xsl:choose>
        <xsl:when test="/document/bookmarklist/bookmark[stdhome=1]/content_id"><xsl:value-of select="/document/bookmarklist/bookmark[stdhome=1]/content_id"/></xsl:when>
        <xsl:otherwise>/xims</xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:template match="/document">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            <div id="content">

                <h1>
                    <xsl:value-of select="$name"/>'s <xsl:value-of select="$i18n/l/Bookmarks"/>
                </h1>
    
                <xsl:apply-templates select="bookmarklist"/>
    
                <xsl:call-template name="create_bookmark"/>
    
                <p class="back">
                    <a href="{$xims_box}{$goxims}/users?sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Back"/></a>
                </p>

            </div>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template name="create_bookmark">
    <h2><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$i18n/l/Bookmark"/></h2>
    <p>
        <form action="{$xims_box}{$goxims}/bookmark" name="eform" method="GET">
            <xsl:value-of select="$i18n/l/Path"/>: <input type="text" name="path" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Bookmark')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$stdhome}?contentbrowse=1;sbfield=eform.path')" class="doclink"><xsl:value-of select="$i18n/l/Browse_for"/>&#160;<xsl:value-of select="$i18n/l/Object"/></a>
            <br/>
            <xsl:value-of select="$i18n/l/Set_as"/>&#160;<xsl:value-of select="$i18n/l/default_bookmark"/>: <input type="checkbox" class="text" name="stdhome" value="1"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('DefaultBookmark')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <br/>
            <input type="hidden" name="name" value="{$name}"/>
            <input name="sort-by" type="hidden" value="{$sort-by}"/>
            <input name="order-by" type="hidden" value="{$order-by}"/>
            <input name="userquery" type="hidden" value="{$userquery}"/>
            <input type="submit" class="control" name="create" value="{$i18n/l/create}"/>
        </form>
    </p>
</xsl:template>

<xsl:template match="bookmarklist">
            <h2><xsl:value-of select="$i18n/l/Bookmarks"/></h2>
            <table cellpadding="3">
                <xsl:apply-templates select="bookmark">
                    <xsl:sort select="stdhome" order="descending"/>
                    <xsl:sort select="content_id" order="ascending"/>
                </xsl:apply-templates>
            </table>
</xsl:template>

<xsl:template match="bookmark">
    <tr>
        <td width="400" valign="top">
            <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="SymbolicLink" title="SymbolicLink"/>&#160;
            <a href="{$xims_box}{$goxims_content}{content_id}"><xsl:value-of select="content_id"/></a>
        </td>
        <td valign="top">
            <xsl:choose>
                <xsl:when test="stdhome != '1'">
                    <a href="{$xims_box}{$goxims}/bookmark?id={id};setdefault=1;name={$name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/set_as"/>&#160;<xsl:value-of select="$i18n/l/default_bookmark"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$i18n/l/default_bookmark"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
            &#160;
            <a href="{$xims_box}{$goxims}/bookmark?id={id};delete=1;name={$name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
                <img
                    src="{$skimages}option_purge.png"
                    border="0"
                    width="37"
                    height="19"
                    alt="{$l_purge}"
                    title="{$l_purge}"
                />
            </a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
