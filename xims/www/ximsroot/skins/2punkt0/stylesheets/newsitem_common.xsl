<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="document_common.xsl"/>
	
	<xsl:variable name="i18n_news" select="document(concat($currentuilanguage,'/i18n_newsitem.xml'))"/>
	<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
	
	<xsl:template name="tr-minify"/>
	<xsl:template name="tr-bodyfromfile-create"/>
	
	<xsl:template name="form-leadimage-create">
		<xsl:call-template name="form-leadimage">
			<xsl:with-param name="mode">create</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
		<xsl:template name="form-leadimage-edit">
		<xsl:call-template name="form-leadimage">
			<xsl:with-param name="mode">edit</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="form-leadimage">
		<xsl:param name="mode"/>
		<div class="form-div block">
		<div id="tr-lead">
			<div class="label-std">
				<label for="input-lead">
					<xsl:value-of select="$i18n/l/Lead"/>
				</label>
			</div>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
			<br/>
			<textarea id="input-lead" name="lead" rows="3" cols="74" maxlength="390" onkeyup="keyup(this)">
				<xsl:apply-templates select="abstract"/>
			</textarea>
			<xsl:text>&#160;</xsl:text>
			<span id="charcount">
				<xsl:text>&#160;</xsl:text>
			</span>
			<xsl:call-template name="charcountcheck"/>
		</div>
		<xsl:if test="$mode='edit'">
			<xsl:call-template name="form-image"/>
		</xsl:if>
		<xsl:if test="$mode='create'">
			<xsl:call-template name="form-image"/>
			<div>
				<div class="label-std">
					<label for="input-image-title">
						<xsl:value-of select="$i18n/l/Image"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="$i18n/l/Title"/>
					</label>
				</div>
				<input type="text" name="imagetitle" size="60" class="text" id="input-image-title"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('ImageTitle')" class="doclink">(?)</a>
			</div>
			<div id="tr-image-description">
				<div id="label-image-description">
					<label for="input-image-description">
						<xsl:value-of select="$i18n/l/Image"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="$i18n/l/Description"/>
					</label>
				</div>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('ImageDescription')" class="doclink">(?)</a>
				<br/>
				<textarea name="imagedescription" rows="3" cols="74" class="text" id="input-image-description">
					<xsl:text>&#160;</xsl:text>
				</textarea>
				<script type="text/javascript">document.getElementsByName("imagedescription")[0].value = '';</script>
			</div>
			<div id="tr-image-target">
				<div class="label-std">
					<label for="input-image-target">
						<xsl:value-of select="$i18n/l/Image"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="$i18n/l/target"/>
					</label>
				</div>
				<input type="text" name="imagefolder" size="60" class="text" id="input-image-target">
					<!--  Provide an "educated-guess" default value -->
					<xsl:attribute name="value">
						<xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
							<xsl:text>/</xsl:text>
							<xsl:value-of select="location"/>
						</xsl:for-each>
						<xsl:text>/images</xsl:text>
					</xsl:attribute>
				</input>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('NewsItemImage')" class="doclink">(?)</a>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$parentid};to={$parentid};otfilter=Folder,DepartmentRoot,SiteRoot;contentbrowse=1;sbfield=eform.imagefolder','default-dialog','{$i18n/l/browse_target}')" class="button">
					<xsl:value-of select="$i18n/l/browse_target"/>
				</a>
			</div>
		</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="charcountcheck">
		<script type="text/javascript">
    var str_of  = '<xsl:value-of select="$i18n_news/l/of"/>';
    var str_entered = '<xsl:value-of select="$i18n_news/l/Characters_entered"/>';
    var str_charlimit  = '<xsl:value-of select="$i18n_news/l/Charlimit_reached"/>';
    var maxKeys = 390; // Should this be a config.xsl value?
    </script>
	</xsl:template>
	
		<xsl:template name="form-metadata">
  <div class="form-div block">
		<h2>Meta Data</h2>
		<xsl:call-template name="form-keywords"/>
			<xsl:call-template name="form-valid_from"/>
			<xsl:call-template name="form-valid_to"/>
  </div>
</xsl:template>

</xsl:stylesheet>
