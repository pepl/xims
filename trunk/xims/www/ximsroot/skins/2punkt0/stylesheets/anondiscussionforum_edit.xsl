<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforum_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common.xsl"/>
	<xsl:import href="anondiscussionforum_common.xsl"/>

	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-keywordabstract"/>
	</xsl:template>
	
	<xsl:template name="form-abstract">
		<div id="tr-description" class="form-div block">
			<div id="label-description">
				<label for="input-description">
					<xsl:value-of select="$i18n/l/Description"/>
				</label>
			
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('adf_description')" class="doclink">(?)</a>
			</div>
			<br clear="all"/>
			<textarea name="abstract" rows="3" cols="74" id="input-description">
				<xsl:choose>
					<xsl:when test="string-length(abstract) &gt; 0">
						<xsl:apply-templates select="abstract"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>&#160;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</textarea>
		</div>
	</xsl:template>
</xsl:stylesheet>
