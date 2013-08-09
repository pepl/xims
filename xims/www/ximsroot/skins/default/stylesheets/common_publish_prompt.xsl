<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
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
			<xsl:call-template name="head_default"/>
			<body>
				<xsl:call-template name="header"/>
				
				<div id="content-container" class="publish-dialog"> 
					<form name="objPublish" id="objPublish" action="{$xims_box}{$goxims_content}" method="get">
						<h1 class="bluebg"><xsl:value-of select="$i18n/l/Publishing_options"/></h1>
						<p>
							<strong><xsl:value-of select="$i18n/l/Status"/>: <xsl:value-of select="$i18n/l/Object"/> '<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/isCurrently"/>&#160;<xsl:if test="published!='1'"><xsl:value-of select="$i18n/l/NOT"/>
								&#160;</xsl:if><xsl:value-of select="$i18n/l/published"/></strong><br/>
							<xsl:if test="published='1'">
								<xsl:value-of select="$i18n/l/under"/> 
								<br/>
								<a href="{$published_path}" target="_new">
									<xsl:value-of select="$published_path"/>
								</a>
							</xsl:if>
						</p>

						<xsl:if test="message">
							<p>
							 <xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/ObjectHasDependencies"/>:
							 <xsl:call-template name="csv2ul">
									<xsl:with-param name="list" select="message"/>
								</xsl:call-template>
							<xsl:value-of select="$i18n/l/ObjSkipping"/>
							</p>
						</xsl:if>

						<xsl:if test="contains( attributes/text(), 'autoindex=1' )">
							<p>
								<strong><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/HasAutoindex"/></strong>.&#160;
								<xsl:choose>
									<xsl:when test="published='1'"><xsl:value-of select="$i18n/l/IndexIfRepublish"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$i18n/l/IndexIfPublish"/></xsl:otherwise>
								</xsl:choose>.
							</p>
						</xsl:if>
						
						<p>
            <xsl:value-of select="$i18n/l/Click"/>&#160;
            <xsl:choose>
								<xsl:when test="published='1'">'<xsl:value-of select="$i18n/l/Republish"/>'</xsl:when>
								<xsl:otherwise>'<xsl:value-of select="$i18n/l/Publish"/>'</xsl:otherwise>
						</xsl:choose>
            &#160;<xsl:value-of select="$i18n/l/toExpCurrObj"/>
            <xsl:if test="published='1'">,&#160;'<xsl:value-of select="$i18n/l/Unpublish"/>'&#160;<xsl:value-of select="$i18n/l/toRemoveFromLiveServer"/></xsl:if>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;'<xsl:value-of select="$i18n/l/cancel"/>'&#160;<xsl:value-of select="$i18n/l/toReturnPrev"/>.
					</p>

			<xsl:if test="/document/objectlist/object">
				<br/>
				<p><xsl:value-of select="$i18n/l/RelObjFound"/></p>
				<xsl:apply-templates select="/document/objectlist/object"/>
					<xsl:choose>
						<xsl:when test="/document/objectlist/object[location != '']">
							<p>
								<!--<input type="checkbox" name="selector" value="1"  id="selector" class="checkbox" onclick="switcher(this,'objids') ? document.forms[1].recpublish.checked = 1 : document.forms[1].recpublish.checked = 0;"/>-->
								<input type="checkbox" name="selector" value="1"  id="selector" class="checkbox" onclick="cbSwitcher($(this),'objids')"/>
								<label for="selector"><xsl:value-of select="$i18n/l/SelectAll"/></label>		
								<input type="hidden" name="autopublish" id="autopublish" value="1"/>							
							</p>
							<xsl:if test="/document/context/session/user/userprefs/profile_type != 'standard'">
								<p>
									<label for="recpublish"><xsl:value-of select="$i18n/l/PublishRecursive"/></label> 
									<input type="checkbox" name="recpublish" id="recpublish" value="1" class="checkbox"/>
								</p>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<p><xsl:value-of select="$i18n/l/NoRelObjFound"/></p>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<br/>
			<div>
				<br/>
				<label for="update_dependencies"><xsl:value-of select="$i18n/l/UpdateDepend"/></label> 
				<input type="checkbox" name="update_dependencies" value="1" checked="checked" id="update_dependencies" class="checkbox"/>
			</div>
			<br class="clear"/>
			<div>
				<label for="verbose_result"><xsl:value-of select="$i18n/l/ShowDetailsOfPub"/></label>
				<input type="checkbox" name="verbose_result" value="1" id="verbose_result" class="checkbox"/>
			</div>
			
			<br class="clear"/>
			<div id="confirm-buttons">
				<br/>
					<button name="publish" type="submit">
						<xsl:choose>
							<xsl:when test="published='1'">
								<xsl:value-of select="$i18n/l/Republish"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$i18n/l/Publish"/>
							</xsl:otherwise>
						</xsl:choose>
					</button>
					<input name="id" type="hidden" value="{@id}"/>
					<!--<xsl:call-template name="rbacknav"/>-->
					&#160;
					<xsl:if test="published='1'">
						<button name="unpublish" type="submit"><xsl:value-of select="$i18n/l/Unpublish"/></button>
						
						&#160;
					</xsl:if>
					<button name="default" type="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
				</div>
			</form>
		</div>
		<xsl:call-template name="script_bottom"/>
	</body>
</html>
</xsl:template>
	
	<xsl:template match="/document/objectlist/object">
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<p>
			<input type="checkbox" name="objids" value="{@id}" class="checkbox" id="objid-{@id}">
				<xsl:choose>
					<xsl:when test="string-length(location) &lt;= 0">
						<xsl:attribute name="disabled">disabled</xsl:attribute>
					</xsl:when>
					<xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &gt; concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</input>
			<xsl:call-template name="cttobject.dataformat">
				<xsl:with-param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>
			</xsl:call-template>&#160;
			<label for="objid-{@id}">
				<xsl:value-of select="title"/>
				</label>
				&#160;
				(<xsl:value-of select="location_path"/>)
				<xsl:call-template name="button.state.publish"/>
		</p>
	</xsl:template>

	<xsl:template name="title">
				<xsl:value-of select="$i18n/l/Confirm_publishing"/> - XIMS
	</xsl:template>
	
	<xsl:template name="csv2ul">
		<xsl:param name="list"/>
		<ul>
			<xsl:call-template name="csv2li">
				<xsl:with-param name="list" select="$list"/>
			</xsl:call-template>
		</ul>
	</xsl:template>
	<xsl:template name="csv2li">
		<xsl:param name="list"/>
		<xsl:variable name="item" select="substring-before($list, ',')"/>
		<xsl:variable name="rest" select="substring-after($list, ',')"/>
		<xsl:choose>
			<xsl:when test="$item">
				<li>
					<xsl:value-of select="$item"/>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<xsl:value-of select="$list"/>
				</li>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$rest">
			<xsl:call-template name="csv2li">
				<xsl:with-param name="list" select="$rest"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
