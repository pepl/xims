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
    <script type="text/javascript">
      _editor_url = "<xsl:value-of select="concat($ximsroot,'htmlarea/')"/>";
      _editor_lang = "<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>";
    </script>
    <script type="text/javascript" src="{$ximsroot}htmlarea/htmlarea.js"><xsl:text>&#160;</xsl:text></script>
    <script type="text/javascript">
          // WARNING: using this interface to load plugin
          // will _NOT_ work if plugins do not have the language
          // loaded by HTMLArea.

          // In other words, this function generates SCRIPT tags
          // that load the plugin and the language file, based on the
          // global variable HTMLArea.I18N.lang (defined in the lang file,
          // in our case "lang/en.js" loaded above).

          // If this lang file is not found the plugin will fail to
          // load correctly and nothing will work.

          HTMLArea.loadPlugin("TableOperations");
          // HTMLArea.loadPlugin("SpellChecker");
          HTMLArea.loadPlugin("CSS");
    </script>

    <style type="text/css">@import url(<xsl:value-of select="$ximsroot"/>htmlarea/htmlarea.css);</style>
    <script type="text/javascript">
        var editor = null;
        function initEditor() {
          // create an editor for the "body" textbox
          editor = new HTMLArea("body");

          // register the TableOperations plugin
          editor.registerPlugin(TableOperations);

          // register the SpellChecker plugin
          // editor.registerPlugin(SpellChecker);

          // register the CSS plugin
          editor.registerPlugin(CSS, {
            combos : [
              { label: "List:",
                           // menu text       // CSS class
                options: { "None"           : "",
                           "Folder"         : "folderlist",
                           "Document"       : "documentlist",
                           "PDF"            : "pdflist",
                           "Image"          : "imagelist",
                           "Email"          : "emaillist",
                           "External Link"  : "externallinklist",
                           "Word"           : "wordlist",
                           "Excel"          : "excellist",
                           "Powerpoint"     : "pptlist",
                           "Docbook"        : "docbooklist",
                           "Link"           : "linklist",
                           "Bullet"         : "bulletlist"
                         },
                context: "li",
                updatecontextclass: 1
              },
              { label: "Info:",
                options: { "None"           : "",
                           "Quote"          : "quote",
                           "Highlight"      : "highlighted",
                           "Important"      : "important"
                         }
              }
            ]
          });

          // load the stylesheet used by our CSS plugin configuration
          editor.config.pageStyle = "@import url(<xsl:value-of select="concat($ximsroot,$defaultcss)"/>);";
          editor.generate();
        }
    </script>
</xsl:template>
</xsl:stylesheet>
