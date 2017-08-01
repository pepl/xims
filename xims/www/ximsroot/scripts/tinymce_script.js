/**
 * Copyright (c) 2002-2017 The XIMS Project.
 * See the file "LICENSE" for information and conditions for use, reproduction,
 * and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @author Susanne Tober
 */

$().ready(function(){

    $("#body").tinymce({

        // General options
        doctype : '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
        theme: "advanced",
        skin: "xims",
        //we need the lists plugin to fix some problems with lists
        plugins: 'table,contextmenu,lists,advlist,searchreplace,inlinepopups,xhtmlxtras,paste'+
        ',advhr_xims,advimage_xims,clearbr,ximsextras,caption,inoutdent2ndline'+ 
        ',hiddenchars,codemirror,setlang,visualblocks,trailing,xmlinclude,galleryinclude',
        // Theme options
        theme_advanced_buttons1: 'cut,copy,paste,pastetext,pasteword,search,replace,separator,undo,redo,separator,anchor,link,unlink,separator'+
        ',image,clearbr,caption,galleryinclude,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,numlist,bullist,outdent,indent,blockquote,'+
		'indent2ndline,outdent2ndline,separator,codemirror',
        theme_advanced_buttons2: 'styleselect,formatselect,removeformat,cleanup,separator,bold,italic,underline,separator,sup,sub,separator,xlink,setlang,separator,visualaid,visualblocks,hiddenchars',
        theme_advanced_buttons3: 'table,row_props,cell_props,row_before,row_after,delete_row,col_before,col_after,delete_col,split_cells,merge_cells,separator,cite,abbr,acronym,separator,charmap,separator,advhr,separator,ximsextras_New,ximsextras_ArrowBlack,ximsextras_ArrowOrange,ximsextras_MsWord,ximsextras_MsExcel,ximsextras_MsPPT,ximsextras_PDF,ximsextras_Image,ximsextras_Document,ximsextras_Intranet,ximsextras_Email,ximsextras_ExternalLink,help',
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left",
        theme_advanced_statusbar_location: "bottom",
        theme_advanced_path_location: 'bottom',
        theme_advanced_resizing: true,
        theme_advanced_resize_horizontal: false,
        theme_advanced_styles : "Embed into text (no link)=xml_embed;Open in current window=xml_replace;Open in new window=xml_new;Galerie Popup=gallery-opener",
        strict_loading_mode : true,
        button_tile_map: true,
        relative_urls: true,
        language: lang,
        document_base_url: baseUrl,
        element_format: 'xhtml',
        inline_styles : true,
        entity_encoding: 'raw',
        urlconverter_callback : 'urlconverter',
        file_browser_callback: 'filebrowse',
        galleryinclude_file_browser_callback: 'galleryinclude_file_browser',
        oninit : 'setImgDims',
        remove_linebreaks: false,
        //there is a bug in the wrapper. if we enable p-wrapping empty xi:include-Tags will be removed 
        //forced_root_block : false,
        forced_root_block : 'p',
        //undocumented option, see http://www.tinymce.com/forum/viewtopic.php?pid=100089
        remove_trailing_brs: false,
        paste_text_use_dialog: true,
        paste_preprocess: 'convertWordBefore',
        paste_postprocess: 'convertWordAfter',
        extended_valid_elements: "#xi:include[*],#xi:fallback[*],@[xml::lang|class|id|style],multipage,+subpage[*],iframe[*],#td[*],tr[*],-ol[start|type|compact],br[class|clear<all?left?none?right],#span[class|title|style|lang],video[*],audio[*],source[*]",
        custom_elements: 'xi:include,xi:fallback',
        invalid_elements: "st*:*", //remove word's smarttags
        body_id : "content", //change body-id, so custom css-file can be applied
        content_css: css, 

        table_styles: 'Schriftfarbe rot=red;Schriftfarbe orange=orange;Schriftfarbe blau=blue;Texthintergrund=highlighted;gro\u00DFe Schrift=big;kleine Schrift=small;Tabelleninhalt blau=table_blue;Tabelleninhalt hellblau=table_blue_light;Tabelleninhalt dunkelblau=table_blue_dark;Tabelleninhalt orange=table_orange;Tabelleninhalt hellorange=table_orange_light;Tabelleninhalt dunkelorange=table_orange_dark',
        table_cell_styles: 'Schriftfarbe rot=red;Schriftfarbe orange=orange;Schriftfarbe blau=blue;Texthintergrund=highlighted;gro\u00DFe Schrift=big;kleine Schrift=small;Tabelleninhalt blau=table_blue;Tabelleninhalt hellblau=table_blue_light;Tabelleninhalt dunkelblau=table_blue_dark;Tabelleninhalt orange=table_orange;Tabelleninhalt hellorange=table_orange_light;Tabelleninhalt dunkelorange=table_orange_dark',
        table_row_styles: 'Schriftfarbe rot=red;Schriftfarbe orange=orange;Schriftfarbe blau=blue;Texthintergrund=highlighted;gro\u00DFe Schrift=big;kleine Schrift=small;Tabelleninhalt blau=table_blue;Tabelleninhalt hellblau=table_blue_light;Tabelleninhalt dunkelblau=table_blue_dark;Tabelleninhalt orange=table_orange;Tabelleninhalt hellorange=table_orange_light;Tabelleninhalt dunkelorange=table_orange_dark',
        advlist_number_styles: [
                {title : 'Standard', styles : {listStyleType : ''}},
                {title : 'a. b. c.', styles : {listStyleType : 'lower-alpha'}}
                ],
        advlist_bullet_styles: [
                {title : 'Standard', styles : {listStyleType : ''}}
                ],
        ximsextras_iconNames: 'ArrowBlack=list_arrowblack.gif,ArrowOrange=list_arroworange.gif,New=list_new.gif,MsWord=list_word.gif,MsExcel=list_excel.gif,MsPPT=list_ppt.gif,Document=list_document_generic.gif,EMail=list_email.gif,PDF=list_pdf.gif,Folder=list_folder.gif,Image=list_png.gif,Email=list_email.gif,Intranet=list_intranet.gif,ExternalLink=externallink.gif',
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
{                       title : 'Schriftfarbe rot', inline : 'span', classes: 'red'},
                        {title : 'Schriftfarbe orange', inline : 'span', classes: 'orange'},
                        {title : 'Schriftfarbe blau', inline : 'span', classes: 'blue'},
                        {title : 'Texthintergrund', inline : 'span', classes: 'highlighted'},
                        {title : 'gro\u00DFe Schrift', inline : 'span', classes: 'big'},
                        {title : 'kleine Schrift', inline : 'span', classes: 'small'},
                        {title : 'Tabelleninhalt blau', selector : 'td,th', classes: 'table_blue'},
                        {title : 'Tabelleninhalt hellblau', selector : 'td,th', classes: 'table_blue_light'},
                        {title : 'Tabelleninhalt dunkelblau', selector : 'td,th', classes: 'table_blue_dark'},
                        {title : 'Tabelleninhalt orange', selector : 'td,th', classes: 'table_orange'},
                        {title : 'Tabelleninhalt hellorange', selector : 'td,th', classes: 'table_orange_light'},
                        {title : 'Tabelleninhalt dunkelorange', selector : 'td,th', classes: 'table_orange_dark'},
                        {title : 'Umrahmung blau', selector : 'p', classes: 'border_blue'},
                        {title : 'Umrahmung orange', selector : 'p', classes: 'border_orange'},
                        {title : 'Umrahmung schwarz', selector : 'p', classes: 'border_black'},
                        {title : 'Liste MsWord', selector : 'li,ul', classes: 'wordlist'},
                        {title : 'Liste MsExcel', selector : 'li,ul', classes: 'excellist'},
                        {title : 'Liste MsPowerpoint', selector : 'li,ul', classes: 'pptlist'},
                        {title : 'Liste PDF', selector : 'li,ul', classes: 'pdflist'},
                        {title : 'Liste Image', selector : 'li,ul', classes: 'imagelist'},
                        {title : 'Liste Document', selector : 'li,ul', classes: 'documentlist'},
                        {title : 'Liste Intranet', selector : 'li,ul', classes: 'intranetlist'},
                        {title : 'Liste Email', selector : 'li,ul', classes: 'emaillist'},
                        {title : 'Liste Externer Link', selector : 'li,ul', classes: 'externallinklist'}]

    });

});

