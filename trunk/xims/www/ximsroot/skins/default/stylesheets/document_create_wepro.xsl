<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create_wepro"/>
    <body onLoad="document.eform.abstract.value='';">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-body-create_wepro"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
            </div>
            <br />
            <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="without-wysiwyg"/>
    </body>
</html>
</xsl:template>

<xsl:template name="head-create_wepro">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}wepro/ewebeditpro.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
            <script type="text/javascript">
            function setEWProperties(sEditorName) {
                eWebEditPro.instances[sEditorName].editor.setProperty(&apos;BaseURL&apos;, &apos;<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/>&apos;);
                eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty(&apos;TransferMethod&apos;,&apos;<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/>?contentbrowse=1;style=ewebeditimage;otfilter=Image&apos;);
            }
        </script>
    </head>
</xsl:template>

<xsl:template name="tr-body-create_wepro">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <input tabindex="30" type="hidden" name="body" value="" width="100%"/>
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
