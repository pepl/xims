/**
 * Copyright (c) 2002-2009 The XIMS Project.
 * See the file "LICENSE" for information and conditions for use, reproduction,
 * and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @author suse
 */


$().ready(function(){

    $("#body").tinymce({
    
        // General options
        theme: "advanced",
        plugins: 'table,contextmenu,advhr,searchreplace,inlinepopups,safari,xhtmlxtras,paste',
        // Theme options
        theme_advanced_buttons1: 'cut,copy,paste,pastetext,pasteword,search,replace,separator,undo,redo,separator,anchor,link,unlink,separator,hr,image,separator,numlist,bullist,outdent,indent,blockquote,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,visualaid,code,help',
        theme_advanced_buttons2: 'removeformat,cleanup,styleselect,formatselect,separator,bold,italic,underline,separator,sup,sub,separator,charmap',
        theme_advanced_buttons3: 'tablecontrols,|,cite,ins,del,abbr,acronym',
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left",
        theme_advanced_statusbar_location: "bottom",
        theme_advanced_path_location: 'bottom',
        theme_advanced_resizing: true,
        theme_advanced_resize_horizontal: false,
        theme_advanced_styles: 'Highlighted Background=highlighted;Important=important;Border=warn;Indent Both=blockquote;Indent First Line=firstline_indent;Small Caps=small-caps;Table Light=bg_light;Table Dark=bg_dark;Table Border=bg_border;Table Header=bg_header;List Icon Folder=folderlist;List Icon PDF=pdflist;List Icon MS-Word=wordlist;List Icon MS-Excel=excellist;List Icon MS-Powerpoint=pptlist;List Icon Bild=imagelist;List Icon Document=documentlist;List Icon Email=emaillist',
        button_tile_map: true,
        convert_urls : false,
        language: lang, 
        document_base_url: baseUrl, 
        auto_cleanup_word: true,
        entity_encoding: 'raw',
        file_browser_callback: 'filebrowse',
        trim_span_elements: true,
        remove_linebreaks: 'false',
        cleanup_on_startup: 'false',
        paste_strip_class_attributes: 'mso',
        paste_remove_spans: true,
        paste_convert_middot_lists: true,
        cleanup: 'true',
        extended_valid_elements: "+*:*[*],iframe[*],#td[*],tr[*],-ol[start|type|compact]",
        apply_source_formatting: 'true'
    });
        
});

/*
 * Custom file-browse dialog (XIMS file-browse-url)
 */
function filebrowse(field_name, url, type, win){
    if (type == "file") {
        var browseurl = brUrl + 'style=tinymcelink';
    }
    else {
        var browseurl = brUrl + 'style=tinymceimage&otfilter=Image';
    }
    
    tinyMCE.get('body').windowManager.open({
        file: browseurl,
        title: "XIMS File Browser",
        width: 600, // width of XIMS File Browser pop-up
        height: 400,
        resizable: "yes",
        scrollbars: "yes",
        inline: "yes", // This parameter only has an effect if you use the inlinepopups plugin!
        close_previous: "no"
    }, {
        window: win,
        input: field_name
    });

    return false;
}

