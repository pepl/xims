<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:template name="tinymce_scripts">
		<xsl:call-template name="tinymce_load"/>
		<xsl:call-template name="jqtinymce_load"/>
		<script language="javascript" type="text/javascript">        
            var origbody = null;
            var editor = null;
            
            var lang = '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>';  				//language
			var baseUrl = '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/>';   				//baseurl
			var brUrl = '<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>&amp;contentbrowse=1&amp;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>&amp;';			//browseUrl		
		</script>
		<!--######################   tinymce.init() MOVED TO tinymce_script.js   ###############################-->
		<script language="javascript" type="text/javascript" src="{$ximsroot}scripts/tinymce_script.js"/>
	</xsl:template>
	<xsl:template name="jsorigbody">
		<script type="text/javascript">
		  function func() { 
						tinyMCE.get('body').execCommand('mceCleanup',false, false);
                        origbody= tinyMCE.get('body').getContent();
                }
            if (document.readyState != 'complete') {
                if (window.tinyMCE) {
                //var f = function() { origbody = window.tinyMCE.getContent(); }
                //var f = function() { 
						//tinyMCE.get('body').execCommand('mceCleanup',false, false);

                }
                if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
                    setTimeout('func()', 3700); // MSIE needs that high timeout value
                }
                else {
                setTimeout('func()', 3000);
                }
            }
            else {
                origbody = tinyMCE.get('body').getContent();
            }
        </script>
	</xsl:template>
	<xsl:template name="jqtinymce_load">
		<script language="javascript" type="text/javascript" src="{$ximsroot}tinymce/jscripts/tiny_mce/jquery.tinymce.js"/>
	</xsl:template>
	<xsl:template name="tinymce_load">
		<script language="javascript" type="text/javascript" src="{$ximsroot}tinymce/jscripts/tiny_mce/tiny_mce.js"/>
	</xsl:template>
	<xsl:template name="tinymce_simple">
		<script language="javascript" type="text/javascript">
         tinyMCE.init({
           mode : "textareas",
           editor_selector : "mceEditor",
           language : '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>',
           theme : "advanced",
           plugins : 'paste,inlinepopups',
           theme_advanced_buttons1 : "bold,italic,underline,separator,strikethrough,justifyleft,justifycenter,justifyright,"
                                   + "justifyfull,bullist,numlist,undo,redo,link,unlink,code,help",
           theme_advanced_buttons2 : "",
           theme_advanced_buttons3 : "",
           theme_advanced_toolbar_location : "top",
           theme_advanced_toolbar_align : "left",
           theme_advanced_statusbar_location : "bottom",
           theme_advanced_path_location : 'bottom',
           theme_advanced_resizing : true,           
           button_tile_map : true,
           entity_encoding : 'raw'
           //extended_valid_elements : "a[name|href|target|title|onclick],"
           //                        + "img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],"
           //                        + "hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]"
         })
       </script>
	</xsl:template>
</xsl:stylesheet>
