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
        <script language="javascript" type="text/javascript" src="{$ximsroot}tinymce/jscripts/tiny_mce/tiny_mce.js"/>
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

                <!--
                ################################################
                    Start IBK customizations
                ################################################
                -->
		remove_linebreaks : 'false',
		cleanup_on_startup : 'false',
		cleanup : 'true',
                valid_elements : '*[*]',
                apply_source_formatting : 'true',
                plugins : 'table,contextmenu,advhr,searchreplace,paste,inlinepopups,uibkextras',
                theme_advanced_buttons1: 'cut,copy,paste,pastetext,search,replace,separator,undo,redo,separator,anchor,link,unlink,separator,hr,image,separator,numlist,bullist,outdent,indent,blockquote,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,visualaid,code,help',
                theme_advanced_buttons2: 'removeformat,cleanup,styleselect,formatselect,separator,bold,italic,underline,separator,sup,sub,separator,charmap,separator,uibkextras_MsWord,uibkextras_MsExcel,uibkextras_MsPPT,uibkextras_Document,uibkextras_PDF,uibkextras_EMail,uibkextras_Folder,uibkextras_Image',
                theme_advanced_buttons3: 'tablecontrols',
                theme_advanced_toolbar_location : 'top',
                theme_advanced_toolbar_align : 'left',
                theme_advanced_path_location : 'bottom',
                theme_advanced_resizing : true,
                theme_advanced_resize_horizontal : false,
                theme_advanced_styles : 'Highlighted Background=highlighted;Important=important;Border=warn;Indent Both=blockquote;Indent First Line=firstline_indent;Table Light=bg_light;Table Dark=bg_dark;Table Border=bg_border;Table Header=bg_header;List Icon Folder=folderlist;List Icon PDF=pdflist;List Icon MS-Word=wordlist;List Icon MS-Excel=excellist;List Icon MS-Powerpoint=pptlist;List Icon Bild=imagelist;List Icon Document=documentlist;List Icon Email=emaillist',
		content_css :  'https://www.uibk.ac.at/stylesheets/css/07/wysiwyg_editoren.css',
                uibkextras_ressourceUrl : 'http://www.uibk.ac.at/images/07/icons/',
                uibkextras_iconNames : 'MsWord=list_word.gif,MsExcel=list_excel.gif,MsPPT=list_ppt.gif,Document=list_document_generic.gif,EMail=list_email.gif,PDF=list_pdf.gif,Folder=list_folder.gif,Image=list_png.gif'
                <!-- 
                ################################################
                    End of UIBK customizations
                ################################################
                -->
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

</xsl:stylesheet>
