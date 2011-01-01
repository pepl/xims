<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:variable name="stdhome">
    <xsl:choose>
        <xsl:when test="/document/context/session/user/bookmarks/bookmark[stdhome=1]/content_id"><xsl:value-of select="/document/context/session/user/bookmarks/bookmark[stdhome=1]/content_id"/></xsl:when>
        <xsl:otherwise>/xims</xsl:otherwise><!-- fallback if there is no defaultbookmark -->
    </xsl:choose>
</xsl:variable>


<xsl:template name="create_bookmark">
    <h2><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$i18n/l/Bookmark"/></h2>
        <form action="{$xims_box}{$goxims}/bookmark" name="eform">
            <p>
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
            <input type="submit" class="control" name="create" value="{$i18n/l/create}"/>
            </p>
        </form>
</xsl:template>


  <xsl:template match="bookmarks">
    <h2><xsl:value-of select="$i18n/l/User"/>&#160;<xsl:value-of select="$i18n/l/Bookmarks"/></h2>   
    <table cellpadding="3">
      <xsl:choose>
        <xsl:when test="count(bookmark[owner_id=/document/context/session/user/name])&gt;0">  
          <xsl:apply-templates select="bookmark[owner_id=/document/context/session/user/name]">
              <xsl:sort select="stdhome" order="descending"/>
              <xsl:sort select="content_id" order="ascending"/>
           </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
           <tr><td colspan="2"><xsl:value-of select="$i18n/l/No_results"/></td></tr>
        </xsl:otherwise>
      </xsl:choose>
    </table>
    <h2><xsl:value-of select="$i18n/l/Role"/>&#160;<xsl:value-of select="$i18n/l/Bookmarks"/></h2>
    <table cellpadding="3">
      <xsl:choose>
        <xsl:when test="count(bookmark[owner_id!=/document/context/session/user/name])&gt;0">
          <xsl:apply-templates select="bookmark[owner_id!=/document/context/session/user/name]">
            <xsl:sort select="stdhome" order="descending"/>
            <xsl:sort select="content_id" order="ascending"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
           <tr><td colspan="2"><xsl:value-of select="$i18n/l/No_results"/></td></tr>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </xsl:template>

<xsl:template match="bookmark[owner_id=/document/context/session/user/name]">
    <tr class="objrow">
       <td width="400" valign="top">
         <span class="sprite-list sprite-list_Bookmark">
           <span>Bookmark</span>&#xa0;
         </span>
            <xsl:call-template name="bookmark_link"/>
        </td>
        <td valign="top">
            <xsl:choose>
                <xsl:when test="stdhome != '1'">
                    <a href="{$xims_box}{$goxims}/bookmark?id={id};setdefault=1"><xsl:value-of select="$i18n/l/set_as"/>&#160;<xsl:value-of select="$i18n/l/default_bookmark"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$i18n/l/default_bookmark"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>&#160;
            <a href="{$xims_box}{$goxims}/bookmark?id={id};delete=1" 
               class="sprite-list sprite-option_purge"
               title="{$l_purge}">&#160;
               <span><xsl:value-of select="$l_purge"/></span>
            </a>
        </td>
    </tr>
</xsl:template>

<xsl:template match="bookmark[owner_id!=/document/context/session/user/name]">
    <tr class="objrow">
        <td width="400" valign="top">
            <span class="sprite-list sprite-list_Bookmark">
              <span>Bookmark</span>&#xa0;
            </span>
            <xsl:call-template name="bookmark_link"/>
        </td>
        <td valign="top">
            <xsl:if test="stdhome = '1'">
                <xsl:value-of select="$i18n/l/default_bookmark"/>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

<xsl:template name="bookmark_link">
    <xsl:choose>
        <xsl:when test="content_id != ''">
            <a href="{$xims_box}{$goxims_content}{content_id}"><xsl:value-of select="content_id"/></a>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$xims_box}{$goxims_content}/">/root</a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
