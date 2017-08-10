<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
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
        <xsl:call-template name="form-nav-options"/>
		<xsl:call-template name="form-portlets"/>
		<xsl:call-template name="form-stylemedia"/>
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="form-obj-specific"/>
		
	</xsl:template>
	
	<xsl:template match="objectlist/object">
            <a class="label-large" href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
            <a class="option-delete ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" href="{$goxims_content}{$absolute_path}?portlet_id={id}&amp;rem_portlet=1" role="button" aria-disabled="false" >
              <xsl:attribute name="title"><xsl:value-of select="$i18n/l/delete"/></xsl:attribute>
              <span class="ui-button-icon-primary ui-icon sprite-option_delete xims-sprite"><xsl:comment/></span>
              <span class="ui-button-text"><xsl:value-of select="$i18n/l/delete"/>&#160;</span>
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
    <xsl:if test="/document/context/session/user/userprefs/profile_type = 'webadmin'">
      <xsl:call-template name="tr-convert2folder"/>
    </xsl:if>
  </div>
</xsl:template>
	
<xsl:template name="form-portlets">
	<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/DepartmentrootPortlets"/></h2>
		<div class="label-large"><xsl:value-of select="$i18n/l/addedPortlets"/>: </div>
		
		<div class="div-left"><xsl:apply-templates select="/document/objectlist"/><xsl:comment/></div>
		</div>
		<div id="tr-createportlet" class="form-div block">
			<div id="label-createportlet">
				<label for="input-createportlet">
					<xsl:value-of select="$i18n/l/create_portlet"/>
				</label>
			</div>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id}&amp;contentbrowse=1&amp;to={@id}&amp;otfilter=Portlet&amp;sbfield=eform.portlet','default-dialog','{$i18n/l/Browse_for}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_for"/>
			</a>
			<input type="text" name="portlet" size="40" class="text" value="{portlet_id}" id="input-createportlet"/>
			<xsl:text>&#160;</xsl:text>
			<button type="submit" name="add_portlet" id="input-add_portlet" class="button">
				<xsl:value-of select="$i18n/l/add_portlet"/>
			</button>
	</div>
</xsl:template>

<xsl:template name="tr-convert2folder">
  <div id="tr-convert" >
    <div id="label-convert" class="label-large">
      <label for="input-convert">
         <xsl:value-of select="$i18n/l/Convert"/> Departmentroot → <xsl:value-of select="$i18n/l/Folder"/>
	  </label>
	</div>
    <a href="{$xims_box}{$goxims_content}?id={@id}&amp;convert2folder_prompt=1"
       id="input-convert"
       class="button">
 	  <xsl:value-of select="$i18n/l/Convert"/>!
	</a>
  </div>
</xsl:template>

</xsl:stylesheet>
