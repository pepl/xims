<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_create_tinymce.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="document_common.xsl"/>
	<xsl:import href="common_tinymce_scripts.xsl"/>
	<xsl:import href="common_header.xsl"/>
	<xsl:template match="/document/context/object">
	
		<html>
			<xsl:call-template name="head_default"/>
			<body onload="timeoutWYSIWYGChange(2); document.eform['abstract'].value=''; document.eform.name.focus();">
				<xsl:call-template name="header">
					<xsl:with-param name="create">true</xsl:with-param>				
				</xsl:call-template>
				<div class="edit">
					<div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-create"/>
					</div>
					<div class="cancel-save">
					<xsl:call-template name="cancelcreateform">
						<xsl:with-param name="with_save">yes</xsl:with-param>
					</xsl:call-template>
					</div>
					<div id="table-container" class="ui-corner-bottom ui-corner-tr">
						<form id="create-edit-form" action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST">
						<input type="hidden" name="objtype" value="{$objtype}"/>
						<xsl:call-template name="tr-locationtitle-create"/>
							<xsl:call-template name="tr-body-create_tinymce"/>
							<xsl:call-template name="tr-keywords-create"/>
							<xsl:call-template name="tr-abstract-create"/>
							<xsl:call-template name="markednew"/>
							<xsl:call-template name="expandrefs"/>
							<xsl:call-template name="grantowneronly"/>

						<xsl:call-template name="saveaction"/>
					</form>
					</div>
					<div class="cancel-save">
					<xsl:call-template name="cancelcreateform">
						<xsl:with-param name="with_save">yes</xsl:with-param>
					</xsl:call-template>
					</div>
				</div>
				<!--<xsl:call-template name="cancelaction"/>-->
				<xsl:call-template name="script_bottom"/>
				<xsl:call-template name="tinymce_scripts"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template name="title">
		<xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
</xsl:template>

	<xsl:template name="tr-body-create_tinymce">
		<!--<tr>
			<td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
				<br/>
				<textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32" onChange="document.getElementById('xims_wysiwygeditor').disabled = true;">
					<xsl:text>&lt;p&gt;&#160;&lt;/p&gt;</xsl:text>
				</textarea>
				<xsl:call-template name="jsorigbody"/>
			</td>
		</tr>-->
		<div>
            <label for="body">Body</label>
            <xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
				<br/>
				<textarea name="body" id="body" rows="24" cols="32" onChange="document.getElementById('xims_wysiwygeditor').disabled = true;">
					<xsl:text>&lt;p&gt;&#160;&lt;/p&gt;</xsl:text>
				</textarea>
				<xsl:call-template name="jsorigbody"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
