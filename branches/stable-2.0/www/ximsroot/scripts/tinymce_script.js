/**
 * Copyright (c) 2002-2011 The XIMS Project.
 * See the file "LICENSE" for information and conditions for use, reproduction,
 * and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @author Susanne Tober
 */


$().ready(function(){

    $("#body").tinymce({
    
        // General options
		theme: "advanced",
        plugins: 'table,contextmenu,advhr,searchreplace,inlinepopups,safari,xhtmlxtras,paste,advimage',
        // Theme options
        theme_advanced_buttons1: 'cut,copy,paste,pastetext,pasteword,search,replace,separator,undo,redo,separator,anchor,link,unlink,separator,'+
			'image,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,numlist,bullist,outdent,indent,blockquote,separator,visualaid,code,help',
        theme_advanced_buttons2: 'styleselect,formatselect,removeformat,cleanup,separator,bold,italic,underline,separator,sup,sub,separator,charmap,separator,advhr,separator,',
        theme_advanced_buttons3: 'table,row_props,cell_props,row_before,row_after,delete_row,col_before,col_after,delete_col,split_cells,merge_cells,separator,cite,abbr,acronym',
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left",
        theme_advanced_statusbar_location: "bottom",
        theme_advanced_path_location: 'bottom',
        theme_advanced_resizing: true,
        theme_advanced_resize_horizontal: false,		
		language: lang, 

		//Cleanup / output
		cleanup: 'true',
		doctype : '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
		inline_styles : true,
        entity_encoding: 'raw',
		remove_linebreaks: 'false',
        cleanup_on_startup: 'false',
		extended_valid_elements: "+*:*[*],+lv-liste[*],multipage,+subpage[*],iframe[*],#td[*],tr[*],-ol[start|type|compact],br[clear<all?left?none?right]",
		invalid_elements: "st*:*", //remove word's smarttags 
		//onBeforeSetContent: 'addTraingP',
		
		//URL
        convert_urls : false,
        document_base_url: baseUrl, 
		
		//Callbacks
        file_browser_callback: 'filebrowse',

		//Layout
		body_id : "content", //change body-id, so uibk-css-file can be applied		
		content_css: css
		
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

