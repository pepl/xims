<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common.xsl"/>
<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:param name="reflib">true</xsl:param>
<xsl:variable name="i18n_reflib" select="document(concat($currentuilanguage,'/i18n_reflibrary.xml'))"/>

<xsl:template name="edit-content">
	<xsl:call-template name="reftypes_list"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'author'"/>
		<xsl:with-param name="mode" select="'rl'"/>
	</xsl:call-template>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'editor'"/>
		<xsl:with-param name="mode" select="'rl'"/>
	</xsl:call-template>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'serial'"/>
		<xsl:with-param name="mode" select="'rl'"/>
	</xsl:call-template>

		<xsl:apply-templates select="/document/reference_properties/reference_property">
			<xsl:sort select="position" order="ascending" data-type="number"/>
		</xsl:apply-templates>
	

	<!-- Add Fulltext (->XIMS::File object as child ?) -->
	<xsl:call-template name="form-abstractnotes"/>
	
	<form action="{$xims_box}{$goxims_content}" name="reftypechangeform" method="get" style="display:none">
		<input type="hidden" name="id" value="{@id}"/>
		<input type="hidden" name="change_reference_type" value="1"/>
		<input type="hidden" name="reference_type_id" value=""/>
		<xsl:call-template name="rbacknav"/>
	</form>

	<script type="text/javascript" language="javascript">
		var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,/document/context/object/location_path)"/>';
		var parentpath = '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path)"/>';
	</script>					
	<script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
	<script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>

</xsl:template>
    
<xsl:template name="reftypes_list">
    		<div id="create-widget">
			<button>				
				<xsl:value-of select="$i18n_reflib/l/ChangeRefType"/>
			</button>
			<ul style="position:absolute !important;">
				<xsl:apply-templates select="/document/reference_types/reference_type" mode="getoptions"/>
			</ul>	
    </div>
    </xsl:template>
    
    <xsl:template match="reference_type" mode="getoptions">
    <li><a href="javascript:return submitReferenceTypeUpdate(this.value);"><xsl:value-of select="name"/></a></li>
</xsl:template>

    <xsl:template match="/document/reference_types/reference_type">
        <option value="{@id}">
            <xsl:if test="@id = /document/context/object/reference_type_id">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="name"/>
        </option>
    </xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author">
    <xsl:variable name="current_pos" select="number(position)"/>
    <xsl:variable name="role">
        <xsl:choose>
            <xsl:when test="name(..) = 'authorgroup'">0</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date" select="/document/context/object/reference_values/reference_value[property_id=/document/reference_properties/reference_property[name='date']/@id]/value"/>
    <xsl:variable name="title" select="/document/context/object/reference_values/reference_value[property_id=/document/reference_properties/reference_property[name='title']/@id]/value"/>
    <xsl:if test="$current_pos!=1">
        <xsl:text> </xsl:text>
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?reposition_author=1;author_id={id};role={$role};old_position={$current_pos};new_position={$current_pos - 1};date={$date};title={$title}"
           title="{i18n/l/Reposition}"><!--&lt;--><span class="ui-icon ui-icon-triangle-1-w ui-icon-small"/></a>
        <xsl:text> </xsl:text>
    </xsl:if>
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="{$i18n/l/Opens_in_new_window}">
        <xsl:call-template name="authorfullname"/>
    </a>
    <xsl:text> </xsl:text>    
    <xsl:if test="position()!=last()">
        <xsl:text> </xsl:text>
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?reposition_author=1;author_id={id};role={$role};old_position={$current_pos};new_position={$current_pos + 1};date={$date};title={$title}"
           title="{i18n/l/Reposition}"><!--&gt;--><span class="ui-icon ui-icon-triangle-1-e ui-icon-small"/></a>
	</xsl:if>
	<a href="{$xims_box}{$goxims_content}{$absolute_path}?remove_author_mapping=1;property={name()};property_id={id};role={$role};date={$date};title={$title}">
       	<xsl:attribute name="title"><xsl:value-of select="$i18n_vlib/l/Delete_mapping"/>: <xsl:call-template name="authorfullname"/></xsl:attribute>
		<!--<span class="xdelete"> x </span></a>-->
		<span class="ui-button-icon-primary ui-icon sprite-option_delete xims-sprite"></span></a>
	<xsl:if test="position()!=last()"><xsl:text> | </xsl:text>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