/*
 * Custom URL-Conversion
 */	
function urlconverter (u, n, e){
	var isGP = false;
	if (u.indexOf('gopublic') != -1) {
		isGP = true;
	}
	var t = tinyMCE.activeEditor, s = t.settings;
			// Don't convert link href since thats the CSS files that gets loaded into the editor also skip local file URLs
			if (!s.convert_urls || (e && e.nodeName == 'LINK') || u.indexOf('file:') === 0)
				return u;

			// Convert to relative
			if (s.relative_urls) {
				
				if (isGP){
					return u;
				}
				
				return t.documentBaseURI.toRelative(u);
			}
			// Convert to absolute
			u = t.documentBaseURI.toAbsolute(u, s.remove_script_host);

			return u;
}

/*
 * Custom file-browse dialog (XIMS file-browse-url)
 */
function filebrowse(field_name, url, type, win){
    var browseurl;
    if (type == "file") {
        browseurl = brUrl + 'style=tinymcelink';
    }
    else if (type == "gallery") {
        browseurl = brUrl + 'style=tinymcelink&otfilter=Gallery';
    }
    else {
        browseurl = brUrl + 'style=tinymceimage&otfilter=Image';
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

function convertWordBefore(pl, o){
    // Gets executed before the built in logic performes it's cleanups
    o.content = o.content.replace(/<span style="font-variant: small-caps;">/gi, '<span class="small-caps">');

    // eliminate abs. path from IE footnote create
    // add name=... (bug in paste-plugin from new tinymce-version)
    var regEx = new RegExp("", "gi");
    regEx = /href=".*?#_ftn(\d{1,4})/gi;
    //o.content = o.content.replace(regEx, 'href="#_ftn$1');
    o.content = o.content.replace(regEx, 'name="_ftnref$1" href="#_ftn$1');

    regEx = /href=".*?#_ftnref(\d{1,4})/gi;
    o.content = o.content.replace(regEx, 'name="_ftn$1" href="#_ftnref$1');
    return o.content;
}

function convertWordAfter(pl, o){
    // Gets executed after the built in logic performes it's cleanups

    //content = content.replace(/&lt;\/?meta[^>]*\/?> ">/gi, '');
    //content = content.replace(/&lt;\/?link[^>]*\/?> ">/gi, '');
    //content = content.replace(/&lt;!--.+-->">/gi, '');

    // Fnt Problem bei Paste mit IE
    o.content = o.content.replace(/https?:\/\/xims.uibk.ac.at\/ximsroot\/tinymce\/jscripts\/tiny_mce\/plugins\/paste\/blank.htm/gi, '');
    return o.content;
}

function galleryinclude_file_browser(){
//alert("callback");
}

function setImgDims(){
	root = $(tinyMCE.activeEditor.dom.getRoot());
	var mybody = $(tinyMCE.activeEditor.dom.getRoot()).html();
	var imgArr = tinyMCE.activeEditor.dom.select('img');
	for(key in imgArr){
	$(imgArr[key]).load(function(){
		tinyMCE.activeEditor.dom.setAttrib(imgArr[key], 'width',imgArr[key].width);
		tinyMCE.activeEditor.dom.setAttrib(imgArr[key], 'height',imgArr[key].height);
	});
	}
	//padd xi:include
	var xiArr = tinyMCE.activeEditor.dom.select('xi:include');
	for (key in xiArr) {
		//alert("xi:include");
		if(tinyMCE.activeEditor.dom.isEmpty(xiArr[key])){
			//alert("empty xi:include");
			tinyMCE.activeEditor.dom.add(xiArr[key], '&#160;');
		}
	}
}


