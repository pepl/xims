<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: departmentroot_create.xsl 2239 2009-08-03 09:35:54Z haensel $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="create_common.xsl"/>
<xsl:import href="container_common.xsl"/>
<xsl:import href="departmentroot_common.xsl"/>
<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

<xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:call-template name="form-stylemedia"/>
	<xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-obj-specific"/>
	<xsl:call-template name="form-grant"/>
	<br class="clear"/>
</xsl:template>

<xsl:template name="form-stylemedia">
<div class="block form-div">
<h2><xsl:value-of select="$i18n/l/LayoutOptions"/></h2>
	<xsl:call-template name="form-stylesheet"/>
	<xsl:call-template name="form-css"/>
	<xsl:call-template name="form-script"/>
	<xsl:call-template name="form-image"/>
	<xsl:call-template name="form-feed"/>
</div>
</xsl:template>

<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/ExtraOptions"/></h2>
			<xsl:call-template name="autoindex"/>
			<xsl:call-template name="form-pagerowlimit-edit"/>
			<xsl:call-template name="defaultsorting"/>
			<!-- start uibk-design extras -->
		    <!-- <xsl:if test="contains($absolute_path, 'uniweb') or contains($absolute_path, 'cabal')">
		    	<xsl:call-template name="select-faculty"/>
				<!-/- show only to webadmins -/->
				<xsl:if test="/document/context/session/user/userprefs/profile_type = 'webadmin'">
					<xsl:call-template name="select_category"/>
				</xsl:if>
			</xsl:if> -->
		    <!-- end uibk-design extras -->
		</div>
	</xsl:template>

<xsl:template name="form-keywords"/>

</xsl:stylesheet>
