<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:param name="bxepresent" />

<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:if test="$bxepresent=1 and (./schema_id) and (./css_id) and (./attributes/bxeconfig_id) and (./attributes/bxexpath)">
                        <xsl:call-template name="bxe-edit"/>
                    </xsl:if>
                    <xsl:if test="schema_id and attributes/sfe = '1'">
                        <xsl:call-template name="sfe-edit"/>
                    </xsl:if>
                    <xsl:call-template name="tr-body-edit"/>
                    <tr>
                        <td colspan="3">
                            <xsl:call-template name="testbodysxml"/>
                            <xsl:call-template name="prettyprint">
                                <xsl:with-param name="ppmethod">prettyprintxml</xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </tr>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="tr-schema-edit"/>
                    <xsl:call-template name="tr-css-edit"/>
                    <xsl:call-template name="tr-bxeconfig-edit"/>
                    <xsl:if test="schema_id">
                        <xsl:call-template name="sfe-attribute-edit"/>
                    </xsl:if>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-schema-edit">
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/Schema"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="schema" size="40" value="{./schema_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Schema')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./schema_id};otfilter=XML;sbfield=eform.schema')" class="doclink"><xsl:value-of select="$i18n_xml/l/Browse_schema"/></a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-bxeconfig-edit">
<tr>
    <td valign="top"><xsl:value-of select="$i18n_xml/l/BXEConfig"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="bxeconfig" size="40" value="{./attributes/bxeconfig_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./attributes/bxeconfig_id};otfilter=XML;sbfield=eform.bxeconfig')" class="doclink"><xsl:value-of select="$i18n_xml/l/Browse_BXEconfig"/></a>
    </td>
</tr>
<tr>
    <td valign="top"><xsl:value-of select="$i18n_xml/l/BXE_XPath"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="bxexpath" size="40" value="{./attributes/bxexpath}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
    </td>
</tr>
</xsl:template>

<xsl:template name="bxe-edit">
    <tr>
        <td colspan="3">
            <a href="{$xims_box}{$goxims_content}?id={@id};edit=bxe"><xsl:value-of select="$i18n_xml/l/edit_with_BXE"/></a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="sfe-edit">
    <tr>
        <td colspan="3">
            <a href="{$xims_box}{$goxims_content}?id={@id};simpleformedit=1"><xsl:value-of select="$i18n_xml/l/Edit_with_SFE"/></a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="sfe-attribute-edit">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n_xml/l/Link_to_edit_with_SFE"/>
            <input name="sfe" type="radio" value="true">
              <xsl:if test="attributes/sfe = '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/Yes"/>
            <input name="sfe" type="radio" value="false">
              <xsl:if test="attributes/sfe!= '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('sfe')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
