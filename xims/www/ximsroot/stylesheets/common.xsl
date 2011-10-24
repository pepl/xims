<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:import href="config.xsl"/>
	
	<xsl:variable name="currentuilanguage"><xsl:value-of select="/document/context/session/uilanguage"/></xsl:variable>
	<xsl:variable name="skimages" select="concat($ximsroot,'skins/',$currentskin,'/images/')"/>
	<xsl:variable name="sklangimages" select="concat($skimages,$currentuilanguage,'/')"/>
	
	<xsl:variable name="absolute_path"><xsl:call-template name="pathinfoinit"/></xsl:variable>
	<xsl:variable name="absolute_path_nosite"><xsl:call-template name="pathinfoinit_nosite"/></xsl:variable>
	<xsl:variable name="parent_path"><xsl:call-template name="pathinfoparent"/></xsl:variable>
	<xsl:variable name="parent_path_nosite"><xsl:call-template name="pathinfoparent_nosite"/></xsl:variable>
	
	<xsl:variable name="publishingroot">
		<xsl:choose>
			<xsl:when test="/document/context/object/parents/object[@parent_id = '1']/title">
				<xsl:value-of select="/document/context/object/parents/object[@parent_id = '1']/title"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/document/context/object/title"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:param name="sb" select="'position'"/>
	<xsl:param name="order" select="'asc'"/>
	<xsl:param name="defsorting">0</xsl:param>
	<xsl:param name="m" select="'e'"/>
	<xsl:param name="r"/>
	<xsl:param name="hd">
		<xsl:choose>
			<xsl:when test="count(/document/context/object/children/object[marked_deleted != '1'])=0">0</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="page" select="1"/>
	<xsl:param name="showtrashcan" select="0"/>
	
	<xsl:param name="printview" select="'0'"/>
	<xsl:param name="default"/>
	<xsl:param name="edit"/>
	<xsl:param name="objtype">
		<xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/>
	</xsl:param>
	<xsl:param name="create.x"/>
	<xsl:param name="create"/>
	<xsl:param name="s"/>
	<xsl:param name="start_here"/>
	<xsl:param name="hls"/>
	<xsl:param name="message" select="/document/context/session/message/text()"/>
	<xsl:param name="warning_msg" select="/document/context/session/warning_msg/text()"/>
	<xsl:param name="error_msg" select="/document/context/session/error_msg/text()"/>
	
	<xsl:template match="/document">
		<xsl:apply-templates select="context/object"/>
	</xsl:template>
	
	<xsl:template name="pathinfoinit">
		<xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>
		<xsl:if test="/document/context/object/@document_id != 1">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="/document/context/object/location"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="pathinfoinit_nosite">
		<xsl:for-each select="/document/context/object/parents/object[@parent_id &gt; 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>
		<xsl:if test="/document/context/object[@parent_id &gt; 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="/document/context/object/location"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="pathinfoparent">
		<xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="pathinfoparent_nosite">
		<xsl:for-each select="/document/context/object/parents/object[@parent_id &gt; 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="parentpath">
		<xsl:for-each select="preceding-sibling::object[@document_id != 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>
	</xsl:template>
	
	<!-- is used in common_move.xsl, common_contentbrowse.xsl, common_contentbrowse_ewebeditimage.xsl -->
	<xsl:template name="targetpath">
		<xsl:for-each select="/document/context/object/targetparents/object[@document_id != 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>/<xsl:value-of select="/document/context/object/target/object/location"/>
	</xsl:template>
	
	<!-- used in urllink-contentbrowse, returns the absolute path of target
	  only working as long as the title of the siteroot is named something like "http://www.uibk.ac.at"-->
	<xsl:template name="targetpath_abs">
		<xsl:for-each select="/document/context/object/targetparents/object[@document_id != 1]">
			<xsl:choose>
				<xsl:when test="@document_id = 2">
					<xsl:value-of select="title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="location"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>/<xsl:value-of select="/document/context/object/target/object/location"/>
	</xsl:template>
	
	<xsl:template name="targetpath_nosite">
		<xsl:for-each select="/document/context/object/targetparents/object[@parent_id &gt; 1]">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="location"/>
		</xsl:for-each>
		<xsl:if test="/document/context/object/target/object[@parent_id &gt; 1]">/<xsl:value-of select="/document/context/object/target/object/location"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="departmentpath">
		<xsl:value-of select="substring(/document/context/object/parents/object[@document_id = /document/context/object/department_id]/location_path, string-length(/document/context/object/parents/object[object_type_id = 19]/location_path) +1)"/>
	</xsl:template>
	
	<xsl:template match="/document/context/object/parents/object">
		<xsl:param name="no_navigation_at_all">false</xsl:param>
		<xsl:variable name="thispath">
			<xsl:call-template name="parentpath"/>
		</xsl:variable>
		<xsl:if test="$no_navigation_at_all = 'false'">
        / <a class="" href="{$goxims_content}{$thispath}/{location}?m={$m}">
				<xsl:value-of select="location"/>
			</a>
		</xsl:if>
	</xsl:template>
	<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6    |i|u|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|
    dl|dt|dd|li|ol|ul|
    a|
    img|map|area|
    caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|
    button|fieldset|form|label|legend|input|option|optgroup|select|textarea|
    applet|object|param|embed|script|iframe">
		<xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:for-each select="@*">
				<xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="head_default">
		<head>
			<title>
				<xsl:call-template name="title"/>
			</title>
			<xsl:call-template name="css"/>
			<xsl:call-template name="script_head"/>
		</head>
	</xsl:template>
	<xsl:template name="title">
		<xsl:value-of select="title"/> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - <xsl:call-template name="department_title"/> - XIMS
	</xsl:template>
	
	<xsl:template name="css">
		<!-- defmin.css generated by xims_minimize_jscss.pl-->
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/defmin.css" type="text/css"/>
	</xsl:template>
	
	<xsl:template name="script_head">
		<script src="{$ximsroot}scripts/default.js" type="text/javascript">
			<xsl:text>&#160;</xsl:text>
		</script>  
        <script language="javascript" src="{$jquery}" type="text/javascript"/>
	</xsl:template>
	
	<xsl:template name="script_bottom">
		<!-- defmin.js generated by xims_minimize_jscss.pl -->
		<script src="{$ximsroot}skins/{$currentskin}/scripts/defmin.js" type="text/javascript">
			<xsl:text>&#160;</xsl:text>
		</script>		
	</xsl:template>
	
	<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date" mode="time">
		<xsl:value-of select="./hour"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="./minute"/>
	</xsl:template>
	
	<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date" mode="ISO8601">
		<xsl:value-of select="./year"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="./month"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="./day"/>
		<xsl:text>T</xsl:text>
		<xsl:value-of select="./hour"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="./minute"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="./second"/>
		<!--<xsl:value-of select="./tzd"/>-->
	</xsl:template>
	
	<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp|date_from_timestamp|date_to_timestamp|dc_date" mode="ISO8601-MinNoT">
		<xsl:value-of select="./year"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="./month"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="./day"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="./hour"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="./minute"/>
	</xsl:template>
	
	<xsl:template name="userfullname">
		<xsl:if test="firstname != ''">
			<xsl:value-of select="firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		
		<xsl:value-of select="lastname"/>
	</xsl:template>
	
	<xsl:template name="creatorfullname">
		<xsl:if test="created_by_firstname != ''">
			<xsl:value-of select="created_by_firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>	
		<xsl:value-of select="created_by_lastname"/>
	</xsl:template>
	
	<xsl:template name="modifierfullname">
		<xsl:if test="last_modified_by_firstname != ''">
			<xsl:value-of select="last_modified_by_firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="last_modified_by_lastname"/>
	</xsl:template>
	
	<xsl:template name="publisherfullname">
		<xsl:if test="published_by_firstname != ''">
			<xsl:value-of select="published_by_firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="published_by_lastname"/>
	</xsl:template>
	
	<xsl:template name="lastpublisherfullname">
		<xsl:if test="last_published_by_firstname != ''">
			<xsl:value-of select="last_published_by_firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="last_published_by_lastname"/>
	</xsl:template>
	
	<xsl:template name="ownerfullname">
		<xsl:if test="owned_by_firstname != ''">
			<xsl:value-of select="owned_by_firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		
		<xsl:value-of select="owned_by_lastname"/>
	</xsl:template>
	<xsl:template name="lockerfullname">
		<xsl:if test="locked_by_firstname != ''">
			<xsl:value-of select="locked_by_firstname"/>
			<xsl:text> </xsl:text>
		</xsl:if>		
		<xsl:value-of select="locked_by_lastname"/>
	</xsl:template>
	
	<xsl:template name="message">
		<xsl:choose>
			<xsl:when test="$error_msg != ''">
				<span class="error_msg">
					<xsl:value-of select="$error_msg"/>
				</span>
			</xsl:when>
			<xsl:when test="$warning_msg != ''">
				<span class="warning_msg">
					<xsl:value-of select="$warning_msg"/>
				</span>
			</xsl:when>
			<xsl:when test="$message != ''">
				<span class="message">
					<xsl:value-of select="$message"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#160;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="br-replace">
		<xsl:param name="word"/>
		<xsl:variable name="cr">
			<xsl:text>
