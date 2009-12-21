<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-200% The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_bookmarks.xsl 2171 2008-12-26 15:28:33Z pepl $
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
            <xsl:call-template name="head_default">
								<xsl:with-param name="mode">user</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="noncontent">true</xsl:with-param>
                </xsl:call-template>
                <div id="content-container">

                <h1 class="bluebg">
                    <xsl:value-of select="$name"/>s <xsl:value-of select="$i18n/l/Bookmarks"/>
                </h1>

                <xsl:apply-templates select="bookmarklist"/>
<br/><br/>
                <xsl:call-template name="create_bookmark">
									<xsl:with-param name="admin">true</xsl:with-param>
                </xsl:call-template>
<br/><br/>
                <p class="back">
                    <a href="{$xims_box}{$goxims}/users?sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Back"/></a>
                </p>

            </div>
            </body>
        </html>

</xsl:template>

<xsl:template match="bookmarklist">
            <h2><xsl:value-of select="$i18n/l/Bookmarks"/></h2>
                <table id="obj-table">
    <thead>
					<tr>
						<th><xsl:value-of select="$i18n/l/Path"/></th>
						<th>&#160;</th>
						<th><xsl:value-of select="$i18n/l/Options"/></th>
					</tr>
				</thead>
				<tbody>
        <xsl:apply-templates select="bookmark">
            <xsl:sort select="stdhome" order="descending"/>
            <xsl:sort select="content_id" order="ascending"/>
        </xsl:apply-templates>
        </tbody>
    </table>
</xsl:template>

<xsl:template match="bookmark">
    <tr>
        <td>
            <span class="bookmarklink"><xsl:call-template name="bookmark_link"/></span>
        </td>
        <td>
					&#160;
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
            <a class="sprite sprite-option_purge" href="{$xims_box}{$goxims}/bookmark?id={id};delete=1;name={$name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
             <span><xsl:value-of select="$i18n/l/purge"/></span>&#160;</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
