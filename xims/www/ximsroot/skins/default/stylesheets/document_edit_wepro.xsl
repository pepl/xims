<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit_wepro"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit_wepro"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:call-template name="tr-body-edit_wepro"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="expandrefs"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

<xsl:template name="head-edit_wepro">
    <head>
        <title><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}ewebedit/ewebeditpro.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
            <script type="text/javascript">
            function setEWProperties(sEditorName) {
                eWebEditPro.instances[sEditorName].editor.setProperty(&apos;BaseURL&apos;, &apos;<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/>&apos;);
                eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty(&apos;TransferMethod&apos;,&apos;<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/>?contentbrowse=1;style=ewebeditimage;otfilter=Image&apos;);
            }
        </script>
    </head>
</xsl:template>

<xsl:template name="tr-body-edit_wepro">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <input tabindex="30" type="hidden" name="body" value="{$bodycontent}" width="100%"/>
            <script language="JavaScript1.2">
            <!-- for ewebedit: pull parent_id into a JavaScript variable -->
            var parentID=&apos;<xsl:apply-templates select="@parent_id"/>&apos;;
            var documentID=&apos;<xsl:apply-templates select="@id"/>&apos;;
            var sEditorName = &apos;body&apos;;
            eWebEditPro.create(sEditorName, &apos;99.5%&apos;, &apos;450&apos;);
            eWebEditPro.onready = &apos;setEWProperties(sEditorName)&apos;;
            </script>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
