<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xml_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common.xsl"/>

<xsl:param name="bxepresent" />
<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitle-edit_xml"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:if test="$bxepresent=1 and (./schema_id) and (./css_id) and (./attributes/bxeconfig_id) and (./attributes/bxexpath)">
			<xsl:call-template name="bxe-edit"/>
	</xsl:if>
	<xsl:if test="schema_id and attributes/sfe = '1'">
			<xsl:call-template name="sfe-edit"/>
	</xsl:if>
	<xsl:call-template name="form-body-edit">
		<xsl:with-param name="mode">xml</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-stylesheet"/>
	<xsl:call-template name="tr-schema-edit"/>
	<xsl:call-template name="form-css"/>
	<xsl:call-template name="tr-bxeconfig-edit"/>
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
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Schema')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./schema_id};otfilter=XML;sbfield=eform.schema')" class="button"><xsl:value-of select="$i18n_xml/l/Browse_schema"/></a>
    </div>
</xsl:template>

<xsl:template name="tr-bxeconfig-edit">
<div id="tr-bxeconfig">
    <div class="label-std"><label for="input-bxeconfig"><xsl:value-of select="$i18n_xml/l/BXEConfig"/></label></div>
        <input type="text" name="bxeconfig" size="60" value="{./attributes/bxeconfig_id}" class="text" id="input-bxeconfig"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./attributes/bxeconfig_id};otfilter=XML;sbfield=eform.bxeconfig')" class="button"><xsl:value-of select="$i18n_xml/l/Browse_BXEconfig"/></a>
    </div>
<div id="tr-bxexpath">
    <div class="label-std"><label for="input-bxexpath"><xsl:value-of select="$i18n_xml/l/BXE_XPath"/></label></div>
        <input type="text" name="bxexpath" size="60" value="{./attributes/bxexpath}" class="text" id="input-bxexpath"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
    </div>
</xsl:template>

<xsl:template name="bxe-edit">
        <div id="tr-bxeedit">
            <a href="{$xims_box}{$goxims_content}?id={@id};edit=bxe"><xsl:value-of select="$i18n_xml/l/edit_with_BXE"/></a>
        </div>
</xsl:template>

<xsl:template name="sfe-edit">
     <div id="tr-sfeedit">
        <a href="{$xims_box}{$goxims_content}?id={@id};simpleformedit=1"><xsl:value-of select="$i18n_xml/l/Edit_with_SFE"/></a>
        </div>
</xsl:template>

<xsl:template name="sfe-attribute-edit">
    <div id="tr-sfeedit-attr">
        <fieldset>
            <legend class="label-large"><!--<div id="label-sfeedit-attr">--><xsl:value-of select="$i18n_xml/l/Link_to_edit_with_SFE"/><!--</div>--></legend>
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
            
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('sfe')" class="doclink">(?)</a>
            </fieldset>
        </div>
</xsl:template>

</xsl:stylesheet>
