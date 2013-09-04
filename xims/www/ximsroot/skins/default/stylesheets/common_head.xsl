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
		<!-- 
		<link rel="stylesheet" href="{$ximsroot}vendor/jquery-ui/css/smoothness/jquery_min.css" type="text/css"/>
		-->
		<!-- debuggin mode -->
		<link rel="stylesheet" href="{$ximsroot}vendor/jquery-ui/css/smoothness/jquery-ui-current.css" type="text/css"/> 
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
    <xsl:if test="$codemirror">
      <link rel="stylesheet" type="text/css" href="{$ximsroot}vendor/codemirror-ui/css/codemirror-ui.css" />
      <link rel="stylesheet" type="text/css" href="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/lib/codemirror.css"/>
      <link rel="stylesheet" type="text/css" href="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/mode/{$cm_mode}/{$cm_mode}.css"/>
    </xsl:if>
		<!--
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/min.css" type="text/css"/> 
    -->
		<!-- debugging mode -->

		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/common.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/content.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/sprites.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/menu.css" type="text/css"/>
		  
    <!-- custom content css -->
    <xsl:if test="$defaultcss != ''"><link type="text/css" href="{$defaultcss}" rel="stylesheet"/></xsl:if>

	</xsl:template>
	
	<xsl:template name="script_head">
		<script type="text/javascript">
            var ximsconfig = <xsl:value-of select="$js-config"/>;
		</script>
		<!--  
		 <script src="{$ximsroot}vendor/jquery/jquery_min.js" type="text/javascript"><xsl:comment></xsl:comment></script> 
		-->
		<!-- debugging mode -->

    <script src="{$ximsroot}vendor/jquery/jquery-current.js" type="text/javascript"><xsl:comment/></script>
		<script src="{$ximsroot}vendor/jquery-ui/js/jquery-ui-current.js" type="text/javascript"><xsl:comment/></script>
		<script src="{$ximsroot}vendor/jquery-ui-timepicker/jquery-ui-timepicker-addon.js" type="text/javascript"><xsl:comment/></script>
		<script src="{$ximsroot}vendor/jquery-ui-combobox/jquery.ui.combobox.js" type="text/javascript"><xsl:comment/></script>
		<script src="{$ximsroot}scripts/jquery-ui-i18n.js" type="text/javascript"><xsl:comment/></script>
    
	</xsl:template>
</xsl:stylesheet>

