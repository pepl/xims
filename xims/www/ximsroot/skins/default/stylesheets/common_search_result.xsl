<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_search_result.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="container_common.xsl"/>

<xsl:variable name="objectitems_count">
    <xsl:value-of select="/document/context/session/searchresultcount"/>
</xsl:variable>
<xsl:variable name="totalpages" select="ceiling($objectitems_count div $searchresultrowlimit)"/>

<xsl:template match="/document/context/object">
	<html>
		<xsl:call-template name="head_default"/>
		<body>
			<xsl:call-template name="header" />
			<div id="content-container">
				<h1 class="bluebg"><xsl:value-of select="$i18n/l/Search_for"/>&#160;'<xsl:value-of select="$s"/>'</h1>
				<p><xsl:apply-templates select="/document/context/session/message"></xsl:apply-templates></p>
			<table class="obj-table">
				<xsl:call-template name="tableheader"/>
			</table>
			<xsl:if test="$totalpages">
				<xsl:call-template name="pagenav">
					<xsl:with-param name="totalitems" select="/document/context/session/searchresultcount"/>
					<xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
					<xsl:with-param name="currentpage" select="$page"/>
					<xsl:with-param name="url" select="concat($xims_box,$goxims_content,$absolute_path,'?s=',$s,';search=1;start_here=',$start_here,';')"/>
				</xsl:call-template>
			</xsl:if>
		</div>
		<xsl:call-template name="script_bottom"/>
	</body>
	</html>
</xsl:template>

<xsl:template name="title">
	<xsl:value-of select="$i18n/l/Search_for"/> '<xsl:value-of select="$s"/>' - XIMS
</xsl:template>

<xsl:template name="tableheader">
<xsl:variable name="location" select="concat($goxims_content,$absolute_path)"/>
	<tr>
	<!-- status -->
	<th id="th-status">
		<a class="th-icon-right">
			<xsl:value-of select="$i18n/l/Status"/>
		</a>
	</th>
	<!-- title-icon / dataformat-->
	<th id="th-titel-icon">&#160;</th>
	<!-- title -->
	<xsl:choose>
		<xsl:when test="$sb='title'">
			<xsl:choose>
				<xsl:when test="$order='asc'">
					<th id="th-title" class="sorting">
						<a href="{$location}?s={$s};search=1;sb=title;order=desc" class="th-icon-right">
							<span class="ui-icon ui-icon-triangle-1-n"><xsl:comment/></span>
							<xsl:value-of select="$i18n/l/Title"/>&#160;						
						</a>
					</th>
				</xsl:when>
				<xsl:otherwise>
					<th id="th-title" class="sorting">
						<a href="{$location}?s={$s};search=1;sb=title;order=asc" class="th-icon-right">
							<span class="ui-icon ui-icon-triangle-1-s"><xsl:comment/></span>
							<xsl:value-of select="$i18n/l/Title"/>&#160;						
						</a>
					</th>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<th id="th-title" class="sorting">
				<a href="{$location}?s={$s};search=1;sb=title;order=asc" class="th-icon-right">
					<span class="ui-icon ui-icon-triangle-2-n-s"><xsl:comment/></span>
					<xsl:value-of select="$i18n/l/Title"/>&#160;						
				</a>
			</th>
		</xsl:otherwise>
	</xsl:choose>
	<!-- last modified -->
	<xsl:choose>
		<xsl:when test="$sb='date'">
			<xsl:choose>
				<xsl:when test="$order='asc'">
					<th id="th-lastmod" class="sorting">
						<a href="{$location}?s={$s};search=1;sb=date;order=desc" class="th-icon-right">
							<span class="ui-icon ui-icon-triangle-1-n"><xsl:comment/></span>
							<xsl:value-of select="$i18n/l/Last_modified"/>&#160;						
						</a>
					</th>
				</xsl:when>
				<xsl:otherwise>
					<th id="th-lastmod" class="sorting">
						<a href="{$location}?s={$s};search=1;sb=date;order=asc" class="th-icon-right">
							<span class="ui-icon ui-icon-triangle-1-s"><xsl:comment/></span>
							<xsl:value-of select="$i18n/l/Last_modified"/>&#160;						
						</a>
					</th>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<th id="th-lastmod" class="sorting">
				<a href="{$location}?s={$s};search=1;sb=date;order=desc" class="th-icon-right">
					<span class="ui-icon ui-icon-triangle-2-n-s"><xsl:comment/></span>
					<xsl:value-of select="$i18n/l/Last_modified"/>&#160;						
				</a>
			</th>
		</xsl:otherwise>
	</xsl:choose>
	<!-- size -->
	<xsl:call-template name="th-size"/>
	</tr>
	<xsl:choose>
		<xsl:when test="$sb='title'">
			<xsl:choose>
				<xsl:when test="$order='asc'">
				<xsl:apply-templates select="/document/objectlist/object">
					<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$order='desc'">
					<xsl:apply-templates select="/document/objectlist/object">
						<!-- as long as lower-first is not implemented, we probably have to use lowercase the title here -->
						<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="descending"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$sb='date'">
			<xsl:choose>
				<xsl:when test="$order='asc'">
					<xsl:apply-templates select="/document/objectlist/object">
						<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="ascending"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$order='desc'">
					<xsl:apply-templates select="/document/objectlist/object">
						<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:when>					
		<xsl:otherwise>
			<xsl:apply-templates select="/document/objectlist/object">
				<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="objectlist/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    	<tr class="objrow">
<!-- status -->
  <td class="ctt_status">
    <xsl:call-template name="state-toolbar"/>
  </td>
<!-- dataformat icon -->
			<td class="ctt_df">
				<xsl:call-template name="cttobject.dataformat"/>
			</td>

<!-- title, location_path, abstract -->
			<td class="ctt_loctitle" style="white-space:normal;">
				<xsl:call-template name="cttobject.locationtitle">
						<xsl:with-param name="search">true</xsl:with-param>
						<xsl:with-param name="location_path"><xsl:value-of select="location_path"/></xsl:with-param>
				</xsl:call-template>
            <div class="location_path">
                <p><xsl:value-of select="location_path"/></p>
            </div>
            <div class="abstract">
                <xsl:value-of select="abstract"/>
            </div>
        </td>
<!-- last modification -->
        <td class="ctt_lm">
            <xsl:call-template name="cttobject.last_modified"/>
        </td>
<!-- size -->
        <td class="ctt_cl">
            <xsl:call-template name="cttobject.content_length"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
