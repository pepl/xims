<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template name="htmlarea_scripts">
        <script src="{$ximsroot}htmlarea/htmlarea.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}htmlarea/htmlarea-lang-en.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}htmlarea/dialog.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>

        <script src="{$ximsroot}htmlarea/popupwin.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>


        <script src="{$ximsroot}htmlarea/plugins/TableOperations/table-operations.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}htmlarea/plugins/TableOperations/table-operations-lang-en.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>

        <style type="text/css">@import url(<xsl:value-of select="$ximsroot"/>htmlarea/htmlarea.css);</style>
        <script type="text/javascript">
        var editor = null;
        function initEditor() {
            editor = new HTMLArea('body');
            //editor.config.stylesheet = '<xsl:value-of select="concat($ximsroot,$defaultcss)"/>';
            //editor.config.bodyStyle = '@import url(<xsl:value-of select="concat($ximsroot,$defaultcss)"/>);'
            editor.config.editorURL = '<xsl:value-of select="$ximsroot"/>htmlarea/';
            editor.registerPlugin('TableOperations');
            editor.generate();
        };
        </script>
</xsl:template>
</xsl:stylesheet>