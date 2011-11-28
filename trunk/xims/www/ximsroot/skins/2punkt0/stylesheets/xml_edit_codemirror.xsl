<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xml_edit_codemirror.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common_codemirror.xsl"/>
<xsl:import href="codemirror_common.xsl"/>
<xsl:import href="codemirror_xml_script.xsl"/>

<xsl:param name="codemirror" select="true()"/>	
<xsl:param name="selEditor" select="true()"/>
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
	<xsl:call-template name="form-body-edit_codemirror"/>
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
		<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./schema_id};otfilter=XML;sbfield=eform.schema','default-dialog','{$i18n_xml/l/Browse_schema}')" class="button"><xsl:value-of select="$i18n_xml/l/Browse_schema"/></a>
    </div>
</xsl:template>

<xsl:template name="tr-bxeconfig-edit">
<div id="tr-bxeconfig">
    <div class="label-std"><label for="input-bxeconfig"><xsl:value-of select="$i18n_xml/l/BXEConfig"/></label></div>
        <input type="text" name="bxeconfig" size="60" value="{./attributes/bxeconfig_id}" class="text" id="input-bxeconfig"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./attributes/bxeconfig_id};otfilter=XML;sbfield=eform.bxeconfig','default-dialog','{$i18n_xml/l/Browse_BXEconfig}')" class="button"><xsl:value-of select="$i18n_xml/l/Browse_BXEconfig"/></a>
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
     <div class="form-div block">
        <a href="{$xims_box}{$goxims_content}?id={@id};simpleformedit=1" class="button"><xsl:value-of select="$i18n_xml/l/Edit_with_SFE"/></a>
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
            
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('sfe')" class="doclink">(?)</a>
            </fieldset>
        </div>
</xsl:template>

<xsl:template name="form-body-edit_codemirror">
		<div class="block form-div">
            <h2><label for="body">Body</label>
            <xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Body')" class="doclink">
			<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/>
				</xsl:attribute>(?)</a></h2>
			<textarea name="body" id="body" rows="20" cols="90">
				<xsl:value-of select="$bodycontent"/>
			</textarea>
		</div>
</xsl:template>

</xsl:stylesheet>
