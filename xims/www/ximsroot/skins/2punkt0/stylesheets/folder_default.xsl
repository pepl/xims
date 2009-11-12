<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: folder_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="container_common.xsl"/>
	<xsl:variable name="deleted_children">
		<xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])"/>
	</xsl:variable>
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default"/>
			<body>
				<!--<script language="javascript" type="text/javascript" src="{$ximsroot}scripts/search_filter.js"/>-->
				<xsl:call-template name="header">
					<xsl:with-param name="createwidget">true</xsl:with-param>
				</xsl:call-template>
				<div id="main-content">
					<xsl:call-template name="options-menu-bar"/>
					<div id="right-empty-div-cell">&#160;</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
						<xsl:call-template name="childrentable"/>
						<xsl:call-template name="pagenavtable"/>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="deleted_objects">
		<xsl:choose>
			<xsl:when test="$hd=0 and $deleted_children > 0">
				<div class="deleted_objects">
					<a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=1">Hide deleted Objects</a>
				</div>
			</xsl:when>
			<xsl:when test="$deleted_children > 0">
				<div class="deleted_objects">
					<a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=0">Show the  <xsl:value-of select="$deleted_children"/> deleted Object(s) in this Container</a>
				</div>
			</xsl:when>
			<xsl:otherwise>
            </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	


</xsl:stylesheet>