</xsl:text>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($word,$cr)">
				<xsl:value-of select="substring-before($word,$cr)"/>
				<br/>
				<xsl:call-template name="br-replace">
					<xsl:with-param name="word" select="substring-after($word,$cr)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$word"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="body">
		<xsl:apply-templates select="/document/context/object/body"/>
	</xsl:template>
	<xsl:template name="rbacknav">
		<xsl:if test="$r != ''">
			<input name="r" type="hidden" value="{$r}"/>
			<input name="page" type="hidden" value="{$page}"/>
			<input name="sb" type="hidden" value="{$sb}"/>
			<input name="order" type="hidden" value="{$order}"/>
			<xsl:if test="$hd = '0'">
				<input name="hd" type="hidden" value="{$hd}"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="rbacknav_qs">
		<xsl:if test="$r != ''">
			<xsl:value-of select="concat(';sb=', $sb, ';order=', $order, ';page=', $page, ';r=', $r)"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="department_title">
		<xsl:choose>
			<xsl:when test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/is_objectroot = '1'">
				<xsl:value-of select="/document/context/object/title"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/department_id]/title"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

 <!-- this is a simple template which converts                  -->
    <!-- a given token into a url-encoded string                   -->
    <!--  the converted string is returned after conversion        -->
    <!--  note: any occurence of the percent sign is left          -->
    <!--        untouched                                          -->
    <xsl:template name="url_encode">
      <xsl:param name="token"/>
	<xsl:choose>
	<!-- substitute all characters with special meaning -->
	    <!-- U+0020   SPACE -->
	    <xsl:when test="contains($token, ' ')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, ' '),'%20', substring-after($token, ' '))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0022 &#34; QUOTATION MARK -->
	    <xsl:when test="contains($token, '&#34;')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '&#34;'),'%22', substring-after($token, '&#34;'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0023 # NUMBER SIGN -->
	    <xsl:when test="contains($token, '#')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '#'),'%23', substring-after($token, '#'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0024 $ DOLLAR SIGN -->
	    <xsl:when test="contains($token, '$')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '$'),'%24', substring-after($token, '$'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0026 &#38; AMPERSAND -->
	    <xsl:when test="contains($token, '&#38;')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '&#38;'),'%26', substring-after($token, '&#38;'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0027 &#39; APOSTROPHE -->
	    <xsl:when test='contains($token, "&#39;")'>
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select='concat(substring-before($token, "&#39;"), "%27", substring-after($token, "&#39;"))'/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+002B + PLUS SIGN -->
	    <xsl:when test="contains($token, '+')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '+'),'%2B', substring-after($token, '+'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+002C , COMMA -->
	    <xsl:when test="contains($token, ',')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, ','),'%2C', substring-after($token, ','))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+002F / SOLIDUS -->
	    <xsl:when test="contains($token, '/')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '/'),'%2F', substring-after($token, '/'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+003A : COLON -->
	    <xsl:when test="contains($token, ':')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, ':'),'%3A', substring-after($token, ':'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+003B ; SEMICOLON -->
	    <xsl:when test="contains($token, ';')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, ';'),'%3B', substring-after($token, ';'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+003C &#60; LESS-THAN SIGN -->
	    <xsl:when test="contains($token, '&#60;')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '&#60;'),'%3C', substring-after($token, '&#60;'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+003D = EQUALS SIGN -->
	    <xsl:when test="contains($token, '=')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '='),'%3D', substring-after($token, '='))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+003E &#62; GREATER-THAN SIGN -->
	    <xsl:when test="contains($token, '&#62;')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '&#62;'),'%3E', substring-after($token, '&#62;'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+003F ? QUESTION MARK -->
	    <xsl:when test="contains($token, '?')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '?'),'%3F', substring-after($token, '?'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0040 @ COMMERCIAL AT -->
	    <xsl:when test="contains($token, '@')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '@'),'%40', substring-after($token, '@'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+005B [ LEFT SQUARE BRACKET -->
	    <xsl:when test="contains($token, '[')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '['),'%5B', substring-after($token, '['))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+005C \ REVERSE SOLIDUS -->
	    <xsl:when test="contains($token, '\')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '\'),'%5C', substring-after($token, '\'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+005D ] RIGHT SQUARE BRACKET -->
	    <xsl:when test="contains($token, ']')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, ']'),'%5D', substring-after($token, ']'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+005E ^ CIRCUMFLEX ACCENT -->
	    <xsl:when test="contains($token, '^')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '^'),'%5E', substring-after($token, '^'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+0060 ` GRAVE ACCENT -->
	    <xsl:when test="contains($token, '`')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '`'),'%60', substring-after($token, '`'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+007B { LEFT CURLY BRACKET -->
	    <xsl:when test="contains($token, '{')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '{'),'%7B', substring-after($token, '{'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+007C | VERTICAL LINE -->
	    <xsl:when test="contains($token, '|')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '|'),'%7C', substring-after($token, '|'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+007D } RIGHT CURLY BRACKET -->
	    <xsl:when test="contains($token, '}')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '}'),'%7D', substring-after($token, '}'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+007E ~ TILDE -->
	    <xsl:when test="contains($token, '~')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '~'),'%7E', substring-after($token, '~'))"/>
	      </xsl:call-template>
	    </xsl:when>
	  <!-- substitute all (uppercase and lowercase) umlauts -->
	    <!-- U+00C4 Ä LATIN CAPITAL LETTER A WITH DIAERESIS -->
	    <xsl:when test="contains($token, 'Ä')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'Ä'),'%C4', substring-after($token, 'Ä'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00D6 Ö LATIN CAPITAL LETTER O WITH DIAERESIS -->
	    <xsl:when test="contains($token, 'Ö')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'Ö'),'%D6', substring-after($token, 'Ö'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00DC Ü LATIN CAPITAL LETTER U WITH DIAERESIS -->
	    <xsl:when test="contains($token, 'Ü')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'Ü'),'%DC', substring-after($token, 'Ü'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00DF ß LATIN SMALL LETTER SHARP S -->
	    <xsl:when test="contains($token, 'ß')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'ß'),'%DF', substring-after($token, 'ß'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00E4 ä LATIN SMALL LETTER A WITH DIAERESIS -->
	    <xsl:when test="contains($token, 'ä')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'ä'),'%E4', substring-after($token, 'ä'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00E9 é LATIN SMALL LETTER E WITH ACUTE -->
	    <xsl:when test="contains($token, 'é')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'é'),'%E9', substring-after($token, 'é'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00F6 ö LATIN SMALL LETTER O WITH DIAERESIS -->
	    <xsl:when test="contains($token, 'ö')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'ö'),'%F6', substring-after($token, 'ö'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+00FC ü LATIN SMALL LETTER U WITH DIAERESIS -->
	    <xsl:when test="contains($token, 'ü')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, 'ü'),'%FC', substring-after($token, 'ü'))"/>
	      </xsl:call-template>
	    </xsl:when>
	<!-- substitute a few space characters like carriage return, etc. -->
	    <!-- U+000A 
 LINE FEED (LF) -->
	    <xsl:when test="contains($token, '
')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '
'),'%0A', substring-after($token, '
'))"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- U+000D 
 CARRIAGE RETURN (CR) -->
	    <xsl:when test="contains($token, '
')">
	      <xsl:call-template name="url_encode">
		  <xsl:with-param name="token" select="concat(substring-before($token, '
'),'%0D', substring-after($token, '
'))"/>
	      </xsl:call-template>
	    </xsl:when>
	  <!-- if all special characters have been replaced -->
	    <!-- return $token -->
	    <xsl:otherwise>
		<xsl:value-of select="$token"/>
	    </xsl:otherwise>
	</xsl:choose>
    </xsl:template>

</xsl:stylesheet>
