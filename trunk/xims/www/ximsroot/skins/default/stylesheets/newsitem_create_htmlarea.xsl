<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="document_create_htmlarea.xsl"/>
<xsl:import href="newsitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create_htmlarea"/>
    <body onLoad="document.eform['abstract'].value=''; initEditor(); document.eform.title.focus()">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-leadimage-create"/>
                    <xsl:call-template name="tr-body-create_htmlarea"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-valid_from"/>
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
    </body>
</html>
</xsl:template>

<xsl:template name="head-create_htmlarea">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="htmlarea_scripts"/>
        <xsl:call-template name="jscalendar_scripts"/>
    </head>
</xsl:template>

</xsl:stylesheet>
