<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:param name="bxepresent" />

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:if test="$bxepresent=1">
                        <xsl:call-template name="bxe-edit"/>
                    </xsl:if>
                    <xsl:call-template name="tr-body-edit"/>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="tr-schema-edit"/>
                    <xsl:call-template name="tr-css-edit"/>
                    <xsl:call-template name="tr-bxeconfig-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-schema-edit">
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/Schema"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="schema" size="40" value="{./schema_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
<!--        <a href="javascript:openDocWindow('Schema')" class="doclink">(?)</a>-->
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./schema_id};otfilter=XML;sbfield=eform.schema')" class="doclink"><xsl:value-of select="$i18n/l/Browse_schema"/></a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-bxeconfig-edit">
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/BXEConfig"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="bxeconfig" size="40" value="{./attributes/bxeconfig_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
<!--        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>-->
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={./attributes/bxeconfig_id};otfilter=XML;sbfield=eform.bxeconfig')" class="doclink"><xsl:value-of select="$i18n/l/Browse_BXEconfig"/></a>
    </td>
</tr>
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/BXE_XPath"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="bxexpath" size="40" value="{./attributes/bxexpath}" class="text"/>
        <xsl:text>&#160;</xsl:text>
<!--        <a href="javascript:openDocWindow('BXE Config')" class="doclink">(?)</a>-->
        <xsl:text>&#160;</xsl:text>
    </td>
</tr>
</xsl:template>

<xsl:template name="bxe-edit">
    <tr>
        <td colspan="3">
            <xsl:if test="(./schema_id) and (./css_id) and (./attributes/bxeconfig_id) and (./attributes/bxexpath)">
                <a href="?id={@id};edit=bxe"><xsl:value-of select="$i18n/l/edit_with_BXE"/></a>
            </xsl:if>
        </td>
    </tr>
</xsl:template>



</xsl:stylesheet>
