<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>
<xsl:import href="view_common.xsl"/>
		
<xsl:param name="reflib" select="true()"/>
<!--<xsl:param name="reflib">true</xsl:param>-->
<!--<xsl:variable name="reflib" select="true()"/>-->

<xsl:variable name="createwidget">false</xsl:variable>
<!--<xsl:variable name="parent_id">false</xsl:variable>-->
<xsl:variable name="i18n_reflib" select="document(concat($currentuilanguage,'/i18n_reflibrary.xml'))"/>

<xsl:template name="view-content">
	<!--<form action="{$xims_box}{$goxims_content}" name="reftypechangeform" method="get" style="display:block">
		<input type="hidden" name="id" value="{@id}"/>
		<input type="hidden" name="change_reference_type" value="1"/>
		<input type="hidden" name="reference_type_id" value=""/>
		<xsl:call-template name="rbacknav"/>
		
		<xsl:call-template name="reftypes_list"/>
	</form>-->
	<div style="display:inline-block;float:left;padding-top:15px">
		<strong>Referenztyp</strong> : <xsl:value-of select="/document/reference_types/reference_type[@id=/document/context/object/reference_type_id]/name"/>
		&#160;&#160;
	</div>
	<xsl:call-template name="reftypes_list"/>

	<br class="clear"/>
	<p>
		<strong><xsl:value-of select="$i18n_vlib/l/authors"/></strong>:<br/>
		<xsl:apply-templates select="authorgroup/author">
			<xsl:sort select="position" order="ascending" data-type="number"/>
		</xsl:apply-templates>
	</p>
	<xsl:if test="editorgroup/author">
		<p>
			<strong><xsl:value-of select="$i18n_vlib/l/editors"/></strong>:<br/>
			<xsl:apply-templates select="editorgroup/author">
				<xsl:sort select="position" order="ascending" data-type="number"/>
			</xsl:apply-templates>
		</p>
	</xsl:if>
	<xsl:if test="serial != ''">
		<p>
			<strong>Journal</strong>:<br/>
			<xsl:apply-templates select="serial"/>
		</p>
	</xsl:if>
	<xsl:if test="abstract != ''">
		<p>
			<strong><xsl:value-of select="$i18n/l/Abstract"/></strong>: <xsl:apply-templates select="abstract"/>
		</p>
	</xsl:if>
	<xsl:if test="notes != ''">
		<p>
			<strong><xsl:value-of select="$i18n/l/Notes"/></strong>: <xsl:apply-templates select="notes"/>
		</p>
	</xsl:if>

	<xsl:apply-templates select="reference_values/reference_value">
		<xsl:sort select="/document/reference_properties/reference_property[@id=current()/property_id]/position" order="ascending" data-type="number"/>
	</xsl:apply-templates>

<script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
</xsl:template>

<xsl:template match="reference_value">
	<xsl:variable name="property_id" select="property_id"/>
	<xsl:if test="/document/reference_properties/reference_property[@id=current()/property_id]">
		<p>
			<xsl:call-template name="get-prop-name"><xsl:with-param name="id" select="$property_id"/></xsl:call-template>:&#160;
			<!--<xsl:value-of select="/document/reference_properties/reference_property[@id=$property_id]/name"/>:-->
			<xsl:value-of select="value"/>
		</p>
	</xsl:if>
</xsl:template>

<xsl:template name="reftypes_list">
	<div id="create-widget">
		<button>				
			<xsl:value-of select="$i18n_reflib/l/ChangeRefType"/>
		</button>
		<ul style="position:absolute !important; overflow-y:hidden;">
			<xsl:apply-templates select="/document/reference_types/reference_type" mode="getoptions"/>
		</ul>	
	</div>
</xsl:template>
	
<xsl:template match="reference_type" mode="getoptions">
	<!--<li><a href="javascript:submitReferenceTypeUpdate(this.value);"><xsl:value-of select="name"/></a></li>-->
	<li><a href="{$xims_box}{$goxims_content}?change_reference_type=1;id={/document/context/object/@id};reference_type_id={@id}"><xsl:value-of select="name"/></a></li>
</xsl:template>

<xsl:template match="/document/reference_types/reference_type">
	<option value="{@id}">
		<xsl:if test="@id = /document/context/object/reference_type_id">
			<xsl:attribute name="selected">selected</xsl:attribute>
		</xsl:if>
		<xsl:value-of select="name"/>
	</option>
</xsl:template>

<xsl:template name="button.options.copy"/>
<xsl:template name="button.options.move"/>
<xsl:template name="button.options.delete">
	<xsl:call-template name="button.options.purge"/>
</xsl:template>
<xsl:template name="button.options.send_email"/>
</xsl:stylesheet>
