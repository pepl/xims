<?xml version="1.0" encoding="iso-8859-1"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:variable name="bodycontent">
        <xsl:call-template name="body"/>
    </xsl:variable>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit_htmlarea"/>
    <body onLoad="initEditor(); ">
        <p class="edit">
            <xsl:call-template name="table-edit_wepro"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:call-template name="tr-body-edit_htmlarea"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="expandrefs"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

<xsl:template name="head-edit_htmlarea">
    <head>
            <title>Edit <xsl:value-of select="$objtype"/> in <xsl:value-of select="$absolute_path"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}htmlarea/htmlarea.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}htmlarea/htmlarea-lang-en.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}htmlarea/dialog.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
<!--
            <script src="{$ximsroot}htmlarea/popupwin.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
-->
<!--
            <script src="{$ximsroot}htmlarea/plugins/TableOperations/table-operations.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}htmlarea/plugins/TableOperations/table-operations-lang-en.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
-->
            <style type="text/css">@import url(<xsl:value-of select="$ximsroot"/>htmlarea/htmlarea.css);</style>
            <script type="text/javascript">
            var editor = null;
            function initEditor() {
                editor = new HTMLArea('body');
                //editor.config.stylesheet = '<xsl:value-of select="concat($ximsroot,$defaultcss)"/>';
                //editor.config.bodyStyle = '@import url(<xsl:value-of select="concat($ximsroot,$defaultcss)"/>);'
                editor.config.editorURL = '<xsl:value-of select="$ximsroot"/>htmlarea/';
                //editor.registerPlugin('TableOperations');
                editor.generate();
            };
            </script>
    </head>
</xsl:template>

<xsl:template name="tr-body-edit_htmlarea">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32">
                <xsl:value-of select="$bodycontent"/>
            </textarea>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>