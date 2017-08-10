<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: simpledb_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:str="http://exslt.org/strings" xmlns:math="http://exslt.org/math" extension-element-prefixes="str math">

	<xsl:import href="edit_common.xsl"/>
	<xsl:import href="simpledb_common.xsl"/>
	<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
	<xsl:param name="property_id"/>
	<xsl:param name="message" select="/document/context/session/message"/>
	
	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<div class="form-div block">
		<xsl:call-template name="form-stylesheet"/>
		<xsl:call-template name="form-pagerowlimit-edit"/>
				</div>

		<div  class="form-div block">
			<xsl:if test="$message != ''">
				<div>
					<span class="message">
						<xsl:value-of select="$message"/>
					</span>
				</div>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$property_id != ''">
					<div>
						<h2><xsl:value-of select="$i18n_simpledb/l/Edit_property"/>&#160;'<xsl:value-of select="/document/member_properties/member_property[@id=$property_id]/name"/>'</h2>
					</div>
						<xsl:call-template name="tr-property_properties"/>
					<div>
						<input type="hidden" name="property_id" value="{$property_id}"/>
						<button type="submit" name="update_property_mapping" class="button"><xsl:value-of select="$i18n_simpledb/l/Save_changes"/></button>&#160;
						<button type="button" name="discard" onclick="window.location.href='{$xims_box}{$goxims_content}{$absolute_path}?edit=1'; return true;" class="button"><xsl:value-of select="$i18n_simpledb/l/Stop_editing"/></button>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div>
						<h2><xsl:value-of select="$i18n_simpledb/l/Create_property"/>:</h2>
					</div>
					<xsl:call-template name="tr-property_properties"/>
					<div>
						<button type="submit" name="create_property_mapping" class="button" accesskey="c"><xsl:value-of select="$i18n_simpledb/l/Create_property"/></button>
					</div>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="tr-current_propertymappings"/>
		</div>
	</xsl:template>
	
	<xsl:template name="tr-property_properties">
		<xsl:variable name="maxposition">
			<xsl:choose>
				<xsl:when test="/document/member_properties/member_property[1]">
					<xsl:value-of select="math:max(/document/member_properties/member_property/position)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<div>
			<div class="label-sdbp">
				<label for="sdbp_name">
					<xsl:value-of select="$i18n_simpledb/l/Name"/>
				</label>
			</div>
			<input id="sdbp_name" type="text" name="sdbp_name" value="{/document/member_properties/member_property[@id=$property_id]/name}" size="40" class="text"/>
		</div>
		
		<div>
			<div class="label-sdbp">
				<label for="sdbp_type">
					<xsl:value-of select="$i18n_simpledb/l/Type"/>
				</label>
			</div>
			<xsl:choose>
				<xsl:when test="/document/member_properties/member_property[@id=$property_id]/type">
					<input type="text" name="sdbp_type" id="sdbp_type" value="{/document/member_properties/member_property[@id=$property_id]/type}" size="40" readonly="readonly" class="readonlytext"/>
				</xsl:when>
				<xsl:otherwise>
					<select id="sdbp_type" name="sdbp_type" onchange="checkPropertyType(this)">
						<option value="string">String</option>
						<option value="stringoptions">String options</option>
						<option value="textarea">Textarea</option>
						<option value="boolean">Boolean</option>
						<option value="integer">Integer</option>
						<option value="datetime">Datetime</option>
						<option value="float">Float</option>
					</select>
				</xsl:otherwise>
			</xsl:choose>
		</div>		
				
			<div id="tr-regex">
			<xsl:if test="$property_id != '' and /document/member_properties/member_property[@id=$property_id]/type = 'stringoptions'">
			<xsl:attribute name="style">display:none</xsl:attribute></xsl:if>
				<div class="label-sdbp">
					<label for="sdbp_regex">
						<xsl:value-of select="$i18n_simpledb/l/Regex"/>
					</label>
				</div>
				<input id="sdbp_regex" type="text" name="sdbp_regex" value="{/document/member_properties/member_property[@id=$property_id]/regex}" size="40" class="text"/>
			</div>

			<div id="tr-stringoptions">
			<xsl:if test="$property_id = '' or /document/member_properties/member_property[@id=$property_id]/type != 'stringoptions'">
			<xsl:attribute name="style">display:none</xsl:attribute></xsl:if>
				<div class="label-sdbp">
					<label for="sdbp_regex_select">
						<xsl:value-of select="$i18n_simpledb/l/String_options"/>
					</label>
				</div>
				<select id="sdbp_regex_select" name="sdbp_regex_select"><xsl:comment/>
					<xsl:for-each select="str:split(substring-before(substring-after(/document/member_properties/member_property[@id=$property_id]/regex,'^('),')$'), '|')">
						<option value="{.}">
							<xsl:value-of select="translate(.,'\','')"/>
						</option>
					</xsl:for-each>
				</select>
				<xsl:text> </xsl:text>
				<a href="javascript:addSelection($('#sdbp_regex_add'),$('#sdbp_regex_select'));" class="button" title="{$i18n_simpledb/l/Add_to_selection}"><!--onclick="addSelection(sdbp_regex_add,sdbp_regex_select);">-->
				<span class="ui-icon ui-icon-circle-arrow-w"><xsl:comment/></span>
				</a>
				
				<xsl:text> </xsl:text>
				<input id="sdbp_regex_add" type="text" name="sdbp_regex_add" class="text" size="40" />
				<xsl:text> </xsl:text>
				<button type="button" onclick="removeSelection(sdbp_regex_select);" class="button"><xsl:value-of select="$i18n_simpledb/l/Remove_selected"/></button>
		</div>
		
		<div>
			<div class="label-sdbp">
				<label for="sdbp_description">
					<xsl:value-of select="$i18n_simpledb/l/Description"/>
				</label>
			</div>
			<textarea id="sdbp_description" rows="3" cols="38" name="sdbp_description" class="text">
				<xsl:apply-templates select="/document/member_properties/member_property[@id=$property_id]/description"/>
		        <xsl:comment/>
	        </textarea>
		</div>
		<div>
			<div class="label-sdbp">
				<label for="sdbp_part_of_title">
					<xsl:value-of select="$i18n_simpledb/l/Part_of_title"/>
				</label>
			</div>
			<input id="sdbp_part_of_title" type="checkbox" name="sdbp_part_of_title" value="1" class="checkbox">
				<xsl:if test="/document/member_properties/member_property[@id=$property_id]/part_of_title = '1'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
		</div>
		
		<div>
			<div class="label-sdbp">
				<label for="sdbp_mandatory">
					<xsl:value-of select="$i18n_simpledb/l/Mandatory"/>
				</label>
			</div>
			<input id="sdbp_mandatory" type="checkbox" name="sdbp_mandatory" value="1" class="checkbox">
				<xsl:if test="/document/member_properties/member_property[@id=$property_id]/mandatory = '1'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
		</div>
		
		<div>
			<div class="label-sdbp">
				<label for="sdbp_gopublic">
					<xsl:value-of select="$i18n_simpledb/l/gopublic"/>
				</label>
			</div>
			<input id="sdbp_gopublic" type="checkbox" name="sdbp_gopublic" value="1" class="checkbox">
				<xsl:if test="$property_id = '' or /document/member_properties/member_property[@id=$property_id]/gopublic = '1'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
		</div>
		
		<div>
			<div class="label-sdbp">
				<label for="sdbp_position">
					<xsl:value-of select="$i18n_simpledb/l/Position"/>
				</label>
			</div>
			<xsl:choose>
				<xsl:when test="$property_id = ''">
					<input id="sdbp_position" type="text" size="4" name="sdbp_position" readonly="readonly" class="readonlytext" value="{$maxposition+1}"/>
				</xsl:when>
				<xsl:otherwise>
					<select id="sdbp_position" name="sdbp_position" class="text">
						<xsl:for-each select="/document/member_properties/member_property/position">
							<option>
								<xsl:if test=". = /document/member_properties/member_property[@id=$property_id]/position">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</option>
						</xsl:for-each>
					</select>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		
	</xsl:template>
	
	<xsl:template name="tr-current_propertymappings">
		<xsl:if test="/document/member_properties/member_property[1]">
			<div>
				<strong>
					<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>:</strong>
			</div>
			<div>
				<!--<ul style="margin-top: 0px">-->
				<table class="obj-table">
					<tbody>
						<tr>
							<th id="th-pos"><xsl:value-of select="$i18n/l/Position"/></th>
							<th><xsl:value-of select="$i18n/l/Name"/></th>
							<th><xsl:value-of select="$i18n/l/Options"/></th>
						</tr>
					<xsl:apply-templates select="/document/member_properties/member_property" mode="entry">
						<xsl:sort select="position" order="ascending" data-type="number"/>
						<xsl:sort select="name" order="ascending"/>
					</xsl:apply-templates>
					</tbody>
				</table>
				<!--</ul>-->
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="member_property" mode="entry">
		<tr class="objrow">
			<td>
			<xsl:value-of select="position"/>
			<xsl:text> </xsl:text>
			</td>
			<td>
			<xsl:choose>
				<xsl:when test="part_of_title=1">
					<strong>
							<xsl:value-of select="name"/>
					</strong>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="mandatory = 1">&#160;*</xsl:if>
			&#160;&#160;
			</td>
			<td>
			<a class="option-edit ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" href="{$xims_box}{$goxims_content}{$absolute_path}?edit=1&amp;property_id={@id}" role="button" aria-disabled="false" >
        <xsl:attribute name="title"><xsl:value-of select="$l_Edit"/></xsl:attribute>
        <span class="ui-button-icon-primary ui-icon sprite-option_edit xims-sprite"><xsl:comment/></span>
        <span class="ui-button-text"><xsl:value-of select="$l_Edit"/></span>
      </a>
			<xsl:if test="/document/context/object/user_privileges/delete">
				<xsl:text> </xsl:text>
				<a class="option-delete ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" role="button" aria-disabled="false" onclick="javascript:rv=confirm('{$i18n_simpledb/l/Sure_to_delete}'); if ( rv == true ) location.href='{$xims_box}{$goxims_content}{$absolute_path}?property_id={@id}&amp;delete_property_mapping=1'; return false;">
          <xsl:attribute name="title"><xsl:value-of select="$l_delete"/></xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="concat($xims_box,$goxims_content, $absolute_path, '?property_id=', @id, '&amp;delete_property_mapping=1')"></xsl:value-of>
          </xsl:attribute>
          <span class="ui-button-icon-primary ui-icon sprite-option_delete xims-sprite"><xsl:comment/></span>
          <span class="ui-button-text"><xsl:value-of select="$l_delete"/></span>
        </a>
			</xsl:if>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="form-stylesheet">
		<xsl:variable name="parentid" select="parents/object[/document/context/object/@parent_id=@document_id]/@id"/>
		<div id="tr-stylesheet">
			<div class="label-std">
				<label for="input-stylesheet">
					<xsl:value-of select="$i18n/l/Stylesheet"/>
				</label>
			</div>
			<input type="text" name="stylesheet" size="60" value="{style_id}" class="text" id="input-stylesheet"/>
			<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Stylesheet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Stylesheet"/></xsl:attribute>(?)</a>-->
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$parentid}&amp;contentbrowse=1&amp;to={$parentid}&amp;otfilter=XSLStylesheet,Folder&amp;sbfield=eform.stylesheet','default-dialog','{$i18n/l/Browse_stylesheet}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_stylesheet"/>
			</a>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
