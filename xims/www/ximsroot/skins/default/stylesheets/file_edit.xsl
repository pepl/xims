<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: file_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="edit_common.xsl"/>
	
	<xsl:template name="form-file-edit">
		<div id="tr-replace">
			<div class="label-std">
				<label for="input-replace">
					<xsl:value-of select="$i18n/l/File"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n/l/replace"/>
				</label>
			</div>
			<input type="file" name="file" size="43" class="text" id="input-replace"/>
			<!--<xsl:text>&#160;</xsl:text>
			    <a href="javascript:openDocWindow('File')" class="doclink">(?)</a>-->
		</div>
	</xsl:template>
	
	<xsl:template name="edit-content">
      <xsl:call-template name="form-titlelocationfile-edit"/>
	  <xsl:call-template name="form-marknew-pubonsave"/>
	  <xsl:call-template name="preview-image"/>
	  <xsl:call-template name="form-keywordabstractrights"/>
    </xsl:template>
	
	<xsl:template name="form-titlelocationfile-edit">
	  <div class="form-div ui-corner-all div-left">
		<xsl:call-template name="form-title"/>
		<xsl:call-template name="form-location-edit"/>
		<xsl:call-template name="form-file-edit"/>
	  </div>
	</xsl:template>
	
	<xsl:template name="preview-image"/>
</xsl:stylesheet>
