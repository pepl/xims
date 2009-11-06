<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="document_common.xsl"/>
<xsl:import href="document_create_wepro.xsl"/>
<xsl:import href="newsitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create_wepro"/>
    <body onLoad="document.eform['abstract'].value=''; document.eform.title.focus()">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-leadimage-create"/>
                    <xsl:call-template name="tr-body-create_wepro"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-valid_from"/>
                    <xsl:call-template name="tr-valid_to"/>
                    <tr>
                        <td colspan="3">
                            <xsl:call-template name="markednew"/>
                        </td>
                    </tr>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="head-create_wepro">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <script src="{$ximsroot}wepro/ewebeditpro.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
            <script type="text/javascript">
            function setEWProperties(sEditorName) {
                eWebEditPro.instances[sEditorName].editor.setProperty(&apos;BaseURL&apos;, &apos;<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/>&apos;);
                eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty(&apos;TransferMethod&apos;,&apos;<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/>?contentbrowse=1;style=ewebeditimage;otfilter=Image&apos;);
            }
        </script>
        <xsl:call-template name="jscalendar_scripts"/>
    </head>
</xsl:template>

</xsl:stylesheet>
