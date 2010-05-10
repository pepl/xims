<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforum_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="view_common.xsl"/>
	<xsl:import href="anondiscussionforum_common.xsl"/>
	<xsl:param name="createwidget">forum</xsl:param>
	
	<xsl:template name="view-content">
		<div id="docbody">
			<h1 class="documenttitle">
				<xsl:value-of select="title"/>
			</h1>
			<p>
				<strong>
					<xsl:apply-templates select="abstract"/>
				</strong>
			</p>
			<br/>
			<br/>
			<br/>
			<!--<xsl:variable name="topics"><xsl:value-of select="count(children/object)"/></xsl:variable>-->
			<xsl:if test="count(children/object)">
				<xsl:call-template name="forumtable"/>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="forumtable">
		<table class="obj-table">
			<thead>
				<tr>
					<th id="th-topic" class="sorting">
						<a href="{$xims_box}{$goxims_content}{$absolute_path}?sb=name&amp;order=desc" class="th-icon-right">
							<span class="ui-icon ui-icon-triangle-1-n"/>
							<xsl:value-of select="$i18n/l/Topic"/>
						</a>
					</th>
					<th id="th-created" class="sorting" nowrap="nowrap">
						<a href="?sb=date" class="th-icon-right">
							<span class="ui-icon ui-icon-triangle-1-n"/>
							<xsl:value-of select="$i18n/l/Created"/>
						</a>
					</th>
					<th id="th-author" width="134">
						<xsl:value-of select="$i18n/l/Author"/>
					</th>
					<th id="th-replies" width="50">
						<xsl:value-of select="$i18n/l/Replies"/>
					</th>
					<th id="th-lastreply" width="134">
						<xsl:value-of select="$i18n/l/Last_reply"/>
					</th>
					<th id="th-options" width="60">
						<xsl:value-of select="$i18n/l/Options"/>
					</th>
				</tr>
			</thead>
			<tbody>
				<!--<xsl:apply-templates select="children/object">-->
				<xsl:choose>
					<xsl:when test="$sb='name'">
						<xsl:choose>
							<xsl:when test="$order='asc'">
								<xsl:apply-templates select="children/object">
									<xsl:sort select="title" order="ascending" case-order="lower-first"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="$order='desc'">
								<xsl:apply-templates select="children/object">
									<xsl:sort select="title" order="descending"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$sb='date' or $sb='position'">
						<xsl:choose>
							<xsl:when test="$order='asc'">
								<xsl:apply-templates select="children/object">
									<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="ascending"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="$order='desc'">
								<xsl:apply-templates select="children/object">
									<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="children/object">
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<tr>
			<xsl:choose>
				<!-- begin sort by name -->
				<xsl:when test="$sb='name'">
					<td>
						<img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
						<xsl:text> </xsl:text>
						<a href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
							<xsl:value-of select="title"/>
						</a>
					</td>
					<td nowrap="nowrap" align="center">
						<xsl:apply-templates select="creation_timestamp" mode="datetime"/>
					</td>
				</xsl:when>
				<!-- end sort by name -->
				<!-- begin sort by date -->
				<xsl:when test="$sb='date' or $sb='position'">
					<td>
						<img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
						<xsl:text> </xsl:text>
						<a href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
							<xsl:value-of select="title"/>
						</a>
					</td>
					<td nowrap="nowrap" align="center">
						<xsl:apply-templates select="creation_timestamp" mode="datetime"/>
					</td>
				</xsl:when>
				<!-- end sort by date -->
			</xsl:choose>
			<td align="left">
				<a>
					<xsl:attribute name="href">mailto:<xsl:value-of select="attributes/email"/>?subject=RE: <xsl:value-of select="title"/>
					</xsl:attribute>
					<xsl:value-of select="attributes/author"/>
				</a>
				<xsl:choose>
					<xsl:when test="attributes/coemail">,
                    <a>
							<xsl:attribute name="href">mailto:<xsl:value-of select="attributes/coemail"/>?subject=RE: <xsl:value-of select="title"/>
							</xsl:attribute>
							<xsl:value-of select="attributes/coauthor"/>
						</a>
					</xsl:when>
					<xsl:when test="attributes/coauthor">,<br/>
						<xsl:value-of select="attributes/coauthor"/>
					</xsl:when>
				</xsl:choose>
			</td>
			<td align="center">
				<xsl:value-of select="descendant_count"/>
			</td>
			<td nowrap="nowrap" align="center">
				<xsl:if test="descendant_count != '0'">
					<xsl:apply-templates select="descendant_last_modification_timestamp" mode="datetime"/>
				</xsl:if>
			</td>
			<td>
				<!--<xsl:if test="user_privileges/delete">
					<form name="delete" method="get" action="{$xims_box}{$goxims_content}" id="delete_{@id}">
						<input type="hidden" name="delete_prompt" value="1"/>
						<input type="hidden" name="id" value="{@id}"/>
						<input type="image" src="{$skimages}option_delete.png">						
							<xsl:attribute name="title">
								<xsl:value-of select="$i18n/l/delete"/>
							</xsl:attribute>
							<xsl:attribute name="alt">
								<xsl:value-of select="$i18n/l/delete"/>
							</xsl:attribute>
						</input>
					</form>
				</xsl:if>-->
				<form name="delete" method="get" action="{$xims_box}{$goxims_content}" id="delete_{@id}">
						<input type="hidden" name="delete_prompt" value="1"/>
						<input type="hidden" name="id" value="{@id}"/>
						<xsl:call-template name="button.options.delete"/>
				</form>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
