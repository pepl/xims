<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_trashcan_confirm.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="common_header.xsl"/>
	<xsl:param name="id"/>
	<xsl:template match="/document/context/object">
		<html>
		<xsl:call-template name="head_default">
				<xsl:with-param name="mode">delete</xsl:with-param>
			</xsl:call-template>

			<body>
				<xsl:call-template name="header"/>
				<div id="content-container">
					<h1 class="bluebg"><xsl:value-of select="$i18n/l/DeleteConfirmMultiple"/></h1>
					<xsl:choose>
					<xsl:when test="not(/document/objectlist)">
						<p><xsl:value-of select="$i18n/l/NoObjects"/></p>
						<br/>
						<button name="default" type="button" class="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
					</xsl:when>
					<xsl:otherwise>
					  <form action="{$xims_box}{$goxims_content}" method="post">
                        <xsl:call-template name="input-token"/>
						<p><xsl:value-of select="$i18n/l/AboutDeletionMultiple"/></p>
						<xsl:apply-templates select="/document/objectlist/object" />
						<p><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/DeletionNotice"/></p>
							<p><strong><xsl:value-of select="$i18n/l/WarnNoUndo"/></strong></p>
						<p><xsl:value-of select="$i18n/l/ClickCancelConf"/></p>
						<div id="confirm-buttons">
							<button name="deletemultiple" type="submit" class="button">
							<xsl:value-of select="$i18n/l/Confirm"/>
							</button>
							<input name="id" type="hidden" value="{@id}"/>
							<!--<input type="hidden" name="forcetrash" value="1"/>-->
						&#160;
						<button type="button" name="default" class="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
						</div>
					</form>
					</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:call-template name="script_bottom"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="objectlist/object">
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:if test="published != 1">
			<p>
				<xsl:call-template name="cttobject.dataformat">
					<xsl:with-param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>
				</xsl:call-template>&#160;<xsl:value-of select="title"/>&#160;
				(<xsl:value-of select="location_path"/>)
			</p>
			<input type="hidden" name="multiselect" value="{@id}"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
