<?xml version="1.0" encoding="utf-8"?>
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

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:if test="$edit != ''">
                <xsl:call-template name="table-edit"/>
                <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                    <table border="0" width="98%">
                        <xsl:call-template name="tr-locationtitle-edit"/>
                        <xsl:call-template name="tr-stylesheet-edit"/>
                        <xsl:call-template name="tr-pagerowlimit-edit"/>
                        <xsl:call-template name="markednew"/>
                    </table>
                    <xsl:call-template name="saveedit"/>
                </form>
            </xsl:if>

        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>


<xsl:template name="tr-stylesheet-edit">

<xsl:variable name="parentid" select="parents/object[/document/context/object/@parent_id=@document_id]/@id"/>
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/Stylesheet"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="{style_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=Folder;sbfield=eform.stylesheet')" class="doclink">Browse for Stylesheet directory</a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-pagerowlimit-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/PageRowLimit"/></td>
        <td colspan="2">
            <input tabindex="35" type="text" name="pagerowlimit" size="2" maxlength="2" value="{attributes/pagerowlimit}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PageRowLimit')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


</xsl:stylesheet>
