<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: edit_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>

	<xsl:variable name="bodycontent">
		<xsl:call-template name="body"/>
	</xsl:variable>
	<xsl:param name="pubonsave" ><xsl:value-of select="/document/context/session/user/userprefs/publish_at_save"/></xsl:param>
	<xsl:param name="usertype"><xsl:value-of select="/document/context/session/user/userprefs/profile_type"/></xsl:param>
	<xsl:param name="tinymce" select="false()"/>	
	<xsl:param name="tinymce2" select="false()"/>
	<xsl:param name="codemirror" select="false()"/>
	<xsl:param name="selEditor" select="false()"/>	
	<xsl:param name="testlocation" select="true()"/>
	<xsl:param name="simpledb" select="false()"/>
	<xsl:param name="reflib" select="false()"/>
	<xsl:param name="vlib" select="false()"/>
	<xsl:param name="questionnaire" select="false()"/>
	<xsl:param name="codemirror" select="false()"/>
	
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">edit</xsl:with-param>
				<xsl:with-param name="reflib" select="$reflib"/>
				<xsl:with-param name="vlib" select="$vlib"/>
				<xsl:with-param name="simpledb" select="$simpledb"/>
				<xsl:with-param name="questionnaire" select="$questionnaire"/>
				<xsl:with-param name="codemirror" select="$codemirror"/>
			</xsl:call-template>
			<body>
				<xsl:if test="$selEditor and not(attributes/geekmode='1')">
					<xsl:attribute name="onload">timeoutEditorChange(2, '<xsl:value-of select="$selEditor"/>');</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="header"/>
				<div class="edit">
					<xsl:call-template name="heading"><xsl:with-param name="mode">edit</xsl:with-param><xsl:with-param name="selEditor" select="$selEditor"></xsl:with-param></xsl:call-template>
					<xsl:call-template name="cancelform"/>
					
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
					  <form action="{$xims_box}{$goxims_content}?id={@id}"
                            name="eform" 
                            method="post" 
                            id="create-edit-form"
                            enctype="multipart/form-data">
                        <xsl:call-template name="input-token"/>
						
						<xsl:call-template name="edit-content"/>
						<xsl:call-template name="saveedit"/>
						</form>
					</div>
					
					<xsl:if test="reflib">
						<form action="{$xims_box}{$goxims_content}" name="reftypechangeform" method="get" style="display:none">
							<input type="hidden" name="id" value="{@id}"/>
							<input type="hidden" name="change_reference_type" value="1"/>
							<input type="hidden" name="reference_type_id" value=""/>
							<xsl:call-template name="rbacknav"/>
						</form>
					</xsl:if>
					
						<xsl:call-template name="cancelform-copy"/>
				</div>
				<xsl:call-template name="script_bottom">
					<xsl:with-param name="tinymce" select="$tinymce"/>
					<xsl:with-param name="tinymce2" select="$tinymce2"/>
					<xsl:with-param name="codemirror" select="$codemirror"/>
					<xsl:with-param name="testlocation" select="$testlocation"/>
					<xsl:with-param name="simpledb" select="$simpledb"/>
					<xsl:with-param name="reflib" select="$reflib"/>
					<xsl:with-param name="vlib" select="$vlib"/>
					<xsl:with-param name="questionnaire" select="$questionnaire"/>
				</xsl:call-template>
				<!--<script type="text/javascript" >
      var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,/document/context/object/location_path)"/>';
      </script>-->
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="edit-content">
	</xsl:template>
	
	</xsl:stylesheet>
