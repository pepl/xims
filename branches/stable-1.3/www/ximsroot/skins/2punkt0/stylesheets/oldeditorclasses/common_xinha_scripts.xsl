<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_xinha_scripts.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="xinha_scripts">
    <script type="text/javascript">
      _editor_url = &apos;<xsl:value-of select="concat($ximsroot,'xinha/')"/>&apos;;
      _editor_lang = &apos;<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>&apos;;
      <!--_editor_skin = "silva";   // If you want use a skin, add the name (of the folder) here-->
    </script>
    <script type="text/javascript" src="{$ximsroot}xinha/XinhaCore.js"><xsl:text>&#160;</xsl:text></script>

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

      xinha_editors = xinha_editors ? xinha_editors : [ 'body' ];

      xinha_plugins = xinha_plugins ? xinha_plugins :
      [
      'CharacterMap',
      'ContextMenu',
      'ListType',
      'Stylist',
      'SuperClean',
      'TableOperations'
      ];

      // THIS BIT OF JAVASCRIPT LOADS THE PLUGINS, NO TOUCHING  :)
      if(!Xinha.loadPlugins(xinha_plugins, xinha_init)) return;

      xinha_config = xinha_config ? xinha_config() : new Xinha.Config();

      // To adjust the styling inside the editor, we can load an external stylesheet like this
      // NOTE : YOU MUST GIVE AN ABSOLUTE URL

      xinha_config.pageStyleSheets = [ &apos;<xsl:value-of select="concat($ximsroot,$defaultcss)"/>&apos;<xsl:if test="css_id != ''">,&apos;<xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/>&apos;</xsl:if> ];

      <xsl:if test="css_id != ''">xinha_config.stylistLoadStylesheet(&apos;<xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/>&apos;);</xsl:if>

      xinha_config.stripScripts = false;

      xinha_config.toolbar =
      [
      ["popupeditor"],
      ["separator","formatblock","bold","italic","underline","strikethrough"],
      ["separator","subscript","superscript"],
      ["linebreak","separator","justifyleft","justifycenter","justifyright","justifyfull"],
      ["separator","insertorderedlist","insertunorderedlist","outdent","indent"],
      ["separator","inserthorizontalrule","createlink","insertimage","inserttable"],
      ["linebreak","separator","undo","redo","selectall","print"], (Xinha.is_gecko ? [] : ["cut","copy","paste","overwrite","saveas"]),
      ["separator","killword","clearfonts","removeformat","toggleborders","splitblock","lefttoright", "righttoleft"],
      ["separator","htmlmode","showhelp","about"]
      ];

      xinha_config.baseURL = &apos;<xsl:choose><xsl:when test="$edit = '1'"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/></xsl:otherwise></xsl:choose>&apos;;

      xinha_config.baseHref = &apos;<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/>&apos;;

      <!-- TODO: Check why drap&drop of images does not work
      xinha_config.baseURL = 'content/$parent_path';
      xinha_config.expandRelativeUrl = false;
      xinha_config.stripBaseHref = false;
      -->

      xinha_config.makeLinkShowsTarget = false;

      xinha_config.URIs['insert_image'] = &apos;<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;contentbrowse=1;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;style=xinhaimage;otfilter=Image&apos;;
      xinha_config.URIs['link'] = &apos;<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;contentbrowse=1;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>;style=xinhalink&apos;;

      xinha_editors   = Xinha.makeEditors(xinha_editors, xinha_config, xinha_plugins);
      Xinha.startEditors(xinha_editors);
      }

      Xinha._addEvent(window,'load', xinha_init); // this executes the xinha_init function on page load
      // and does not interfere with window.onload properties set by other scripts


    </script>
</xsl:template>
</xsl:stylesheet>
