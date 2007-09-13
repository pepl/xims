<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:template name="tinymce_scripts">
        <script language="javascript" type="text/javascript" src="{$ximsroot}tinymce/jscripts/tiny_mce/tiny_mce.js"/>
        <script language="javascript" type="text/javascript">
            var origbody = null;
            var editor = null;
            tinyMCE.init({
                mode : 'exact',
                elements : 'body',
                language : '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>',
                document_base_url : '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/>',
                auto_cleanup_word : true,
                entity_encoding : 'raw',
                plugins : 'table,contextmenu,advhr,searchreplace',
                theme_advanced_buttons1_add_before: 'cut,copy,paste,separator,search,replace,separator',
                theme_advanced_buttons3_add_before : 'tablecontrols,separator',
                theme_advanced_toolbar_location : 'top',
                theme_advanced_toolbar_align : 'left',
                theme_advanced_path_location : 'bottom',
                theme_advanced_resizing : true,
                theme_advanced_resize_horizontal : false,
                content_css :  &apos;<xsl:choose>
                    <xsl:when test="css_id != ''"><xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="concat($ximsroot,$defaultcss)"/></xsl:otherwise>
                  </xsl:choose>&apos;,
                file_browser_callback : 'filebrowse',
                urlconverter_callback : 'urltransformer',
                remove_linebreaks : 'false',
                cleanup : 'true',
                cleanup_on_startup : 'false',
                apply_source_formatting : 'true'
            });

            /*
             * Custom file-browse dialog (XIMS file-browse-url)
             */
            function filebrowse (field_name, url, type, win) {
                if (type == "file") {
                    var browseurl = '<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>&amp;contentbrowse=1&amp;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>&amp;style=tinymcelink';
                }
                else {
                    var browseurl = '<xsl:value-of select="concat($xims_box,$goxims_content)"/>?id=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>&amp;contentbrowse=1&amp;to=<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>&amp;style=tinymceimage&amp;otfilter=Image';
                }
                <![CDATA[
                var cmsURL = window.location.pathname;      
                var searchString = window.location.search;  
                if (searchString.length < 1) {
                    searchString = "?";
                }
                tinyMCE.openWindow({
                    file : browseurl,
                    title : "XIMS File Browser",
                    width : 600,  // width of XIMS File Browser pop-up
                    height : 400,
                    close_previous : "no"
                }, {
                    window : win,
                    input : field_name,
                    resizable : "yes",
                    scrollbars : "yes",
                    inline : "yes",  // This parameter only has an effect if you use the inlinepopups plugin!
                    editor_id : tinyMCE.getWindowArg("editor_id")
                });
                return false;
                ]]>
            }

            /*
             * Custom URL transformation routine. Make TinyMCE
             * act more like HTMLArea
             *   1. leave URLs starting with a '/' untouched
             *   2. leave URLS starting with 'http://' untouched => unchanged feature
             *   3. resolve all other URLs relative to 'document_base_url'
             * 
             * We first check for '/'-starting URLs and pass it then on to TinyMCEs
             * default function 'TinyMCE.prototype.convertURL' :-)
             */
            function urltransformer (url, node, on_save) {
                // Do some custom URL conversion
                if ( url.charAt(0) == '/' ) {
                    return url;
                }
                else {
                    // we simply pass it on to the default TinyMCE function
                    return tinyMCE.convertURL(url, node, on_save);
                }
            }
        </script>
    </xsl:template>

    <xsl:template name="jsorigbody">
        <script type="text/javascript">
            if (document.readyState != 'complete') {
                var f = function() { origbody = window.tinyMCE.getContent(); }
                if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
                    setTimeout(f, 3700); // MSIE needs that high timeout value
                }
                else {
                    setTimeout(f, 3000);
                }
            }
            else {
                origbody = window.tinyMCE.getContent();
            }
        </script>
    </xsl:template>

</xsl:stylesheet>
