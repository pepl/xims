<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
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
     --->


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
          editor.config.imageURL = &apos;<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;contentbrowse=1;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;style=htmlareaimage;otfilter=Image&apos;
          editor.config.linkURL = &apos;<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;contentbrowse=1;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;style=htmlarealink&apos;
          editor.config.hideSomeButtons( " fontname fontsize ");
          // used by ContextMenu plugin
          editor.config.siterootPath = &apos;<xsl:value-of select="concat($xims_box,$goxims_content,'/',/document/context/object/parents/object[@parent_id=1]/location)"/>&apos;
          editor.generate();
        }
    </script>
</xsl:template>
</xsl:stylesheet>
