<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_delete_confirm.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="common_header.xsl"/>
	<!--<xsl:output method="html" encoding="utf-8"/>-->
	<xsl:param name="id"/>
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">delete</xsl:with-param>
			</xsl:call-template>

			<body>
				<xsl:call-template name="header">
					<!--<xsl:with-param name="noncontent">true</xsl:with-param>
					<xsl:with-param name="nopath">true</xsl:with-param>-->
				</xsl:call-template>
				<div id="content-container">
					<form name="objectdeletion" action="{$xims_box}{$goxims_content}" method="get">
						<h1 class="bluebg"><xsl:value-of select="$i18n/l/DeleteConfirm"/></h1>
						<p><xsl:value-of select="$i18n/l/AboutDeletion1"/> '<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/AboutDeletion2"/></p>
						<p><strong><xsl:value-of select="$i18n/l/WarnNoUndo"/></strong></p>
						<p><xsl:value-of select="$i18n/l/ClickCancelConf"/></p>
						<div id="confirm-buttons">
							<input class="ui-state-default ui-corner-all fg-button" name="delete" type="submit">
							<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Confirm"/></xsl:attribute>
							</input>
							<input name="id" type="hidden" value="{$id}"/>
                        &#160;
                        <input type="button" class="ui-state-default ui-corner-all fg-button" name="default" onclick="javascript:history.go(-1)">
                        <xsl:attribute name="value"><xsl:value-of select="$i18n/l/cancel"/></xsl:attribute></input>
						</div>
					</form>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
