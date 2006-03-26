<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="vlibraryitem_common.xsl"/>
    <xsl:import href="common_htmlarea_scripts.xsl"/>

    <xsl:variable name="bodycontent">
        <xsl:call-template name="body"/>
    </xsl:variable>

    <xsl:template match="/document/context/object">
        <html>
                <head>
            <xsl:call-template name="head-edit_htmlarea"/>
            <xsl:call-template name="jscalendar_scripts"/>
            </head>
            <body onLoad="initEditor();">
                <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
                <div class="edit">
                    <xsl:call-template name="table-edit"/>
                    <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                        <table border="0" width="98%">
                            <!--<xsl:call-template name="tr-locationtitle-edit_doc"/>-->
                            <xsl:call-template name="tr-locationtitle-edit"/>
                            <xsl:call-template name="tr-vlsubjects-edit"/>
                            <xsl:call-template name="tr-chronicle_from"/>
                            <xsl:call-template name="tr-chronicle_to"/>
                            <xsl:call-template name="tr-abstract-edit"/>
                            <xsl:call-template name="tr-publisher-edit"/>
                            <xsl:call-template name="tr-vlkeywords-edit"/>
                            <xsl:call-template name="tr-body-edit_htmlarea"/>
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

    <xsl:template name="head-edit_htmlarea">
        <head>
            <title><xsl:value-of select="$i18n/l/Edit"/> <xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <xsl:call-template name="htmlarea_scripts"/>
        </head>
    </xsl:template>

    <xsl:template name="tr-body-edit_htmlarea">
        <tr>
            <td colspan="3">
                Body
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
                <br/>
                <textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32" onChange="document.getElementById('xims_wysiwygeditor').disabled = true;">
                    <xsl:value-of select="$bodycontent"/>
                </textarea>
                <xsl:call-template name="jsorigbody"/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="jsorigbody">
        <script type="text/javascript">
            if (document.readyState != 'complete') {
                var f = function() { origbody = window.editor.getHTML(); }
                if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
                    setTimeout(f, 3700); // MSIE needs that high timeout value
                } 
                else {
                    setTimeout(f, 2000);
                }
            }
            else {
                origbody = window.editor.getHTML();
            }
        </script>
    </xsl:template>

</xsl:stylesheet>
