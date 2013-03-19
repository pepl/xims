<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_move_browse.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="common.xsl"/>
	
	<xsl:variable name="target_path">
		<xsl:call-template name="targetpath"/>
	</xsl:variable>
	
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">move</xsl:with-param>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>
					<div id="content-container">
					<h1 class="bluebg"><xsl:value-of select="$i18n/l/Move_object"/> '<xsl:value-of select="title"/>'</h1>
						<form action="{$xims_box}{$goxims_content}" method="get" id="create-edit-form" name="eform">
							<xsl:value-of select="$i18n/l/from"/> '<xsl:value-of select="$parent_path"/>'
							<label for="input-to">
								<xsl:value-of select="$i18n/l/to"/>
							</label>:
							<input type="text" size="60" name="to" id="input-to">
								<xsl:choose>
									<xsl:when test="$target_path != $absolute_path">
										<xsl:attribute name="value">
											<xsl:value-of select="$target_path"/>
										</xsl:attribute>
									</xsl:when>
								</xsl:choose>
							</input>
							<xsl:text> </xsl:text>
							<button type="submit" name="store" id="store"><xsl:value-of select="$i18n/l/Move_object"/></button>
							<br/>
							<br/>
							<xsl:value-of select="$i18n/l/browse_target"/>:
							<br/>&#xa0;
							<xsl:apply-templates select="targetparents/object[@document_id !=1]"/>
							<xsl:apply-templates select="target/object"/>
							<div>
								<xsl:apply-templates select="targetchildren/object[@id != /document/context/object/@id and marked_deleted !='1']">
									<xsl:sort select="title" order="ascending" case-order="lower-first"/>
								</xsl:apply-templates>
							</div>
							<input type="hidden" name="id" value="{@id}"/>
							<input type="hidden" name="move" value="1"/>
							<input type="hidden" name="sb" value="position"/>
							<input type="hidden" name="order" value="desc"/>
						</form>
						<br/>
						<button type="button" name="default" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
					</div>
				<xsl:call-template name="script_bottom"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="targetparents/object|target/object">
      / <a class="">
			<xsl:attribute name="href">
				<xsl:value-of select="concat($xims_box,$goxims_content,'?id=',/document/context/object/@id,';move_browse=1;to=',@id)"/>
			</xsl:attribute>
			<xsl:value-of select="location"/>
		</a>
	</xsl:template>
	
	<xsl:template match="targetchildren/object">
		<img src="{$ximsroot}images/icons/list_Container.gif" alt="Container" width="20" height="18"/>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="concat($xims_box,$goxims_content,'?id=',/document/context/object/@id,';move_browse=1;to=',@id)"/>
				<xsl:call-template name="rbacknav_qs"/>
			</xsl:attribute>
			<xsl:value-of select="title"/>
		</a>
		<br/>
	</xsl:template>
</xsl:stylesheet>
