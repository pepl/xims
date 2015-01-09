<?xml version="1.0"?>
	<!--
		# Copyright (c) 2002-2015 The XIMS Project. # See the file "LICENSE"
		for information and conditions for use, reproduction, # and
		distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
		$Id: common_tinymce_scripts.xsl 2249 2009-08-10 11:29:26Z haensel $
	-->
<xsl:stylesheet version="1.0"
	            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
                xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:param name="tinymce_version">3</xsl:param>
	
	<xsl:template name="tinymce_scripts">
		<xsl:call-template name="tinymce_load"/>
		<!-- <xsl:call-template name="jqtinymce_load" /> -->
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
				<xsl:choose>
		     		<xsl:when test="$tinymce_version = '4'">
						var tinymceUrl = '<xsl:value-of	select="concat($ximsroot,'vendor/tinymce4/js/tinymce/tinymce.min.js')" />';
					</xsl:when>
		     		<xsl:otherwise>
		     			var tinymceUrl = '<xsl:value-of	select="concat($ximsroot,'vendor/tinymce3/jscripts/tiny_mce/tiny_mce.js')" />';
		     		</xsl:otherwise>
		     	</xsl:choose>
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
		
		<xsl:choose>
     		<xsl:when test="$tinymce_version = '4'">
				<script type="text/javascript" src="{$ximsroot}scripts/tinymce4_script.js"><xsl:comment/></script>
			</xsl:when>
     		<xsl:otherwise>
     			<script type="text/javascript" src="{$ximsroot}scripts/tinymce_script.js"><xsl:comment/></script>
     		</xsl:otherwise>
     	</xsl:choose>
	</xsl:template>
	
	<xsl:template name="tinymce_load">
     	<xsl:choose>
     		<xsl:when test="$tinymce_version = '4'">
     			<script  type="text/javascript" src="{$ximsroot}vendor/tinymce4/js/tinymce/jquery.tinymce.min.js" ><xsl:comment/></script>
     			<script  type="text/javascript" src="{$ximsroot}vendor/tinymce4/js/tinymce/tinymce.min.js" ><xsl:comment/></script>
     		</xsl:when>
     		<xsl:otherwise>
     			<script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/jquery.tinymce.js" ><xsl:comment/></script>
				<script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/tiny_mce.js" ><xsl:comment/></script>
     		</xsl:otherwise>
     	</xsl:choose>
     	
		<!-- ### load minimized tinymce ### -->
<!--
		<script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/tiny_mce_gzip.js"><xsl:comment/></script>
		<script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/jquery.tinymce.js"><xsl:comment/></script>
    <script  type="text/javascript" src="{$ximsroot}vendor/tinymce3/jscripts/tiny_mce/tiny_mce_min.js"><xsl:comment/></script>
-->
  
	</xsl:template>
	
	<xsl:template name="tinymce_simple">
		<script  type="text/javascript">
			tinyMCE.init({ mode : "textareas", editor_selector : "mceEditor",
			language : '<xsl:value-of
			select="substring(/document/context/session/uilanguage,1,2)" />',
			theme : "advanced", plugins : 'paste,inlinepopups',
			theme_advanced_buttons1 :
			"bold,italic,underline,separator,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,undo,redo,link,unlink,code,help",
			theme_advanced_buttons2 : "", theme_advanced_buttons3 : "",
			theme_advanced_toolbar_location : "top",
			theme_advanced_toolbar_align : "left",
			theme_advanced_statusbar_location : "bottom",
			theme_advanced_path_location : 'bottom', theme_advanced_resizing :
			true, button_tile_map : true, entity_encoding : 'raw' //
			extended_valid_elements : "a[name|href|target|title|onclick]," // +
			"img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],"
			// +
			"hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]"
			})
		</script>
	</xsl:template>
</xsl:stylesheet>
