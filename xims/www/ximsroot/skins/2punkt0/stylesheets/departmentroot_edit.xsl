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
	
	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-stylemedia"/>
		<!--<xsl:call-template name="form-stylesheet"/>
		<xsl:call-template name="tr-css-edit"/>
		<xsl:call-template name="tr-script-edit"/>
		--><!--<xsl:call-template name="tr-imagedepartmentroot-edit"/>--><!--
		<xsl:call-template name="tr-image-edit"/>
		<xsl:call-template name="tr-feed-edit"/>-->
		<xsl:call-template name="form-keywordabstract"/>
		<!--<xsl:call-template name="form-abstract"/>-->
		<!--<xsl:call-template name="autoindex"/>
		<xsl:call-template name="form-pagerowlimit-edit"/>
		<xsl:call-template name="defaultsorting"/>-->
		<!--<xsl:call-template name="defaultprivmask-edit"/>-->
		<!--<xsl:call-template name="tr-deptportlets-edit"/>-->
		<xsl:call-template name="form-obj-specific"/>
		<br clear="all"/>
	</xsl:template>
	
	<xsl:template name="defaultprivmask-edit">
		<tr>
			<td valign="top">Default Privilege Mask</td>
			<td>
				<input tabindex="30" type="text" name="defaultprivmask" size="40" value="{attributes/defaultprivmask}" class="text"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('defaultprivmask')" class="doclink">(?)</a>
			</td>
		</tr>
	</xsl:template>
	
	<!--<xsl:template name="tr-imagedepartmentroot-edit">
    <div id="tr-image">
        <div id="label-image"><label for="input-image"><xsl:value-of select="$i18n/l/Image"/></label></div>
            <input type="text" name="image" size="60" value="{image_id}" class="text" id="input-image"/>
            <xsl:text>&#160;</xsl:text>
                    <a href="javascript:openDocWindow('DepartmentImage')" class="doclink">(?)</a>
                    <xsl:text>&#160;</xsl:text>
                 <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
            </div>
</xsl:template>-->

	<xsl:template name="tr-deptportlets-edit">
		<div class="deptportlets">
			<p>DepartmentRoot Portlets</p>
			<xsl:apply-templates select="/document/objectlist"/>
			<div id="tr-createportlet">
				<div id="label-createportlet">
					<label for="input-createportlet">
						<xsl:value-of select="$i18n/l/create_portlet"/>
					</label>
				</div>
				<input type="text" name="portlet" size="40" class="text" value="{portlet_id}" id="input-createportlet"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="button">
					<xsl:value-of select="$i18n/l/Browse_for"/>
				</a>
				<button type="submit" name="add_portlet" id="input-add_portlet">
					<xsl:value-of select="$i18n/l/add_portlet"/>
				</button>
			</div>
			<!--<div id="tr-createportlet-button">
				<button type="submit" name="add_portlet" id="input-add_portlet">
					<xsl:value-of select="$i18n/l/add_portlet"/>
				</button>
			</div>-->
		</div>
	</xsl:template>
	
	<xsl:template match="objectlist/object">
    <div class="tr-deptportlets-item">
        <div class="deptportlets-item">
            <a href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
            </div>
            <a class="xims-sprite sprite-option_delete" href="{$goxims_content}{$absolute_path}?portlet_id={id};rem_portlet=1">
							<span><xsl:value-of select="$i18n/l/delete"/></span>&#160;
            </a>
    </div>
    <br/>
</xsl:template>

<xsl:template name="form-stylemedia">
<div class="block form-div">
<h2>Style &amp; Media / Multimedia</h2>
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
		<h2>Objekt-spezifische Optionen</h2>
			<xsl:call-template name="autoindex"/>
			<xsl:call-template name="form-pagerowlimit-edit"/>
			<xsl:call-template name="defaultsorting"/>
			<xsl:call-template name="tr-deptportlets-edit"/>
		</div>
	</xsl:template>

</xsl:stylesheet>
