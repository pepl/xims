<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_create_tinymce.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:import href="create_common.xsl"/>
	<xsl:import href="document_common.xsl"/>
	
	<xsl:param name="tinymce">1</xsl:param>	
	<xsl:param name="selEditor">wysiwyg</xsl:param>	
        <xsl:param name="testlocation" select="true()"/>
        <xsl:param name="tinymce_version" select="4"/>
	
	<xsl:template name="create-content">
		<input type="hidden" name="objtype" value="{$objtype}"/>
		<xsl:call-template name="form-locationtitle-create"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
        <xsl:call-template name="form-nav-options"/>
		<xsl:call-template name="form-body-create_tinymce"/>
		<xsl:call-template name="social-bookmarks"/>
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="expandrefs"/>
		<xsl:call-template name="form-grant"/>
	</xsl:template>


	<xsl:template name="form-body-create_tinymce">
		<div class="block form-div">
            <h2><label for="body">Body</label>
            <!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>--></h2>
				<textarea name="body" id="body" rows="20" cols="90" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;">
					<xsl:text>&lt;p&gt;&#160;&lt;/p&gt;</xsl:text>
				</textarea>
		</div>
		<xsl:call-template name="jsorigbody"/>
	</xsl:template>
</xsl:stylesheet>
