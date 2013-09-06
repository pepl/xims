<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_publish_prompt.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:param name="id"/>
	<xsl:variable name="objecttype">
		<xsl:value-of select="/document/context/object/object_type_id"/>
	</xsl:variable>
	<xsl:variable name="publish_gopublic">
		<xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
	</xsl:variable>
	<xsl:variable name="published_path_base">
		<xsl:choose>
			<xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
				<xsl:value-of select="$absolute_path_nosite"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$absolute_path"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="object_path">
		<xsl:value-of select="$published_path_base"/>
	</xsl:variable>
	<xsl:variable name="published_path">
		<xsl:choose>
			<xsl:when test="$publish_gopublic = 0">
				<xsl:value-of select="concat($publishingroot,$object_path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(/document/context/session/serverurl,$gopublic_content,$object_path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">publish</xsl:with-param>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>
				
				<div id="content-container" class="publish-dialog"> 
				<h1 class="bluebg"><xsl:value-of select="$i18n/l/Publishing_options"/></h1>
					<xsl:choose>
					<xsl:when test="not(/document/objectlist)">
						<p><xsl:value-of select="$i18n/l/NoObjects"/></p>
						<br/>
						<button name="default" type="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
					</xsl:when>
					<xsl:otherwise>
					<form name="objPublish" id="objPublish" action="{$xims_box}{$goxims_content}" method="get">						
						<p><xsl:value-of select="$i18n/l/AboutPublishMultiple"/></p>
						<xsl:apply-templates select="/document/objectlist/object" />
						<p><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/PublishingNotice"/></p>

						<!--<xsl:if test="message">
							<p>
							 <xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/ObjectHasDependencies"/>:
							 <xsl:call-template name="csv2ul">
									<xsl:with-param name="list" select="message"/>
								</xsl:call-template>
							<xsl:value-of select="$i18n/l/ObjSkipping"/>
							</p>
						</xsl:if>-->
<!--
						<xsl:if test="contains( attributes/text(), 'autoindex=1' )">
							<p>
								<strong><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/HasAutoindex"/></strong>.&#160;
								<xsl:choose>
									<xsl:when test="published='1'"><xsl:value-of select="$i18n/l/IndexIfRepublish"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$i18n/l/IndexIfPublish"/></xsl:otherwise>
								</xsl:choose>.
							</p>
						</xsl:if>-->						
							<p>
								<label for="recpublish"><xsl:value-of select="$i18n/l/PublishRecursive"/></label> 
								<input type="checkbox" name="recpublish" id="recpublish" value="1" class="checkbox"/>
								<input type="hidden" name="autopublish" id="autopublish" value="1"/><br/>
								(<xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/RecUnpublishNotice"/>)
							</p>							
				<br/>
			<p>
				<br/>
				<label for="update_dependencies"><xsl:value-of select="$i18n/l/UpdateDepend"/></label> 
				<input type="checkbox" name="update_dependencies" value="1" checked="checked" id="update_dependencies" class="checkbox"/>
			</p>
			<br class="clear"/>
			<p>
				<label for="verbose_result"><xsl:value-of select="$i18n/l/ShowDetailsOfPub"/></label>
				<input type="checkbox" name="verbose_result" value="1" id="verbose_result" class="checkbox"/>
			</p>
			
			<br class="clear"/>
			<p>
				<xsl:value-of select="$i18n/l/Click"/>&#160;
					'<xsl:value-of select="$i18n/l/Publish"/>'&#160;<xsl:value-of select="$i18n/l/toExpCurrObj"/>
				<xsl:if test="published='1'">,&#160;'<xsl:value-of select="$i18n/l/Unpublish"/>'&#160;<xsl:value-of select="$i18n/l/toRemoveFromLiveServer"/></xsl:if>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;'<xsl:value-of select="$i18n/l/cancel"/>'&#160;<xsl:value-of select="$i18n/l/toReturnPrev"/>.
			</p>
			<div id="confirm-buttons">
				<br/>
					<button name="publishmultiple" type="submit" class="button">
						<xsl:value-of select="$i18n/l/Publish"/>
					</button>
					<input name="id" type="hidden" value="{@id}"/>
					&#160;
					<button name="unpublishmultiple" type="submit" class="button"><xsl:value-of select="$i18n/l/Unpublish"/></button>
					&#160;
					<button name="default" type="button" class="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
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
			<p>
				<xsl:call-template name="cttobject.dataformat">
					<xsl:with-param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>
				</xsl:call-template>&#160;<xsl:value-of select="title"/>&#160;
				(<xsl:value-of select="location_path"/>) <xsl:call-template name="button.state.publish"/>
			</p>
			<input type="hidden" name="multiselect" value="{@id}"/>
	</xsl:template>	
</xsl:stylesheet>
