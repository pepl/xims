<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: simpledb_default.xsl 2241 2009-08-03 14:02:50Z susannetober $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml" xmlns:aaa="http://www.w3.org/2005/07/aaa" exclude-result-prefixes="exslt" >

	<xsl:import href="view_common.xsl"/>
	<xsl:import href="container_common.xsl"/>
	<xsl:import href="simpledb_common.xsl"/>
	
	<xsl:param name="simpledb">true</xsl:param>
	<xsl:param name="createwidget">default</xsl:param>
	
	<xsl:param name="onepage"/>
	<xsl:param name="searchstring"/>
	<xsl:variable name="objectitems_count">
		<xsl:choose>
			<xsl:when test="/document/context/object/children/@totalobjects">
				<xsl:value-of select="/document/context/object/children/@totalobjects"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="objectitems_rowlimit">
		<xsl:choose>
			<xsl:when test="/document/context/object/attributes/pagerowlimit != ''">
				<xsl:value-of select="/document/context/object/attributes/pagerowlimit"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$searchresultrowlimit"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="totalpages" select="ceiling($objectitems_count div $objectitems_rowlimit)"/>
	
	<xsl:template name="view-content">
		<xsl:if test="/document/member_properties/member_property[1]">
			<div id="simpledb_resulttitle">
				<div>
					<xsl:if test="$searchstring != ''">
						<strong><xsl:value-of select="$i18n/l/Search_for"/></strong>:
						<span class="simpledb_filter">'<xsl:value-of select="$searchstring"/>'</span>.
						<a href="{$xims_box}{$goxims_content}{$absolute_path}">Reset search</a>
					</xsl:if>
				</div>
				<div>
				<xsl:call-template name="items_page_info"/>
				</div>
			</div>
			<xsl:call-template name="simpledb.itemsearch"/>
			<xsl:call-template name="childrenlist"/>
			<xsl:call-template name="pagenav">
				<xsl:with-param name="totalitems" select="$objectitems_count"/>
				<xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
				<xsl:with-param name="currentpage" select="$page"/>
				<xsl:with-param name="url" select="concat($xims_box,$goxims_content,$absolute_path,'?searchstring=',$searchstring,';')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
  
	<xsl:template name="childrenlist">
		<div id="simpledb_childrenlist">
			<xsl:apply-templates select="children/object" mode="divlist">
				<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>
	
	<xsl:template match="children/object" mode="divlist">
		<xsl:variable name="abstract" select="normalize-space(abstract)"/>
		<div class="simpledb_childrenlistitem" id="simpledbchildrenlistitem{position()}">
			<div class="simpledb_membertitle div-left">
				<xsl:call-template name="simpledbmembertitle"/>
				<xsl:text>&#xa0;</xsl:text>(id: <xsl:value-of select="@document_id"/>)
			</div>
			<xsl:call-template name="state-toolbar"/>
			<xsl:call-template name="options-toolbar">
				<xsl:with-param name="email-disabled" select="false()"/>
			</xsl:call-template>
			<xsl:call-template name="last_modified"/>
			<xsl:if test="$abstract != ''">
				<div class="simpledbabstract">
					<xsl:value-of select="$abstract"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="last_modified">
		<div class="simpledb_lastmodified">
			<strong>
				<xsl:value-of select="$i18n/l/Last_modified"/>:
      </strong>
			<xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
		</div>
	</xsl:template>
	
	<xsl:template name="simpledbmembertitle">
		<strong>
			<a title="{location}" href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
				<xsl:apply-templates select="member_values/member_value[property_id=/document/member_properties/member_property[part_of_title=1]/@id]" mode="title">
					<xsl:sort select="/document/member_properties/member_property[@id=current()/property_id]/position" order="ascending"/>
				</xsl:apply-templates>
			</a>
		</strong>
	</xsl:template>
	
	<xsl:template name="items_page_info">
    (<xsl:value-of select="$objectitems_count"/>
		<xsl:text> </xsl:text>
		<xsl:call-template name="decide_plural"/>
		<xsl:if test="$onepage = '' and $totalpages > 0">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$i18n/l/Page"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$page"/>/<xsl:value-of select="$totalpages"/>
		</xsl:if>
		<xsl:text>)</xsl:text>
	</xsl:template>
	<xsl:template name="decide_plural">
		<xsl:choose>
			<xsl:when test="number($objectitems_count) = 1">
				<xsl:value-of select="$i18n_simpledb/l/Item"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$i18n_simpledb/l/Items"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="simpledb.itemsearch">
		<div id="simpledb_itemsearch">
			<label for="searchstring">
				<xsl:value-of select="$i18n/l/Search_for"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_simpledb/l/Items"/>
			</label>
			<xsl:text>&#160;(</xsl:text>
			<xsl:value-of select="$i18n_simpledb/l/Looking_in"/>
			<xsl:apply-templates select="/document/member_properties/member_property[mandatory=1]" mode="namelist"/>)
			<xsl:value-of select="$i18n_simpledb/l/or_by_field_value"/>&#160;:
			<form action="{$xims_box}{$goxims_content}{$absolute_path}">
				<input type="text" name="searchstring" id="searchstring" size="17" maxlength="200">
					<xsl:if test="$searchstring != ''">
						<xsl:attribute name="value">
							<xsl:value-of select="$searchstring"/>
						</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:text>&#160;</xsl:text>
				<button type="submit" name="submit"><xsl:value-of select="$i18n/l/Search"/></button>
			</form>
		</div>
	</xsl:template>

<xsl:template name="create-widget">
	<div id="create-widget">
		<button><xsl:value-of select="$i18n/l/Create"/></button>
		<ul style="position:absolute !important;">
			<li><a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype=SimpleDBItem">SimpleDBItem</a></li>
		</ul>
		<noscript>Fehler!</noscript>
	</div>
</xsl:template>
	
	<xsl:template name="map_item_properties">
		<form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0; display: inline" method="get" id="map_item_properties" name="map_item_properties">
			<input type="submit" name="edit" alt="{$i18n_simpledb/l/Map_Item_Properties}" title="{$i18n_simpledb/l/Map_Item_Properties}" value="{$i18n_simpledb/l/Map_Item_Properties}"/>
			<input name="page" type="hidden" value="{$page}"/>
			<input name="r" type="hidden" value="{/document/context/object/@id}"/>
			<xsl:if test="$defsorting != 1">
				<input name="sb" type="hidden" value="{$sb}"/>
				<input name="order" type="hidden" value="{$order}"/>
			</xsl:if>
		</form>
	</xsl:template>
	
	<xsl:template match="member_property" mode="namelist">
    '<xsl:value-of select="name"/>'<xsl:if test="position()!=last()">, </xsl:if>
	</xsl:template>
	<xsl:template match="member_value" mode="title">
		<xsl:value-of select="value"/>
		<xsl:if test="position()!=last()">, </xsl:if>
	</xsl:template>
</xsl:stylesheet>
