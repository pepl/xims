<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: symboliclink_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common.xsl"/>
	
		<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtarget-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<br clear="all"/>
	</xsl:template>
	
	<xsl:template name="form-locationtarget-edit">
	<div class="form-div div-left">
	<div id="tr-title">
								<div class="label-std">
									<label for="input-title"><xsl:value-of select="$i18n/l/Title"/></label>
								</div>
								<input id="input-title" readonly="readonly" size="60">
									<xsl:attribute name="value"><xsl:value-of select="title"/></xsl:attribute>
								</input>
							</div>
		<xsl:call-template name="form-location-edit"/>
		<xsl:call-template name="form-target-edit"/>
	</div>
	</xsl:template>
	
	<xsl:template name="form-target-edit">
		<div id="tr-target">
			<div class="label-std">
					<label for="input-target">
						<xsl:value-of select="$i18n/l/Target"/>
					</label> *
			</div>
			<input type="text" name="target" size="60" value="{symname_to_doc_id}" class="text" id="input-target"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('PortletTarget')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Target"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;sbfield=eform.target','default-dialog','{$i18n/l/browse_target}')" class="button" id="buttonBrTarget">
				<xsl:value-of select="$i18n/l/browse_target"/>
			</a>
		</div>
	</xsl:template>
</xsl:stylesheet>
