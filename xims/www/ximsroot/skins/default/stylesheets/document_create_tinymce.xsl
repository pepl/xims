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
<xsl:import href="document_common.xsl"/>
<xsl:import href="common_tinymce_scripts.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body onload="timeoutWYSIWYGChange(2); document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-body-create_tinymce"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="expandrefs"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
        <xsl:call-template name="tinymce_scripts"/>
    </body>
</html>
</xsl:template>

<xsl:template name="title">
    <xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
</xsl:template>

<xsl:template name="tr-body-create_tinymce">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;">
                <xsl:text>&lt;p&gt;&#160;&lt;/p&gt;</xsl:text>
            </textarea>
            <xsl:call-template name="jsorigbody"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
