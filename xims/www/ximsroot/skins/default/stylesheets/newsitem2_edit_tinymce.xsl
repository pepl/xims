<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="newsitem_edit_tinymce.xsl"/>

<xsl:param name="testlocation" select="true()"/>

<xsl:template name="tinymce_scripts">
    <xsl:call-template name="tinymce_load" />
    <!-- <xsl:call-template name="jqtinymce_load" /> -->
    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">
          var tinymceUrl = '<xsl:value-of select="concat($ximsroot,'vendor/tinymce4/js/tinymce/tinymce.js')" />';
          //var origbody = null;
          var editor = null;
          // language
          var lang = '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)" />';
          // document_base_url
          var baseUrl = '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')" />';
          // filebrowse browseurl
          var brUrl = '<xsl:value-of select="concat( $xims_box,$goxims_content,'?id=',/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id,'&amp;contentbrowse=1&amp;to=',/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id,'&amp;')" />';
          // content_css
          var css = '<xsl:value-of select="$defaultcss" /><xsl:if test="css_id != ''">,<xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')" /></xsl:if>';     
      </xsl:with-param>
    </xsl:call-template>

    <script type="text/javascript" src="{$ximsroot}scripts/tinymce4_scripts.js"><xsl:comment/></script>
  </xsl:template>
  
  <xsl:template name="tinymce_load">
     
    <!-- <script  type="text/javascript" src="{$ximsroot}vendor/tinymce4/js/tinymce/jquery.tinymce.min.js" ><xsl:comment/></script>-->
    <script  type="text/javascript" src="{$ximsroot}vendor/tinymce4/js/tinymce/tinymce.js" ><xsl:comment/></script>

    <!-- ### load minimized tinymce ### -->
<!--
    <script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/tiny_mce_gzip.js"><xsl:comment/></script>
    <script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/jquery.tinymce.js"><xsl:comment/></script>
    <script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/tiny_mce_min.js"><xsl:comment/></script>
-->
  
  </xsl:template>

</xsl:stylesheet>
