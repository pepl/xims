<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xslstylesheet_edit_codemirror.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="codemirror_common.xsl"/>
    <xsl:import href="codemirror_sqlreport_script.xsl"/>
    <xsl:import href="create_common_codemirror.xsl"/>
    <xsl:import href="sqlreport_common.xsl"/>

	<xsl:param name="codemirror" select="true()"/>	
	<xsl:param name="selEditor" select="true()"/>	
	
	<xsl:template name="create-content">
		<input type="hidden" name="objtype" value="{$objtype}"/>
		<xsl:call-template name="form-locationtitle-create"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-body-create_codemirror"/>
		<xsl:call-template name="form-keywordabstract"/>
		<!--<xsl:call-template name="expandrefs"/>-->
		<xsl:call-template name="form-grant"/>
        <xsl:call-template name="form-obj-specific"/>
	</xsl:template>
    
    <xsl:template name="form-body-create_codemirror">
		<div class="block form-div">
            <h2><label for="body">Body</label>
            <xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Body')" class="doclink">(?)</a></h2>
				<textarea name="body" id="body" rows="20" cols="90" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;">
				</textarea>
		</div>
		<xsl:call-template name="jsorigbody"/>
	</xsl:template>

</xsl:stylesheet>

