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

<xsl:import href="common_htmlarea_scripts.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create_htmlarea"/>
    <body onLoad=" document.eform['abstract'].value=''; initEditor(); document.eform.name.focus()">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-body-create_htmlarea"/>
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

<xsl:template name="head-create_htmlarea">
    <head>
        <title><xsl:value-of select="$i18n/l/Create"/> <xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="htmlarea_scripts"/>
    </head>
</xsl:template>

<xsl:template name="tr-body-create_htmlarea">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32">
                <xsl:text>&#160;</xsl:text>
            </textarea>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
