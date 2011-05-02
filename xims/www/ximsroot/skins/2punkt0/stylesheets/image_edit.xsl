<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: image_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="file_edit.xsl"/>
	
	
	<xsl:template name="preview-image">
		<div class="form-div ui-corner-all block">
		<p>
			<a class="button" href="javascript:createImageDialog('{$xims_box}{$goxims_content}{$absolute_path}','default-dialog','{$i18n/l/Preview_image}')">
				<xsl:value-of select="$i18n/l/Preview_image"/>
			</a>
		</p>
		</div>
	</xsl:template>
	
	<xsl:template name="form-file-edit">
		<div id="tr-replace">
			<div class="label-std">
				<label for="input-replace">
					<xsl:value-of select="$i18n/l/Image"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n/l/replace"/>
				</label>
			</div>
			<input type="file" name="file" size="50" class="text" id="input-replace"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
		</div>
	</xsl:template>
</xsl:stylesheet>
