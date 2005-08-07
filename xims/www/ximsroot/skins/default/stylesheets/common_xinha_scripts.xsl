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

<xsl:template name="xinha_scripts">
    <script type="text/javascript">
      _editor_url = &apos;<xsl:value-of select="concat($ximsroot,'xinha/')"/>&apos;;
      _editor_lang = &apos;<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>&apos;;
    </script>
    <script type="text/javascript" src="{$ximsroot}xinha/htmlarea.js"><xsl:text>&#160;</xsl:text></script>


    <!--<style type="text/css">@import url(<xsl:value-of select="$ximsroot"/>xinha/htmlarea.css);</style>-->


    <script type="text/javascript">
        var origbody = null;
    xinha_editors = null;
    xinha_init    = null;
    xinha_config  = null;
    xinha_plugins = null;

    // This contains the names of textareas we will make into Xinha editors
    xinha_init = xinha_init ? xinha_init : function()
    {
      xinha_plugins = xinha_plugins ? xinha_plugins :
      [
       'CharacterMap',
       'ContextMenu',
       'FullScreen',
       'ListType',
       'Linker',
       'EnterParagraphs',
       'TableOperations',
       'Stylist',
      ];

<!--
       'SuperClean',
       'CSS',
       'DynamicCSS',
       'SpellChecker',
-->

      if(!HTMLArea.loadPlugins(xinha_plugins, xinha_init)) return;

      xinha_editors = xinha_editors ? xinha_editors :
      [
        'body',
      ];

      xinha_config = xinha_config ? xinha_config : new HTMLArea.Config();

      xinha_editors   = HTMLArea.makeEditors(xinha_editors, xinha_config, xinha_plugins);

          <!--// register the CSS plugin-->
          <!--xinha_editors.body.registerPlugin(CSS, {-->
          <!--  combos : [-->
          <!--    { label: &apos;List:&apos;,-->
          <!--                 // menu text       // CSS class-->
          <!--      options: { &apos;None&apos;           : &apos;&apos;,-->
          <!--                 &apos;Folder&apos;         : &apos;folderlist&apos;,-->
          <!--                 &apos;Document&apos;       : &apos;documentlist&apos;,-->
          <!--                 &apos;PDF&apos;            : &apos;pdflist&apos;,-->
          <!--                 &apos;Image&apos;          : &apos;imagelist&apos;,-->
          <!--                 &apos;Email&apos;          : &apos;emaillist&apos;,-->
          <!--                 &apos;External Link&apos;  : &apos;externallinklist&apos;,-->
          <!--                 &apos;Word&apos;           : &apos;wordlist&apos;,-->
          <!--                 &apos;Excel&apos;          : &apos;excellist&apos;,-->
          <!--                 &apos;Powerpoint&apos;     : &apos;pptlist&apos;,-->
          <!--                 &apos;Docbook&apos;        : &apos;docbooklist&apos;,-->
          <!--                 &apos;Link&apos;           : &apos;linklist&apos;,-->
          <!--                 &apos;Bullet&apos;         : &apos;bulletlist&apos;-->
          <!--               },-->
          <!--      context: &apos;li&apos;,-->
          <!--      updatecontextclass: 1-->
          <!--    },-->
          <!--  ]-->
          <!--});-->

    if(typeof CSS != 'undefined') {
      xinha_editors.body.config.pageStyle = &apos;@import url(<xsl:value-of select="concat($ximsroot,$defaultcss)"/>);<xsl:if test="css_id != ''">@import url(<xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/>);</xsl:if>&apos;;
    }

    if(typeof Stylist != 'undefined')     {
      xinha_editors.body.config.stylistLoadStylesheet('<xsl:choose>
            <xsl:when test="css_id != ''"><xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="concat($ximsroot,'stylesheets/default.css')"/></xsl:otherwise>
          </xsl:choose>');
      // If you want to provide "friendly" names you can do so like
      // (you can do this for stylistLoadStylesheet as well)
      //xinha_editors.body.config.stylistLoadStyles('p.pink_text { color:pink }', {'p.pink_text' : 'Pretty Pink'});
    }


      <!--xinha_editors.body.config.width  = 640;-->
      <!--xinha_editors.body.config.height = 480;-->

      xinha_editors.body.config.baseURL = &apos;<xsl:choose><xsl:when test="$edit = '1'"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/></xsl:otherwise></xsl:choose>&apos;
      xinha_editors.body.config.hideSomeButtons( " fontname fontsize ");

      HTMLArea.startEditors(xinha_editors);
    }

    window.onload = xinha_init();

    </script>
</xsl:template>
</xsl:stylesheet>
