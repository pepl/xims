<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template name="htmlarea_scripts">
    <script type="text/javascript">
      _editor_url = &apos;<xsl:value-of select="concat($ximsroot,'htmlarea/')"/>&apos;;
      _editor_lang = &apos;<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>&apos;;
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

          HTMLArea.loadPlugin(&apos;TableOperations&apos;);
          // HTMLArea.loadPlugin(&apos;SpellChecker&apos;);
          HTMLArea.loadPlugin(&apos;CSS&apos;);
    </script>

    <style type="text/css">@import url(<xsl:value-of select="$ximsroot"/>htmlarea/htmlarea.css);</style>
    <script type="text/javascript">
        var editor = null;
        function initEditor() {
          // create an editor for the "body" textbox
          editor = new HTMLArea(&apos;body&apos;);

          // register the TableOperations plugin
          editor.registerPlugin(TableOperations);

          // register the SpellChecker plugin
          // editor.registerPlugin(SpellChecker);

          // register the CSS plugin
          editor.registerPlugin(CSS, {
            combos : [
              { label: &apos;List:&apos;,
                           // menu text       // CSS class
                options: { &apos;None&apos;           : &apos;&apos;,
                           &apos;Folder&apos;         : &apos;folderlist&apos;,
                           &apos;Document&apos;       : &apos;documentlist&apos;,
                           &apos;PDF&apos;            : &apos;pdflist&apos;,
                           &apos;Image&apos;          : &apos;imagelist&apos;,
                           &apos;Email&apos;          : &apos;emaillist&apos;,
                           &apos;External Link&apos;  : &apos;externallinklist&apos;,
                           &apos;Word&apos;           : &apos;wordlist&apos;,
                           &apos;Excel&apos;          : &apos;excellist&apos;,
                           &apos;Powerpoint&apos;     : &apos;pptlist&apos;,
                           &apos;Docbook&apos;        : &apos;docbooklist&apos;,
                           &apos;Link&apos;           : &apos;linklist&apos;,
                           &apos;Bullet&apos;         : &apos;bulletlist&apos;
                         },
                context: &apos;li&apos;,
                updatecontextclass: 1
              },
              { label: &apos;Info:&apos;,
                options: { &apos;None&apos;           : &apos;&apos;,
                           &apos;Quote&apos;          : &apos;quote&apos;,
                           &apos;Highlight&apos;      : &apos;highlighted&apos;,
                           &apos;Important&apos;      : &apos;important&apos;
                         }
              }
            ]
          });

          // load the stylesheet used by our CSS plugin configuration
          editor.config.pageStyle = &apos;@import url(<xsl:value-of select="concat($ximsroot,$defaultcss)"/>);&apos;;
          editor.config.baseURL = &apos;<xsl:choose><xsl:when test="$edit = '1'"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/></xsl:otherwise></xsl:choose>&apos;
          editor.generate();
        }
    </script>
</xsl:template>
</xsl:stylesheet>
