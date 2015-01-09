<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xml_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common.xsl"/>

<xsl:param name="selEditor" >code</xsl:param>
<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitle-edit_xml"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:if test="schema_id and attributes/sfe = '1'">
			<xsl:call-template name="sfe-edit"/>
	</xsl:if>
	<xsl:call-template name="form-body-edit">
		<xsl:with-param name="mode">xml</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="jsorigbody"/>
	<xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-stylesheet"/>
	<xsl:call-template name="tr-schema-edit"/>
	<xsl:call-template name="form-css"/>
	<xsl:if test="schema_id">
			<xsl:call-template name="sfe-attribute-edit"/>
	</xsl:if>
	
	
</xsl:template>

<xsl:template name="trytobalance"/>
<xsl:template name="form-minify"/>

<xsl:template name="tr-schema-edit">
<div id="tr-schema">
    <div class="label-std"><label for="input-schema">
			<xsl:value-of select="$i18n/l/Schema"/>
    </label></div>
        <input type="text" name="schema" size="60" value="{./schema_id}" class="text" id="input-schema"/>
        <!--<xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Schema')" class="doclink">(?)</a>-->
        <xsl:text>&#160;</xsl:text>
		<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id}&amp;contentbrowse=1&amp;to={./schema_id}&amp;otfilter=XML&amp;sbfield=eform.schema','default-dialog','{$i18n_xml/l/Browse_schema}')" class="button"><xsl:value-of select="$i18n_xml/l/Browse_schema"/></a>
    </div>
</xsl:template>

<xsl:template name="sfe-edit">
	<div class="form-div block">
		<a href="{$xims_box}{$goxims_content}?id={@id}&amp;simpleformedit=1" class="button"><xsl:value-of select="$i18n_xml/l/Edit_with_SFE"/></a>
	</div>
</xsl:template>

<xsl:template name="sfe-attribute-edit">
    <div id="tr-sfeedit-attr">
        <fieldset>
            <legend class="label-large"><xsl:value-of select="$i18n_xml/l/Link_to_edit_with_SFE"/></legend>
            <input name="sfe" type="radio" value="true" class="radio-button" id="input-sfeedit-true">
              <xsl:if test="attributes/sfe = '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input>
            <label for="input-sfeedit-true"><xsl:value-of select="$i18n/l/Yes"/></label>
            
            <input name="sfe" type="radio" value="false" class="radio-button" id="input-sfeedit-false">
              <xsl:if test="attributes/sfe!= '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input>
            <label for="input-sfeedit-false"><xsl:value-of select="$i18n/l/No"/></label>
            
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('sfe')" class="doclink">(?)</a>-->
            </fieldset>
        </div>
</xsl:template>

</xsl:stylesheet>
