<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_htmlarea_scripts.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="htmlarea_scripts">
    <!--
         The following HTMLArea integration depends on a customized version of HTMLArea3 RC1
         available from http://xims.info/download/.
         createLinkX() and createImageX() functions have been created by Britta Tautermann.
         After the development of Xinha has stabilized, we will work on plugin-based versions
         of our customizations (ImageManager, LinkBrowser, CSS, HtmlTidy, ContextMenus modules).
     -->


    <script type="text/javascript">
      _editor_url = &apos;<xsl:value-of select="concat($ximsroot,'htmlarea/')"/>&apos;;
      _editor_lang = &apos;<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>&apos;;
    </script>
    <script type="text/javascript" src="{$ximsroot}htmlarea/htmlarea.js"><xsl:text>&#160;</xsl:text></script>
    <script type="text/javascript">
          HTMLArea.loadPlugin(&apos;TableOperations&apos;);
          HTMLArea.loadPlugin(&apos;CSS&apos;);
          HTMLArea.loadPlugin(&apos;ContextMenu&apos;);
          HTMLArea.loadPlugin(&apos;HtmlTidy&apos;);
          HTMLArea.loadPlugin(&apos;ImageProperties&apos;);
          HTMLArea.loadPlugin(&apos;CharacterMap&apos;);
    </script>

    <style type="text/css">@import url(<xsl:value-of select="$ximsroot"/>htmlarea/htmlarea.css);</style>
    <script type="text/javascript">
        var origbody = null;
        var editor = null;

        function initEditor() {
          // create an editor for the "body" textbox
          editor = new HTMLArea(&apos;body&apos;);

          // register the TableOperations plugin
          editor.registerPlugin(TableOperations);

          editor.registerPlugin(ContextMenu);
          editor.registerPlugin(HtmlTidy);
          editor.registerPlugin(ImageProperties);
          editor.registerPlugin(CharacterMap);

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

          // external stylesheets to load
          editor.config.pageStyleSheets = [ &apos;<xsl:value-of select="concat($ximsroot,$defaultcss)"/>&apos; ];
          <xsl:if test="css_id != ''">
          editor.config.pageStyleSheets.push( &apos;<xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/>&apos;);
          </xsl:if>

          editor.config.baseURL = &apos;<xsl:choose><xsl:when test="$edit = '1'"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/></xsl:otherwise></xsl:choose>&apos;;
          editor.config.imageURL = &apos;<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;contentbrowse=1;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;style=htmlareaimage;otfilter=Image&apos;;
          editor.config.linkURL = &apos;<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;contentbrowse=1;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;style=htmlarealink&apos;;
          editor.config.hideSomeButtons( " fontname fontsize ");
          // used by ContextMenu plugin
          editor.config.siterootPath = &apos;<xsl:value-of select="concat($xims_box,$goxims_content,'/',/document/context/object/parents/object[@parent_id=1]/location)"/>&apos;;
          editor.generate();
        }
    </script>
</xsl:template>

<xsl:template name="jsorigbody">
    <script type="text/javascript">
        if (document.readyState != 'complete') {
            var f = function() { origbody = window.editor.getHTML(); }
            if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
                setTimeout(f, 3700); // MSIE needs that high timeout value
            }
            else {
                setTimeout(f, 3000);
            }
        }
        else {
            origbody = window.editor.getHTML();
        }
    </script>
</xsl:template>

</xsl:stylesheet>