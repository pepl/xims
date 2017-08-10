<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_movemultiple_browse.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="common.xsl"/>
	
	<xsl:variable name="target_path">
		<xsl:call-template name="targetpath"/>
	</xsl:variable>
	
	<xsl:variable name="selected">
		<xsl:for-each select="/document/objectlist/object">
			multiselect=<xsl:value-of select="@id"/>&amp;
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">move</xsl:with-param>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>
				<div id="content-container">
					<h1 class="bluebg"><xsl:value-of select="$i18n/l/Move_objects"/></h1>
					
				<xsl:choose>
					<xsl:when test="not(/document/objectlist)">
						<p><xsl:value-of select="$i18n/l/NoObjects"/></p>
					</xsl:when>
					<xsl:otherwise>
						<form action="{$xims_box}{$goxims_content}" method="post" id="create-edit-form" name="eform">
                          <xsl:call-template name="input-token"/>
	                      <p><xsl:value-of select="$i18n/l/AboutMoveMultiple"/></p>
						<xsl:apply-templates select="/document/objectlist/object" />
						<p><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/MoveNotice"/></p>

						<xsl:value-of select="$i18n/l/from"/> '<xsl:value-of select="location_path"/>'
						<label for="input-to">
							<xsl:value-of select="$i18n/l/to"/>
						</label>:
						<input type="text" size="60" name="to" id="input-to">
							<xsl:attribute name="value">
								<xsl:value-of select="$target_path"/>
							</xsl:attribute>
						</input>
						<xsl:text> </xsl:text>
						<button type="submit" name="movemultiple" id="movemultiple" class="button"><xsl:value-of select="$i18n/l/Move_objects"/></button>
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
						<input type="hidden" name="sb" value="position"/>
						<input type="hidden" name="order" value="desc"/>
						</form>
					</xsl:otherwise>
				</xsl:choose>
						<br/>
						<button type="button" name="default" class="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
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
				(<xsl:value-of select="location_path"/>) <xsl:call-template name="button.state.publish"/>
			</p>
			<input type="hidden" name="multiselect" value="{@id}"/>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template match="targetparents/object|target/object">
      / <a class="">
			<xsl:attribute name="href">
				<xsl:value-of select="concat($xims_box,$goxims_content,'?id=',/document/context/object/@id,'&amp;movemultiple_browse=1&amp;to=',@id,'&amp;',$selected)"/>
			</xsl:attribute>
			<xsl:value-of select="location"/>
		</a>
	</xsl:template>
	
	<xsl:template match="targetchildren/object">
		<img src="{$ximsroot}images/icons/list_Container.gif" alt="Container" width="20" height="18"/>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="concat($xims_box,$goxims_content,'?id=',/document/context/object/@id,'&amp;movemultiple_browse=1&amp;to=',@id,'&amp;',$selected)"/>
				<xsl:call-template name="rbacknav_qs"/>
			</xsl:attribute>
			<xsl:value-of select="title"/>
		</a>
		<br/>
	</xsl:template>
	
</xsl:stylesheet>
