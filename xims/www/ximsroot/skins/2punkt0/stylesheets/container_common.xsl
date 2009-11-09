<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: container_common.xsl 2216 2009-06-17 12:16:25Z haensel $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:param name="onepage" select="0"/>
	<xsl:param name="pagerowlimit" select="$searchresultrowlimit"/>
	<xsl:variable name="pagesperpagenav" select="10"/>
	<xsl:variable name="totalpages">
		<xsl:choose>
			<xsl:when test="$onepage &gt; 0">
				<xsl:number value="1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:number value="ceiling(/document/context/object/children/@totalobjects div $pagerowlimit)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- save those strings in variables as they are called per object in object/children -->
	<xsl:variable name="l_location" select="$i18n/l/location"/>
	<xsl:variable name="l_created_by" select="$i18n/l/created_by"/>
	<xsl:variable name="l_owned_by" select="$i18n/l/owned_by"/>
	<xsl:variable name="l_position_object" select="$i18n/l/position_object"/>
	<xsl:variable name="l_last_modified_by" select="$i18n/l/last_modified_by"/>
	<xsl:template name="autoindex">
		<div id="tr-autoindex">
			<div id="label-autoindex">
				<label for="cb-autoindex">
					<xsl:value-of select="$i18n/l/Omit_autoindex"/>
				</label>
			</div>
			<input name="autoindex" type="checkbox" value="false" class="checkbox" id="cb-autoindex">
				<xsl:if test="attributes/autoindex = '0'">
					<xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
				</xsl:if>
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('autoindex')" class="doclink">(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="defaultsorting">
		<div id="tr-defaultsorting">
			<fieldset>
				<legend>
					<div id="label-defaultsorting">
						<label for="select-defaultsorting">
							<xsl:value-of select="$i18n/l/Sort_children_default"/>
						</label>
					</div>
				</legend>
				<select name="defaultsortby" id="select-defaultsorting" class="select">
					<option value="position">
						<xsl:value-of select="$i18n/l/Position"/>
					</option>
					<option value="title">
						<xsl:if test="attributes/defaultsortby = 'title'">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$i18n/l/Title"/>
					</option>
					<option value="date">
						<xsl:if test="attributes/defaultsortby = 'date'">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$i18n/l/Last_Modification_Date"/>
					</option>
				</select>
				<input name="defaultsort" type="radio" value="asc" id="radio-defaultsorting-asc" class="radio-button">
					<xsl:if test="not(attributes/defaultsort) or attributes/defaultsort != 'desc'">
						<xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
					</xsl:if>
				</input>
				<label for="radio-defaultsorting-asc">
					<xsl:value-of select="$i18n/l/ascending"/>
				</label>
				<input name="defaultsort" type="radio" value="desc" id="radio-defaultsorting-desc" class="radio-button">
					<xsl:if test="attributes/defaultsort = 'desc'">
						<xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
					</xsl:if>
				</input>
				<label for="radio-defaultsorting-desc">
					<xsl:value-of select="$i18n/l/descending"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('defaultsorting')" class="doclink">(?)</a>
			</fieldset>
		</div>
	</xsl:template>
	<xsl:template name="pagenav">
		<xsl:param name="totalitems"/>
		<xsl:param name="itemsperpage"/>
		<xsl:param name="currentpage"/>
		<xsl:param name="url"/>
		<xsl:if test="$totalpages &gt; 1">
			<div id="pagenav">
				<div>
					<xsl:if test="$currentpage &gt; 1">
						<a href="{$url};page={number($currentpage)-1}">&lt; <xsl:value-of select="$i18n/l/Previous_page"/>
						</a>
					</xsl:if>
					<xsl:if test="$currentpage &gt; 1 and $currentpage &lt; $totalpages">
                |
              </xsl:if>
					<xsl:if test="$currentpage &lt; $totalpages">
						<a href="{$url};page={number($currentpage)+1}">&gt; <xsl:value-of select="$i18n/l/Next_page"/>
						</a>
					</xsl:if>
				</div>
				<div>
					<xsl:call-template name="pageslinks">
						<xsl:with-param name="page" select="1"/>
						<xsl:with-param name="current" select="$currentpage"/>
						<xsl:with-param name="total" select="$totalpages"/>
						<xsl:with-param name="url" select="$url"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template name="pageslinks">
		<xsl:param name="page"/>
		<xsl:param name="current"/>
		<xsl:param name="total"/>
		<xsl:param name="url"/>
		<xsl:variable name="first_in_list">
			<xsl:choose>
				<xsl:when test="1 &gt; ( $current - $pagesperpagenav div 2 )">
					<xsl:number value="1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number value="$current - $pagesperpagenav div 2"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="last_in_list">
			<xsl:choose>
				<xsl:when test="($first_in_list + $pagesperpagenav ) &gt; $total">
					<xsl:number value="$total"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number value="$first_in_list + $pagesperpagenav "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$page = $first_in_list - 1">
			<a href="{$url};page=1">1</a> ...
  </xsl:if>
		<xsl:if test="$page &gt;= $first_in_list">
			<xsl:choose>
				<xsl:when test="$page = $current">
					<strong>
						<a href="{$url};page={$page}">
							<xsl:value-of select="$page"/>
						</a>
					</strong>
				</xsl:when>
				<xsl:when test="$page &lt;= $last_in_list">
					<a href="{$url};page={$page}">
						<xsl:value-of select="$page"/>
					</a>
				</xsl:when>
			</xsl:choose>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:if test="$page &lt;= $last_in_list">
			<xsl:call-template name="pageslinks">
				<xsl:with-param name="page" select="$page + 1"/>
				<xsl:with-param name="current" select="$current"/>
				<xsl:with-param name="total" select="$total"/>
				<xsl:with-param name="url" select="$url"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$page = $last_in_list + 1 and $last_in_list &lt; $total">
    ... <a href="{$url};page={$total}">
				<xsl:value-of select="$total"/>
			</a>
		</xsl:if>
	</xsl:template>
	<xsl:template name="pagenavtable">
		<xsl:variable name="navurl">
			<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?m=',$m)"/>
			<xsl:if test="$defsorting != 1">
				<xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/>
			</xsl:if>
			<xsl:if test="$pagerowlimit != $searchresultrowlimit">
				<xsl:value-of select="concat(';pagerowlimit=',$pagerowlimit)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$totalpages &gt; 1">
			<xsl:call-template name="pagenav">
				<xsl:with-param name="totalitems" select="/document/context/object/children/@totalobjects"/>
				<xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
				<xsl:with-param name="currentpage" select="$page"/>
				<xsl:with-param name="url" select="$navurl"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="childrentable">
		<xsl:variable name="location" select="concat($goxims_content,$absolute_path)"/>
		<table id="obj-table">
			<thead>
				<tr>
					<xsl:if test="$m='e'">
						<th id="th-status">
							<a class="th-icon-right">
								<xsl:value-of select="$i18n/l/Status"/>
							</a>
						</th>
						<xsl:choose>
							<xsl:when test="$sb='position'">
								<xsl:choose>
									<xsl:when test="$order='asc'">
										<th id="th-pos" class="sorting">
											<a href="{$location}?sb=position;order=desc;" class="th-icon-right">
												<span class="ui-icon ui-icon-triangle-1-n"/>
												<xsl:value-of select="$i18n/l/Pos_short"/>&#160;						
										</a>
										</th>
									</xsl:when>
									<xsl:otherwise>
										<th id="th-pos" class="sorting">
											<a href="{$location}?sb=position;order=asc;" class="th-icon-right">
												<span class="ui-icon ui-icon-triangle-1-s"/>
												<xsl:value-of select="$i18n/l/Pos_short"/>&#160;						
										</a>
										</th>
										<!--</xsl:apply-templates>-->
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<th id="th-pos" class="sorting">
									<a href="{$location}?sb=position;order=asc;" class="th-icon-right">
										<span class="ui-icon ui-icon-triangle-2-n-s"/>
										<xsl:value-of select="$i18n/l/Pos_short"/>&#160;						
								</a>
								</th>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<th id="th-titel-icon">
						&#160;
					</th>
					<xsl:choose>
						<xsl:when test="$sb='title'">
							<xsl:choose>
								<xsl:when test="$order='asc'">
									<th id="th-title" class="sorting">
										<a href="{$location}?sb=title;order=desc;m={$m}" class="th-icon-right">
											<span class="ui-icon ui-icon-triangle-1-n"/>
											<xsl:value-of select="$i18n/l/Title"/>&#160;						
										</a>
									</th>
								</xsl:when>
								<xsl:otherwise>
									<th id="th-title" class="sorting">
										<a href="{$location}?sb=title;order=asc;m={$m}" class="th-icon-right">
											<span class="ui-icon ui-icon-triangle-1-s"/>
											<xsl:value-of select="$i18n/l/Title"/>&#160;						
										</a>
									</th>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<th id="th-title" class="sorting">
								<a href="{$location}?sb=title;order=asc;m={$m}" class="th-icon-right">
									<span class="ui-icon ui-icon-triangle-2-n-s"/>
									<xsl:value-of select="$i18n/l/Title"/>&#160;						
								</a>
							</th>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$sb='date'">
							<xsl:choose>
								<xsl:when test="$order='asc'">
									<th id="th-lastmod" class="sorting">
										<a href="{$location}?sb=date;order=desc;m={$m}" class="th-icon-right">
											<span class="ui-icon ui-icon-triangle-1-n"/>
											<xsl:value-of select="$i18n/l/Last_modified"/>&#160;						
										</a>
									</th>
								</xsl:when>
								<xsl:otherwise>
									<th id="th-lastmod" class="sorting">
										<a href="{$location}?sb=date;order=asc;m={$m}" class="th-icon-right">
											<span class="ui-icon ui-icon-triangle-1-s"/>
											<xsl:value-of select="$i18n/l/Last_modified"/>&#160;						
										</a>
									</th>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<th id="th-lastmod" class="sorting">
								<a href="{$location}?sb=date;order=desc;m={$m}" class="th-icon-right">
									<span class="ui-icon ui-icon-triangle-2-n-s"/>
									<xsl:value-of select="$i18n/l/Last_modified"/>&#160;						
								</a>
							</th>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="th-size"/>
					<xsl:if test="$m='e'">
						<xsl:call-template name="th-options"/>
					</xsl:if>
				</tr>
			</thead>
			<tbody>
				<xsl:choose>
					<xsl:when test="$sb='title'">
						<xsl:choose>
							<xsl:when test="$order='asc'">
								<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<!-- as long as lower-first is not implemented, we probably have to use lowercase the title here -->
									<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="$order='desc'">
								<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<!-- as long as lower-first is not implemented, we probably have to use lowercase the title here -->
									<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="descending"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$sb='position'">
						<xsl:choose>
							<xsl:when test="$order='asc'">
								<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<xsl:sort select="position" order="ascending" data-type="number"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="$order='desc'">
								<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<xsl:sort select="position" order="descending" data-type="number"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$sb='date'">
						<xsl:choose>
							<xsl:when test="$order='asc'">
								<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<xsl:sort select="concat(last_modification_timestamp/year
                                                    ,last_modification_timestamp/month
                                                    ,last_modification_timestamp/day
                                                    ,last_modification_timestamp/hour
                                                    ,last_modification_timestamp/minute
                                                    ,last_modification_timestamp/second)" order="ascending"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="$order='desc'">
								<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<xsl:sort select="concat(last_modification_timestamp/year
                                                    ,last_modification_timestamp/month
                                                    ,last_modification_timestamp/day
                                                    ,last_modification_timestamp/hour
                                                    ,last_modification_timestamp/minute
                                                    ,last_modification_timestamp/second)" order="descending"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
				<!--</xsl:choose>-->
				<!--<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
					-->
				<!-- as long as lower-first is not implemented, we probably have to use lowercase the title here -->
				<!--
					<xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				</xsl:apply-templates>-->
				<!--<xsl:apply-templates select="children/object[user_privileges/view and ( marked_deleted &gt; $hd 
                                                                                             or marked_deleted = 0 )]">
									<xsl:sort select="position" order="ascending" data-type="number"/>
									</xsl:apply-templates>-->
			</tbody>
		</table>
	</xsl:template>
	<xsl:template name="th-size">
		<th id="th-size">
			<xsl:value-of select="$i18n/l/Size"/>&#160;(kB)&#160;
			<!--<img src="{$sklangimages}size.png" width="80" height="20" border="0" alt="{$i18n/l/Size}" title="{$i18n/l/Size} {$i18n/l/in} kB"/>-->
		</th>
	</xsl:template>
	<xsl:template name="th-options">
		<th id="th-options">
			<xsl:value-of select="$i18n/l/Options"/>
			<!--<img src="{$sklangimages}options.png" width="221" height="20" alt="{$i18n/l/Options}" title="{$i18n/l/Options}"/>-->
		</th>
	</xsl:template>
	<xsl:template match="children/object">
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
		<xsl:variable name="dfname" select="$df/name"/>
		<xsl:variable name="dfmime" select="$df/mime_type"/>
		<tr class="objrow">
				<td class="ctt_status">
					<xsl:call-template name="cttobject.status"/>
				</td>
				<td class="ctt_position">
					<xsl:call-template name="cttobject.position"/>
				</td>
			<td class="ctt_df">
				<xsl:call-template name="cttobject.dataformat">
					<xsl:with-param name="dfname" select="$dfname"/>
				</xsl:call-template>
			</td>
			<td class="ctt_loctitle">
				<xsl:call-template name="cttobject.locationtitle">
					<xsl:with-param name="dfname" select="$dfname"/>
					<xsl:with-param name="dfmime" select="$dfmime"/>
				</xsl:call-template>
			</td>
			<td class="ctt_lm">
				<xsl:call-template name="cttobject.last_modified"/>
			</td>
			<td class="ctt_cl">
				<xsl:call-template name="cttobject.content_length">
					<xsl:with-param name="dfname" select="$dfname"/>
					<xsl:with-param name="dfmime" select="$dfmime"/>
				</xsl:call-template>
			</td>
				<td class="ctt_options">
					<xsl:call-template name="cttobject.options"/>
				</td>
		</tr>
	</xsl:template>
	<xsl:template name="cttobject.locationtitle">
		<xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>
		<xsl:param name="dfmime" select="/document/data_formats/data_format[@id=current()/data_format_id]/mime_type"/>
		<xsl:param name="link_to_id" select="false()"/>
		<xsl:choose>
			<xsl:when test="marked_deleted=1">
				<xsl:attribute name="class"><xsl:value-of select="'ctt_loctitledel'"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="starts-with(location, 'index.')">
				<xsl:attribute name="class"><xsl:value-of select="'ctt_loctitleindex'"/></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="class"><xsl:value-of select="'ctt_loctitle'"/></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<span>
			<xsl:attribute name="title">id: 
				<xsl:value-of select="@id"/>, 
				<xsl:value-of select="$l_location"/>: 
				<xsl:value-of select="location"/>, 
				<xsl:value-of select="$l_created_by"/>: 
				<xsl:call-template name="creatorfullname"/>, 
				<xsl:value-of select="$l_owned_by"/>: 
				<xsl:call-template name="ownerfullname"/></xsl:attribute>
			<a>
				<xsl:attribute name="href"><xsl:choose><xsl:when test="$dfmime='application/x-container' and not($link_to_id)"><xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?m=',$m)"/><xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:when><xsl:when test="$dfmime='application/x-container' and $link_to_id"><xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m)"/></xsl:when><xsl:when test="$dfname='URL'"><xsl:choose><xsl:when test="symname_to_doc_id != ''"><xsl:value-of select="concat($goxims_content, symname_to_doc_id, '?m=',$m)"/><xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:when><xsl:when test="starts-with(location,'/')"><!--  Treat links relative to '/' as relative to the current SiteRoot --><xsl:value-of select="concat($goxims_content, '/', /document/context/object/parents/object[@parent_id=1]/location, location)"/></xsl:when><xsl:otherwise><xsl:value-of select="location"/></xsl:otherwise></xsl:choose></xsl:when><xsl:when test="marked_deleted=1 or $link_to_id"><xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?m=',$m)"/></xsl:otherwise></xsl:choose></xsl:attribute>
				<xsl:value-of select="title"/>
			</a>
		</span>
	</xsl:template>
	<xsl:template name="cttobject.position">
		<xsl:variable name="position">
			<xsl:value-of select="position"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$m='e' and /document/context/object/user_privileges/write=1">
				<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};posview=yes;sbfield=reposition{@id}.new_position')" title="{$l_position_object}">
					<xsl:value-of select="$position"/>
				</a>
				<!-- the form is needed, so we can write the new position back without reloading this site from the positioning window -->
				<form name="reposition{@id}" method="get" action="{$xims_box}{$goxims_content}">
					<input type="hidden" name="m" value="{$m}"/>
					<input type="hidden" name="id" value="{@id}"/>
					<input type="hidden" name="reposition" value="yes"/>
					<input type="hidden" name="new_position" value="{$position}"/>
				</form>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$position"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="cttobject.last_modified">
		<!--<img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt=""/>-->
		<span>
			<xsl:attribute name="title"><xsl:value-of select="$l_last_modified_by"/>: <xsl:call-template name="modifierfullname"/></xsl:attribute>
			<xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
		</span>
	</xsl:template>
	<xsl:template name="cttobject.content_length">
		<xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>
		<xsl:param name="dfmime" select="/document/data_formats/data_format[@id=current()/data_format_id]/mime_type"/>
		<!-- find a better way to do this (OT property "hasloblength" for example) -->
		<xsl:if test="$dfmime !='application/x-container'
            and $dfname!='URL'
            and $dfname!='SymbolicLink' ">
			<xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
			<!--<img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt=""/>-->
		</xsl:if>
	</xsl:template>
	<xsl:template name="tr-pagerowlimit-edit">
		<div id="tr-pagerowlimit">
			<div id="label-pagerowlimit">
				<label for="input-pagerowlimit">
					<xsl:value-of select="$i18n/l/PageRowLimit"/>
				</label>
			</div>
			<input type="text" name="pagerowlimit" size="2" maxlength="2" value="{attributes/pagerowlimit}" class="text input" id="input-pagerowlimit"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('PageRowLimit')" class="doclink">(?)</a>
		</div>
	</xsl:template>
</xsl:stylesheet>
