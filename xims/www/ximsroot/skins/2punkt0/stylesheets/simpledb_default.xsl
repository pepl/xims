<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: simpledb_default.xsl 2241 2009-08-03 14:02:50Z susannetober $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="exslt">

	<xsl:import href="view_common.xsl"/>
	<xsl:import href="container_common.xsl"/>
	<xsl:import href="simpledb_common.xsl"/>
	
	<xsl:param name="simpledb">true</xsl:param>
	
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
								<div id="docbody">
							<xsl:call-template name="simpledb.options"/>
							<xsl:if test="/document/member_properties/member_property[1]">
								<div id="simpledb_resulttitle">
									<div>
										<xsl:if test="$searchstring != ''">
											<strong>Search for</strong>:
                      <xsl:if test="$searchstring != ''">
												<span class="simpledb_filter">'<xsl:value-of select="$searchstring"/>'</span>
											</xsl:if>.
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}">Reset search</a>
										</xsl:if>
									</div>
									<div>
										<xsl:call-template name="items_page_info"/>
									</div>
								</div>
								<xsl:call-template name="simpledb.itemsearch"/>
								<xsl:call-template name="pagenav">
									<xsl:with-param name="totalitems" select="$objectitems_count"/>
									<xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
									<xsl:with-param name="currentpage" select="$page"/>
									<xsl:with-param name="url" select="concat($xims_box,
                                             $goxims_content,
                                             $absolute_path,
                                             '?searchstring=',
                                             $searchstring)"/>
								</xsl:call-template>
								<xsl:call-template name="childrenlist"/>
								<xsl:call-template name="pagenav">
									<xsl:with-param name="totalitems" select="$objectitems_count"/>
									<xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
									<xsl:with-param name="currentpage" select="$page"/>
									<xsl:with-param name="url" select="concat($xims_box,
                                             $goxims_content,
                                             $absolute_path,
                                             '?searchstring=',
                                             $searchstring)"/>
								</xsl:call-template>
							</xsl:if>
						</div>
	</xsl:template>
  
	<xsl:template name="childrenlist">
		<div id="simpledb_childrenlist">
			<xsl:apply-templates select="children/object" mode="divlist">
				<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                                         ,'abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>
	
	<xsl:template match="children/object" mode="divlist">
		<xsl:variable name="abstract" select="normalize-space(abstract)"/>
		<div class="simpledb_childrenlistitem" id="simpledbchildrenlistitem{position()}">
			<div class="simpledb_membertitle">
				<xsl:call-template name="simpledbmembertitle"/>
				<xsl:text>&#xa0;</xsl:text>
        (id: <xsl:value-of select="@document_id"/>)
      </div>
			<xsl:call-template name="last_modified"/>
			<span class="simpledbitem_status_options">
				<xsl:call-template name="status"/>
				<span class="simpledbitem_options">
					<xsl:call-template name="cttobject.options"/>
				</span>
			</span>
			<xsl:if test="$abstract != ''">
				<div class="simpledbabstract">
					<xsl:value-of select="$abstract"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="last_modified">
		<span class="simpledb_lastmodified">
			<strong>
				<xsl:value-of select="$i18n/l/Last_modified"/>:
      </strong>
			<xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
		</span>
	</xsl:template>
	<xsl:template name="status">
		<span class="simpledb_status">
			<xsl:call-template name="cttobject.status"/>
		</span>
	</xsl:template>
	<xsl:template name="simpledbmembertitle">
		<!--<span class="simpledb_membertitle">-->
		<strong>
			<a title="{location}" href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
				<xsl:apply-templates select="member_values/member_value[
                                       property_id=/document/member_properties/member_property[part_of_title=1]/@id
                                     ]" mode="title">
					<xsl:sort select="/document/member_properties/member_property[
                               @id=current()/property_id
                            ]/position" order="ascending"/>
				</xsl:apply-templates>
			</a>
		</strong>
		<!--</span>-->
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
			<div>
				<label for="searchstring">
					<xsl:value-of select="$i18n/l/Search_for"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n_simpledb/l/Items"/>
				</label>
				<xsl:text>&#160;(</xsl:text>
				<xsl:value-of select="$i18n_simpledb/l/Looking_in"/>
				<xsl:apply-templates select="/document/member_properties/member_property[mandatory=1]" mode="namelist"/>)
              <br/>
				<xsl:value-of select="$i18n_simpledb/l/or_by_field_value"/>&#160;:
            </div>
			<div>
				<form action="{$xims_box}{$goxims_content}{$absolute_path}">
					<input type="text" name="searchstring" id="searchstring" size="17" maxlength="200">
						<xsl:if test="$searchstring != ''">
							<xsl:attribute name="value">
								<xsl:value-of select="$searchstring"/>
							</xsl:attribute>
						</xsl:if>
					</input>
					<xsl:text>&#160;</xsl:text>
					<input type="image" src="{$skimages}go.png" name="submit" alt="{$i18n/l/Search}" title="{$i18n/l/search}"/>
				</form>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name="simpledb.options">
		<div id="simpledb_options">
			<div>
				<xsl:if test="/document/context/object/user_privileges/create 
                          and /document/member_properties/member_property[1]">
					<div class="simpledb_itemcreate">
						<xsl:value-of select="$i18n_simpledb/l/New_Item"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:call-template name="member.createwidget"/>
					</div>
				</xsl:if>
				<xsl:if test="/document/context/object/user_privileges/write 
                          and not(/document/member_properties/member_property[1])">
					<div class="simpledb_map_item_properties">
						<xsl:call-template name="map_item_properties"/>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="$objectitems_count > 0">
				<div class="simpledb_access_xmlimport">
					<a target="_new">
						<xsl:attribute name="href">
							<xsl:choose>
								<xsl:when test="$searchstring != ''">
									<xsl:value-of select="concat('?searchstring=',$searchstring,';')"/>
								</xsl:when>
								<xsl:otherwise>?</xsl:otherwise>
							</xsl:choose>
							<xsl:text>style=access_xmlimport</xsl:text>
						</xsl:attribute>
						<xsl:value-of select="$i18n_simpledb/l/Download_access_xmlimport"/>
					</a>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="member.createwidget">
		<form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0; display: inline" method="get" id="member_creator" name="member_creator">
			<input type="image" name="create" src="{$sklangimages}create.png" alt="{$i18n/l/Create}" title="{$i18n/l/Create}"/>
			<input name="page" type="hidden" value="{$page}"/>
			<input name="r" type="hidden" value="{/document/context/object/@id}"/>
			<input name="objtype" type="hidden" value="SimpleDBItem"/>
			<xsl:if test="$defsorting != 1">
				<input name="sb" type="hidden" value="{$sb}"/>
				<input name="order" type="hidden" value="{$order}"/>
			</xsl:if>
		</form>
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
