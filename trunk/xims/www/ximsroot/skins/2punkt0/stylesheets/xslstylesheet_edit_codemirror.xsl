<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xslstylesheet_edit_codemirror.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common_codemirror.xsl"/>
    <xsl:import href="codemirror_xsl_script.xsl"/>
	<xsl:import href="codemirror_common.xsl"/>
	
	<xsl:param name="codemirror" select="true()"/>	
	<xsl:param name="selEditor" select="true()"/>	
	
	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-body-edit_codemirror"/>
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="expandrefs"/>
	</xsl:template>
    
	<xsl:template name="form-body-edit_codemirror">
		<div class="block form-div">
            <h2><label for="body">Body</label>
            <xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Body')" class="doclink">
			<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/>
				</xsl:attribute>(?)</a></h2>
			<textarea name="body" id="body" rows="20" cols="90">
				<xsl:value-of select="$bodycontent"/>
			</textarea>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
