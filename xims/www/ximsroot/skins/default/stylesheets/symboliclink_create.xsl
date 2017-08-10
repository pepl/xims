<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: symboliclink_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="create_common.xsl"/>
	
	<xsl:template name="create-content">
		<xsl:call-template name="form-locationtarget-create"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
        <xsl:call-template name="form-nav-options"/>
		<xsl:call-template name="form-grant"/>
		<br class="clear"/>
	</xsl:template>
	
	<xsl:template name="form-locationtarget-create">
	<div class="form-div div-left">
		<xsl:call-template name="form-location-create"/>
		<xsl:call-template name="form-target-create"/>
	</div>
	</xsl:template>
	
	<xsl:template name="form-target-create">
		<div id="tr-target">
			<div class="label-std">
					<label for="input-target">
						<xsl:value-of select="$i18n/l/Target"/>
					</label> *
			</div>
			<input type="text" name="target" size="60" class="text" id="input-target"/>
			<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('PortletTarget')" class="doclink">
				<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Target"/>
				</xsl:attribute>(?)</a>-->
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}{$absolute_path}?contentbrowse=1&amp;sbfield=eform.target','default-dialog','{$i18n/l/browse_target}')" class="button" id="buttonBrTarget">
				<xsl:value-of select="$i18n/l/browse_target"/>
			</a>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
