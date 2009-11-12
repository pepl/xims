<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_edit_tinymce.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="document_common.xsl"/>
	<xsl:import href="common_tinymce_scripts.xsl"/>
	<xsl:variable name="bodycontent">
		<xsl:call-template name="body"/>
	</xsl:variable>
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default"/>
			<body onload="timeoutWYSIWYGChange(2);">
				<xsl:call-template name="header"/>
				<div class="edit">
					<div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-edit"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
						<form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" id="create-edit-form">
							<!--<table border="0" width="98%">-->
							<!--<xsl:call-template name="tr-locationtitle-edit_doc"/>-->
							<xsl:call-template name="tr-locationtitle-edit"/>
							<xsl:call-template name="tr-body-edit_tinymce"/>
							<xsl:call-template name="tr-keywords-edit"/>
							<xsl:call-template name="tr-abstract-edit"/>
							<xsl:call-template name="markednew"/>
							<xsl:call-template name="expandrefs"/>
							<!-- </table>-->
							<xsl:call-template name="saveedit"/>
							<!--<xsl:call-template name="canceledit"/>-->
						</form>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
				</div>
				<xsl:call-template name="script_bottom"/>
				<xsl:call-template name="tinymce_scripts"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template name="title">
		<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
    </xsl:template>
	<xsl:template name="tr-body-edit_tinymce">
		<div>
			<label for="body">Body</label>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
			<br/>
			<textarea name="body" id="body" rows="24" cols="32" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;">
				<xsl:text>&lt;p&gt;&#160;&lt;/p&gt;</xsl:text>
				<xsl:value-of select="$bodycontent"/>
			</textarea>
			<xsl:call-template name="jsorigbody"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
