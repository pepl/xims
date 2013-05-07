<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: departmentroot_edit.xsl 2239 2009-08-03 09:35:54Z haensel $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common.xsl"/>
	<xsl:import href="container_common.xsl"/>
	<xsl:import href="departmentroot_common.xsl"/>
	
	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-portlets"/>
		<xsl:call-template name="form-stylemedia"/>
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="form-obj-specific"/>
		
		<!-- start uibk-design extras -->
		    <xsl:if test="contains($absolute_path, 'uniweb') or contains($absolute_path, 'cabal')">
				<!-- show only to webadmins -->
				<xsl:if test="/document/context/session/user/userprefs/profile_type = 'webadmin'">
					<xsl:call-template name="select-faculty"/>
					<xsl:call-template name="select_category"/>
				</xsl:if>
			</xsl:if>
		    <!-- end uibk-design extras -->
		<br class="clear"/>
	</xsl:template>
	
	<xsl:template match="objectlist/object">
            <a class="label-large" href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
            <a class="button option-delete" href="{$goxims_content}{$absolute_path}?portlet_id={id};rem_portlet=1">
				<xsl:value-of select="$i18n/l/delete"/>&#160;
            </a>
			<br/>
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

<xsl:template name="form-keywords"/>

	<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/ExtraOptions"/></h2>
			<xsl:call-template name="autoindex"/>
			<xsl:call-template name="form-pagerowlimit-edit"/>
			<xsl:call-template name="defaultsorting"/>
		</div>
	</xsl:template>
	
<xsl:template name="form-portlets">
	<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/DepartmentrootPortlets"/></h2>
		<div class="label-large"><xsl:value-of select="$i18n/l/addedPortlets"/>: </div>
		
		<div class="div-left"><xsl:apply-templates select="/document/objectlist"/></div>
		</div>
		<div id="tr-createportlet" class="form-div block">
			<div id="label-createportlet">
				<label for="input-createportlet">
					<xsl:value-of select="$i18n/l/create_portlet"/>
				</label>
			</div>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet','default-dialog','{$i18n/l/Browse_for}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_for"/>
			</a>
			<input type="text" name="portlet" size="40" class="text" value="{portlet_id}" id="input-createportlet"/>
			<xsl:text>&#160;</xsl:text>
			<button type="submit" name="add_portlet" id="input-add_portlet">
				<xsl:value-of select="$i18n/l/add_portlet"/>
			</button>
	</div>
</xsl:template>
</xsl:stylesheet>