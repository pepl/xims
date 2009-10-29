/**
 * Copyright (c) 2002-2009 The XIMS Project.
 * See the file "LICENSE" for information and conditions for use, reproduction,
 * and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @author suse
 */


$().ready(function(){

    $("#body").tinymce({
		theme : 'advanced',
		plugins : 'table,contextmenu,advhr,searchreplace,inlinepopups',
		
		theme_advanced_buttons1_add_before: 'cut,copy,paste,separator,search,replace,separator',
        theme_advanced_buttons3_add_before : 'tablecontrols,separator',
		theme_advanced_toolbar_location : 'top',
        theme_advanced_toolbar_align : 'left',
        theme_advanced_path_location : 'bottom',
        theme_advanced_resizing : true,
        theme_advanced_resize_horizontal : false,
		
		language : lang,
		document_base_url : baseUrl,
		auto_cleanup_word : true,
    	mode : 'exact',
        elements : 'body',
        dialog_type : "modal",
        
        entity_encoding : 'raw',
       
        content_css :  css,                           
        file_browser_callback : 'filebrowse',
        remove_linebreaks : 'false',
        cleanup : 'true',
        cleanup_on_startup : 'false',
        apply_source_formatting : 'true'
    
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

