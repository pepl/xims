<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_bookmarks.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="user_common.xsl"/>

<xsl:variable name="stdhome">
    <xsl:choose>
        <xsl:when test="/document/context/session/user/bookmarks/bookmark[stdhome=1]/content_id"><xsl:value-of select="/document/context/session/user/bookmarks/bookmark[stdhome=1]/content_id"/></xsl:when>
        <xsl:otherwise>/xims</xsl:otherwise><!-- fallback if there is no defaultbookmark -->
    </xsl:choose>
</xsl:variable>

    <xsl:template match="/document/context/session/user">
        <html>
            <xsl:call-template name="head_default">
								<xsl:with-param name="mode">user</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="noncontent">true</xsl:with-param>
                </xsl:call-template>
                <div id="content-container">

                <h1>
                    <xsl:value-of select="name"/>s <xsl:value-of select="$i18n/l/Bookmarks"/>
                </h1>

                <xsl:apply-templates select="bookmarks"/>
<br/><br/>
                <xsl:call-template name="create_bookmark"/>
<br/>
                <p>
									<xsl:value-of select="$i18n/l/Notice"/>:&#160;<xsl:value-of select="$i18n/l/NoticeDefBookmarks"/></p>
<br/>
                <p class="back">
                    <a href="{$xims_box}{$goxims}/user"><xsl:value-of select="$i18n/l/BackToHome"/></a>
                </p>

            </div>
			<xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>

<xsl:template match="bookmarks">
	<xsl:variable name="countUserBM" select="count(/document/context/session/user/bookmarks/bookmark[owner_id=/document/context/session/user/name])"/>
	<xsl:variable name="countRoleBM" select="count(/document/context/session/user/bookmarks/bookmark[owner_id!=/document/context/session/user/name])"/>
	
    <h2><xsl:value-of select="$i18n/l/User"/>&#160;<xsl:value-of select="$i18n/l/Bookmarks"/></h2>
    <xsl:choose>
					<xsl:when test="$countUserBM">
    <table id="obj-table">
    <thead>
					<tr>
						<th><xsl:value-of select="$i18n/l/Path"/></th>
						<th>&#160;</th>
						<th><xsl:value-of select="$i18n/l/Options"/></th>
					</tr>
				</thead>
				<tbody>
        <xsl:apply-templates select="bookmark[owner_id=/document/context/session/user/name]">
            <xsl:sort select="stdhome" order="descending"/>
            <xsl:sort select="content_id" order="ascending"/>
        </xsl:apply-templates>
        </tbody>
    </table>
    					</xsl:when>
					<xsl:otherwise>
					<xsl:value-of select="$i18n/l/NoBMs"/>
					</xsl:otherwise>
				</xsl:choose>
<br/><br/>
    <h2><xsl:value-of select="$i18n/l/Role"/>&#160;<xsl:value-of select="$i18n/l/Bookmarks"/></h2>
    <xsl:choose>
					<xsl:when test="$countRoleBM">
    <table id="obj-table">
    <thead>
					<tr>
						<th><xsl:value-of select="$i18n/l/Path"/></th>
						<th>&#160;</th>
					</tr>
				</thead>
				<tbody>
        <xsl:apply-templates select="bookmark[owner_id!=/document/context/session/user/name]">
            <xsl:sort select="stdhome" order="descending"/>
            <xsl:sort select="content_id" order="ascending"/>
        </xsl:apply-templates>
     </tbody>
    </table>
        					</xsl:when>
					<xsl:otherwise>
					<xsl:value-of select="$i18n/l/NoBMs"/>
					</xsl:otherwise>
				</xsl:choose>
</xsl:template>

<xsl:template match="bookmark[owner_id=/document/context/session/user/name]">
    <tr>
        <td>
            <!--<span class="bookmarklink"><xsl:call-template name="bookmark_link"/></span>-->
            <span class="sprite sprite-list_SymbolicLink"><xsl:call-template name="bookmark_link"/></span>
        </td>
        <td>
					&#160;
            <xsl:choose>
                <xsl:when test="stdhome != '1'">
                    <a href="{$xims_box}{$goxims}/bookmark?id={id};setdefault=1"><xsl:value-of select="$i18n/l/set_as"/>&#160;<xsl:value-of select="$i18n/l/default_bookmark"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$i18n/l/default_bookmark"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
        &#160;<a class="sprite sprite-option_purge" href="{$xims_box}{$goxims}/bookmark?id={id};delete=1">&#160;<span><xsl:value-of select="$i18n/l/purge"/></span>&#160;</a>
        </td>
    </tr>
</xsl:template>

<xsl:template match="bookmark[owner_id!=/document/context/session/user/name]">
    <tr>
        <td>
            <span class="sprite sprite-list_SymbolicLink"><xsl:call-template name="bookmark_link"/></span>
        </td>
        <td>
					&#160;
            <xsl:if test="stdhome = '1'">
                <xsl:value-of select="$i18n/l/default_bookmark"/>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

<!--<xsl:template name="bookmark_link">
    <xsl:choose>
        <xsl:when test="content_id != ''">
            <a href="{$xims_box}{$goxims_content}{content_id}"><xsl:value-of select="content_id"/></a>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$xims_box}{$goxims_content}/">/root</a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>-->

</xsl:stylesheet>
