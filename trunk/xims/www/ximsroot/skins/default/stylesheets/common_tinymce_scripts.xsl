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
        <!-- variable used for propper url-conversion:
                see 'urltransformer' JS function -->
        <xsl:variable name="xims_host_temp">
            <xsl:choose>
                <!-- we have to substitute 'https://' with 'http://'
                     for correct url conversion -->
                <xsl:when test="starts-with($xims_box, 'https://')">
                    <xsl:value-of select="concat('http:\/\/', substring-after($xims_box, 'https://'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('http:\/\/', substring-after($xims_box, 'http://'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="tinymce_load"/>
        <script language="javascript" type="text/javascript">
            var origbody = null;
            var editor = null;
            tinyMCE.init({
                mode : 'exact',
                elements : 'body',
                theme : 'advanced',
                language : '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>',
                document_base_url : '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/>',
                auto_cleanup_word : true,
                entity_encoding : 'raw',
                file_browser_callback : 'filebrowse',
                urlconverter_callback : 'urltransformer',
                content_css :  &apos;<xsl:choose>
                            <xsl:when test="css_id != ''"><xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="concat($ximsroot,$defaultcss)"/></xsl:otherwise>
                          </xsl:choose>&apos;
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
        tinyMCE.get('body').windowManager.open({
        file : browseurl,
        title : "XIMS File Browser",
        width : 600,  // width of XIMS File Browser pop-up
        height : 400,
        resizable : "yes",
        scrollbars : "yes",
        inline : "yes",  // This parameter only has an effect if you use the inlinepopups plugin!
        close_previous : "no"
        }, {
        window : win,
        input : field_name
        });
        return false;
        }
        ]]>

            /*
             * Custom URL transformation routine. Make TinyMCE
             * act more like HTMLArea
             *   1. leave URLs starting with a '/' untouched
             *   2. leave URLS starting with 'http://' untouched
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
                    // test for 'http://' matches
                    <xsl:value-of select="concat('match = url.search(/^',$xims_host_temp,'\/gopublic\/.+/);')"/>
                    if ( match != -1 ) {
                        return url;
                    }
                    else {
                        // we simply pass it on to the default TinyMCE function (implicit)
            return url;
                    }
                }
            }
        </script>
    </xsl:template>

    <xsl:template name="jsorigbody">
        <script type="text/javascript">
            if (document.readyState != 'complete') {
                if (window.tinyMCE) {
                //var f = function() { origbody = window.tinyMCE.getContent(); }
                var f = function() { tinyMCE.get('body').execCommand('mceCleanup',false, false);
                                     origbody= tinyMCE.get('body').getContent();
                }
                }
                if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
                    setTimeout(f, 3700); // MSIE needs that high timeout value
                }
                else {
                setTimeout(f, 3000);
                }
            }
            else {
                origbody = tinyMCE.get('body').getContent();
            }
        </script>
    </xsl:template>

    <xsl:template name="tinymce_load">
       <script language="javascript"
               type="text/javascript"
               src="{$ximsroot}tinymce/jscripts/tiny_mce/tiny_mce.js"/>
    </xsl:template>

    <xsl:template name="tinymce_simple">
       <script language="javascript"
               type="text/javascript">
         tinyMCE.init({
           mode : "textareas",
       editor_selector : "mceEditor",
       theme : "simple",
           language : '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>',
         });
       </script>
    </xsl:template>

</xsl:stylesheet>
