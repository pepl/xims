<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: create_common.xsl 2188 2009-01-03 18:24:00Z susannetober $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>

	<xsl:variable name="bodycontent">
		<xsl:call-template name="body"/>
	</xsl:variable>
	<xsl:param name="pubonsave"><xsl:value-of select="/document/context/session/user/userprefs/publish_at_save"/></xsl:param>
	<xsl:param name="usertype"><xsl:value-of select="/document/context/session/user/userprefs/profile_type"/></xsl:param>
    <xsl:param name="codemirror" select="false()"/>
	<xsl:param name="selEditor" select="false()"/>	
	<xsl:param name="testlocation" select="true()"/>
	<xsl:param name="simpledb" select="false()"/>
	<xsl:param name="reflib" select="false()"/>
	<xsl:param name="vlib" select="false()"/>
	
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">create</xsl:with-param>
				<xsl:with-param name="reflib" select="$reflib"/>
				<xsl:with-param name="vlib" select="$vlib"/>
				<xsl:with-param name="simpledb" select="$simpledb"/>
			</xsl:call-template>
			<body>
				<!--<xsl:if test="$selEditor">
					<xsl:attribute name="onload">timeoutWYSIWYGChange(2);</xsl:attribute>
				</xsl:if>-->
				<xsl:call-template name="header">
					<xsl:with-param name="containerpath">true</xsl:with-param>
				</xsl:call-template>
				<div class="edit">
					<xsl:call-template name="heading"><xsl:with-param name="mode">create</xsl:with-param><!--<xsl:with-param name="selEditor" select="$selEditor"/>--></xsl:call-template>
					<xsl:call-template name="cancelcreateform"/>
					
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
						<form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" id="create-edit-form" enctype="multipart/form-data">
						<input type="hidden" name="objtype" value="{$objtype}"/>
						
						<xsl:call-template name="create-content"/>
						
						<xsl:call-template name="saveedit"/>
						</form>
						<br/>
					</div>

						<xsl:call-template name="cancelcreateform"/>
				</div>
				<xsl:call-template name="script_bottom">
                    <xsl:with-param name="codemirror" select="$codemirror"/>
					<xsl:with-param name="testlocation" select="$testlocation"/>
					<xsl:with-param name="simpledb" select="$simpledb"/>
					<xsl:with-param name="reflib" select="$reflib"/>
					<xsl:with-param name="vlib" select="$vlib"/>
				</xsl:call-template>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="create-content">
	</xsl:template>
	
	</xsl:stylesheet>