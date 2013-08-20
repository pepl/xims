<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_header.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:template name="head_default">
		<xsl:param name="mode"/>
		<xsl:param name="questionnaire" select="false()"/>
		<xsl:param name="ap-pres" select="false()"/>
		<xsl:param name="reflib" select="false()"/>
		<xsl:param name="vlib" select="false()"/>
		<xsl:param name="simpledb" select="false()"/>
		<head>
            <meta charset="UTF-8"/>
			<title>
				<xsl:choose>
					<xsl:when test="$mode='create'">
						<xsl:call-template name="title-create"/>
					</xsl:when>
					<xsl:when test="$mode='edit'">
						<xsl:call-template name="title-edit"/>
					</xsl:when>
					<xsl:when test="$mode='delete'">
						<xsl:call-template name="title-delete"/>
					</xsl:when>
					<xsl:when test="$mode='move'">
						<xsl:call-template name="title-move"/>
					</xsl:when>
					<xsl:when test="$mode='mg-acl'">
						<xsl:call-template name="title-mg-acl"/>
					</xsl:when>
					<xsl:when test="$mode='user'">
						<xsl:call-template name="title-userpage"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="title"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:call-template name="css">
				<xsl:with-param name="questionnaire" select="$questionnaire"/>
				<xsl:with-param name="ap-pres" select="$ap-pres"/>
				<xsl:with-param name="reflib" select="$reflib"/>
				<xsl:with-param name="vlib" select="$vlib"/>
				<xsl:with-param name="simpledb" select="$simpledb"/>
				<xsl:with-param name="sitestyle" select="false()"/>
			</xsl:call-template>
			<xsl:call-template name="script_head"/>
		</head>
	</xsl:template>

    <!--Title-->
	<xsl:template name="title-create">
		<xsl:value-of select="$i18n/l/create"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
		<xsl:call-template name="objtype_name">
			<xsl:with-param name="ot_name">
				<xsl:value-of select="$objtype"/>
			</xsl:with-param>
		</xsl:call-template>
		&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
	</xsl:template>
	<xsl:template name="title-edit">
		<xsl:value-of select="$i18n/l/edit"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
		<xsl:call-template name="objtype_name">
			<xsl:with-param name="ot_name">
				<xsl:value-of select="$objtype"/>
			</xsl:with-param>
		</xsl:call-template>
		&#160;'<xsl:value-of select="title"/>'&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS
	</xsl:template>
	<xsl:template name="title-move">
		<xsl:value-of select="$i18n/l/Move_object"/>&#160;<xsl:value-of select="location"/> - XIMS
	</xsl:template>
	<xsl:template name="title-delete">
		<xsl:value-of select="$i18n/l/ConfDeletion1"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
		<xsl:call-template name="objtype_name">
			<xsl:with-param name="ot_name">
				<xsl:value-of select="$objtype"/>
			</xsl:with-param>
		</xsl:call-template>
		&#160;'<xsl:value-of select="title"/>'&#160;<xsl:value-of select="$i18n/l/ConfDeletion2"/>&#160; - XIMS
	</xsl:template>
	<xsl:template name="title-mg-acl">
		<xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="object/title"/>' - XIMS
	</xsl:template>
	<xsl:template name="title-userpage">
		<xsl:value-of select="name"/> - XIMS
	</xsl:template>
	<xsl:template name="title">
		<xsl:value-of select="title"/> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - <xsl:call-template name="department_title"/> - XIMS
	</xsl:template>
	
	<xsl:template name="css">
		<xsl:param name="questionnaire" select="false()"/>
		<xsl:param name="ap-pres" select="false()"/>
		<xsl:param name="reflib" select="false()"/>
		<xsl:param name="vlib" select="false()"/>
		<xsl:param name="simpledb" select="false()"/>
		<xsl:param name="sitestyle" select="false()"/>
		<!-- <link rel="stylesheet" href="{$ximsroot}stylesheets/jquery/jquery_min.css" type="text/css"/>-->
		 <link rel="stylesheet" href="{$ximsroot}stylesheets/jquery/jquery-ui-1.10.3.custom.css" type="text/css"/>
		<!-- debuggin mode -->
		<xsl:if test="$questionnaire">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$ap-pres">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/axpointpresentation.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$reflib">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$vlib">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$simpledb">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/simpledb.css" type="text/css"/>
		</xsl:if>
		<!-- 
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/min.css" type="text/css"/> 
		-->
		<!-- debugging mode -->

		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/common.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/content.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/sprites.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/menu.css" type="text/css"/>
		

	</xsl:template>
	
	<xsl:template name="script_head">
		<script type="text/javascript">
            var ximsconfig = <xsl:value-of select="$js-config"/>;
		</script>
		<!-- <script src="{$ximsroot}scripts/jquery/jquery_min.js"
                type="text/javascript"><xsl:comment></xsl:comment></script> -->
        <xsl:comment>
          <xsl:text disable-output-escaping="yes">[if lt IE 9]&gt;&lt;script src="</xsl:text>
          <xsl:value-of select="concat($ximsroot,'skins/',$currentskin)"/>
          <xsl:text disable-output-escaping="yes">/scripts/html5shiv.js"&gt;&lt;/script&gt;&lt;![endif]</xsl:text>
        </xsl:comment>
		<!-- debuggin mode -->
    <xsl:comment>
          <xsl:text disable-output-escaping="yes">[if lt IE 9]&gt;&lt;script src="</xsl:text>
          <xsl:value-of select="concat($ximsroot,'scripts/jquery/')"/>
          <xsl:text disable-output-escaping="yes">jquery-1.10.2.js"&gt;&lt;/script&gt;&lt;![endif]</xsl:text>
    </xsl:comment>
    <xsl:comment>
          <xsl:text disable-output-escaping="yes">[if gte IE 9]&gt;&lt;script src="</xsl:text>
          <xsl:value-of select="concat($ximsroot,'scripts/jquery/')"/>
          <xsl:text disable-output-escaping="yes">jquery-2.0.3.js"&gt;&lt;/script&gt;&lt;![endif]</xsl:text>
    </xsl:comment>
    <xsl:comment><xsl:text disable-output-escaping="yes">[if !IE]&gt;</xsl:text></xsl:comment>
          <script src="{$ximsroot}scripts/jquery/jquery-2.0.3.js" type="text/javascript"><xsl:comment></xsl:comment></script>
    <xsl:comment><xsl:text disable-output-escaping="yes">&lt;![endif]</xsl:text></xsl:comment>
		<!-- <script src="{$ximsroot}scripts/jquery/jquery-2.0.3.js" type="text/javascript"><xsl:comment></xsl:comment></script>-->
		<script src="{$ximsroot}scripts/jquery/jquery-ui-1.10.3.custom.js" type="text/javascript"><xsl:comment></xsl:comment></script>
		<script src="{$ximsroot}scripts/jquery/jquery-ui-timepicker-addon.js" type="text/javascript"><xsl:comment></xsl:comment></script>
		<script src="{$ximsroot}scripts/jquery/jquery.ui.combobox.js" type="text/javascript"><xsl:comment></xsl:comment></script>
		<script src="{$ximsroot}scripts/jquery/jquery-ui-i18n.js" type="text/javascript"><xsl:comment></xsl:comment></script>

	</xsl:template>
</xsl:stylesheet>

