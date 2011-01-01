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
		skin: "uibk",
        plugins: 'table,contextmenu,advhr,searchreplace,inlinepopups,safari,xhtmlxtras,paste,advimage,clearbr,uibkextras,caption,inoutdent2ndline',
        // Theme options
        theme_advanced_buttons1: 'cut,copy,paste,pastetext,pasteword,search,replace,separator,undo,redo,separator,anchor,link,unlink,separator,'+
			'image,clearbr,caption,separator,justifyleft,justifycenter,justifyright,justifyfull,indent2ndline,outdent2ndline,separator,numlist,bullist,outdent,indent,blockquote,separator,visualaid,code,help',
        theme_advanced_buttons2: 'styleselect,formatselect,removeformat,cleanup,separator,bold,italic,underline,separator,sup,sub,separator,charmap,separator,advhr,separator,'+
			'uibkextras_New,uibkextras_ArrowBlack,uibkextras_ArrowOrange,uibkextras_MsWord,uibkextras_MsExcel,uibkextras_MsPPT,uibkextras_PDF,uibkextras_Image,uibkextras_Document,uibkextras_Intranet,uibkextras_Email,uibkextras_ExternalLink',
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
		content_css: 'http://cabal.uibk.ac.at/stylesheets/css/10/formats.css',
		
		//Plugins
        uibkextras_ressourceUrl: 'https://www.uibk.ac.at/images/10/icons/',
        uibkextras_iconNames: 'ArrowBlack=list_arrowblack.gif,ArrowOrange=list_arroworange.gif,New=list_new.gif,MsWord=list_word.gif,MsExcel=list_excel.gif,MsPPT=list_ppt.gif,Document=list_document_generic.gif,EMail=list_email.gif,PDF=list_pdf.gif,Folder=list_folder.gif,Image=list_png.gif,Email=list_email.gif,Intranet=list_intranet.gif,ExternalLink=externallink.gif',
		formats: {
			'indent2ndline': [
				{selector : 'p', attributes : {'class' : 'indent'}}
				],
			'outdent2ndline': [
				{selector : 'p', attributes : {'class' : 'outdent'}}
				]
			},
		// Style formats
		style_formats : [
			{title : 'Schriftfarbe rot', inline : 'span', classes: 'red'},
			{title : 'Schriftfarbe orange', inline : 'span', classes: 'orange'},
			{title : 'Schriftfarbe blau', inline : 'span', classes: 'blue'},
			{title : 'Texthintergrund', inline : 'span', classes: 'highlighted'},
			{title : 'große Schrift', inline : 'span', classes: 'big'},
			{title : 'kleine Schrift', inline : 'span', classes: 'small'},
			{title : 'Tabelleninhalt blau', inline : 'td', classes: 'table_blue'},
			{title : 'Tabelleninhalt hellblau', selector : 'td', classes: 'table_blue_light'},
			{title : 'Tabelleninhalt dunkelblau', selector : 'td', classes: 'table_blue_dark'},
			{title : 'Tabelleninhalt orange', selector : 'td', classes: 'table_orange'},
			{title : 'Tabelleninhalt hellorange', selector : 'td', classes: 'table_orange_light'},
			{title : 'Tabelleninhalt dunkelorange', selector : 'td', classes: 'table_orange_dark'},
			{title : 'Umrahmung blau', selector : 'p', classes: 'border_blue'},
			{title : 'Umrahmung orange', selector : 'p', classes: 'border_orange'},
			{title : 'Umrahmung schwarz', selector : 'p', classes: 'border_black'},		
			{title : 'Liste MsWord', selector : 'li', classes: 'wordlist'},
			{title : 'Liste MsExcel', selector : 'li', classes: 'excellist'},
			{title : 'Liste MsPowerpoint', selector : 'li', classes: 'pptlist'},
			{title : 'Liste PDF', selector : 'li', classes: 'pdflist'},
			{title : 'Liste Image', selector : 'li', classes: 'imagelist'},
			{title : 'Liste Document', selector : 'li', classes: 'documentlist'},
			{title : 'Liste Intranet', selector : 'li', classes: 'intranetlist'},
			{title : 'Liste Email', selector : 'li', classes: 'emaillist'},
			{title : 'Liste Externer Link', selector : 'li', classes: 'externallinklist'}		
		]
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

