
      var storeBack = function(){
        var path = $('iframe', win.document).contents().find('#input-path').val();
                var title = $('iframe', win.document).contents().find('#input-title').val();
                var target;
                if($('iframe', win.document).contents().find('#input-target')){
                  target = $('iframe', win.document).contents().find('#input-target').val();
                }
                $('#'+field_name).val(path);
                //dirty but working by now (undocumented TinyMCE4 API)
                $('#'+field_name).parents('.mce-container-body').parent().find('input').last().val(title);
                //alert(win.parent.find('#xpointer'));

                //win.find('#xpointer').value('xpointer');
                if(target != ''){
                  $('#'+field_name).siblings('input').siblings('input').val(target);
                }

                tinyMCE.activeEditor.windowManager.close();
                //win.find('#xpointer')[0].value = 'xpointer';
      }

      
$().ready(function(){
  tinymce.init({
	    selector: "#body",
	    theme: "modern",
	    skin: "../../../../tinymce4_addons/skins/xims_lightgray",
	    language: 'de_AT',
	    document_base_url: baseUrl,
	    //editor appearance
	    width: 950,
	    max_width: 950,
	    resize: 'both',
	    //plugins
	    plugins: [
	  	       // "advlist autolink lists link image preview hr anchor",
	  	        "advlist autolink lists link anchor",
	  	        //"advlist autolink lists link image charmap preview hr anchor",
	  	        "searchreplace wordcount visualchars code fullscreen",
	  	        //"searchreplace wordcount visualblocks visualchars code fullscreen",
	  	        //"nonbreaking table contextmenu",
	  	        "nonbreaking contextmenu",
	  	        "template paste"
	  	        //"autosave"
	  	    ],
	    //menubar: false,
	  	  menu: { 
	          //file: {title: 'File', items: 'newdocument'}, 
	          edit: {title: 'Edit', items: 'undo redo | cut copy paste pastetext | selectall | searchreplace'}, 
	          insert: {title: 'Insert', items: 'anchor link unlink | advhr | image clearbr | charmap | template '}, //media insertdatetime
	          table: {title: 'Table', items: 'inserttable tableprops deletetable | cell row column'},
	          //view: {title: 'View', items: 'visualaid visualchars visualblocks | code | fullscreen'}, 	          
	          format: {title: 'Format', items: '| formats | removeformat | bold italic underline superscript subscript '}, 
	          view: {title: 'View', items: 'visualchars visualblocks | code | fullscreen'} 
	          //tools: {title: 'Tools'} 
	      },

	    toolbar1: "styleselect | formatselect | removeformat | bold italic underline superscript subscript | alignleft aligncenter alignright alignjustify | bullist numlist | outdent indent | indent2ndline outdent2ndline",
	    toolbar2: "anchor link unlink | nonbreaking | table | charmap faicons | advhr | galleryinclude image clearbr | xmlinclude | visualchars visualblocks | code | fullscreen", //| restoredraft | media | template
	   // toolbar3: "visualchars visualblocks | code | fullscreen",
	   // toolbar1: "cut copy paste pastetext search searchreplace | undo redo | anchor link unlink | galleryinclude advimage clearbr | alignleft aligncenter alignright alignjustify | bullist numlist | outdent indent | indent2ndline outdent2ndline",
	   // toolbar2: "styleselect | formatselect | removeformat | bold italic underline superscript subscript |",
	   // toolbar3: "",
	    content_css: 'https://www.uibk.ac.at/stylesheets/15/css/bs3grid.css,' +css + ',/ximsroot/vendor/font-awesome/css/font-awesome.min.css' + ',/ximsroot/vendor/open-sans/open-sans.css',
	    body_id: 'content',
	    element_format: 'xml',
	    external_plugins: {
	        "inoutdent2ndline": "../../../tinymce4_addons/plugins/inoutdent2ndline/plugin.js",
	        //"extraicons":       "../../../tinymce4_addons/plugins/extraicons/plugin.js",
	        "xmlinclude": "../../../tinymce4_addons/plugins/xmlinclude/plugin.js",
	        "galleryinclude": "../../../tinymce4_addons/plugins//galleryinclude/plugin.js",
	        "xims_utils": "../../../tinymce4_addons/plugins/xims_utils/plugin.js",
	        "codemirror": "../../../tinymce4_addons/plugins/codemirror/plugin.js",
	        //"advimage": "../../../tinymce4_addons/plugins/advimage/plugin.js",
	        "advhr": "../../../tinymce4_addons/plugins/advhr/plugin.js",
	        "media": "../../../tinymce4_addons/plugins/media/plugin.js",
	        "clearbr": "../../../tinymce4_addons/plugins/clearbr/plugin.js",
	        "visualblocks": "../../../tinymce4_addons/plugins/visualblocks/plugin.js",
	        "faicons":     "../../../tinymce4_addons/plugins/faicons/plugin.js",
	        "table":     "../../../tinymce4_addons/plugins/table/plugin.js",
	        "charmap":     "../../../tinymce4_addons/plugins/charmap/plugin.js",
	        "image":     "../../../tinymce4_addons/plugins/image/plugin.js"
	    },
	    //image_advtab: true,
	    visual: true,
	    //visualblocks_default_state: true,
	    end_container_on_empty_block: true,
	    object_resizing: 'img',
	    keep_styles: false,
	    insertdatetime_formats: ["%Y.%m.%d", "%H:%M"],
	    codemirror: {
	        indentOnInit: true, // Whether or not to indent code on init. 
	        //path: 'http://ximstest1.uibk.ac.at/ximsroot/editors/CodeMirror', // Path to CodeMirror distribution
	        //path: '../../../../CodeMirror', // Path to CodeMirror distribution
	        path: tinymceUrl + '/../../../../codemirror', // Path to CodeMirror distribution
	        config: {           // CodeMirror config object
	          lineNumbers: true,
	          mode: 'htmlmixed'
	        }
	    },
	    indentation : '10px',
	    image_advtab: true,
	    image_description: true,
	    image_title: true,
	    image_caption: true,
	    image_maxWidth: 900,
	    table_style_by_css: true,
	    //table_advtab: false,
	    link_class_list: [
	                    {title: '- keine -', value: ''},
						{title : 'Galerie Popup', value: 'gallery-opener'},
						{title : 'Ein-/ausblenden Link', value: 'link-ein'}//,
						//{title : 'Ein-/ausblenden Text', value: 'text-ein'}
					],
	    advlist_number_styles: "default,lower-alpha",
	    advlist_bullet_styles: "standard", 	    
	    entity_encoding: 'raw',
	    schema: "html5",
	    end_container_on_empty_block: true,
	    convert_fonts_to_spans : true,
	    //FF bug: anchors are removed otherwise when hitting "back" in the same line
	    allow_html_in_named_anchor: true,
	    remove_trailing_brs: false,
	    //element_format : "html"
	    extended_valid_elements: "#xi:include[*],#xi:fallback[*],@[xml::lang|class|id|style],multipage,+subpage[*],iframe[*],#td[*],tr[*],-ol[start|type|compact],br[class|clear<all?left?none?right],#span[class|title|style|lang],#uibk:lv-liste[*],i,#aside[*],#section[*]",
		custom_elements: 'xi:include,xi:fallback,uibk:lv-liste',
		/*protect: [
		          /\<\/?(if|endif)\>/g, // Protect <if> & </endif>
		          /\<xsl\:[^>]+\>/g, // Protect <xsl:...>
		          /<\?php.*?\?>/g // Protect php code
		      ],*/
		//video_template_callback: 'insertVideo',
	    templates: [
	        {title: 'Ein-/ausblenden', content: '<p><a class="link-ein" href="#">[Linktext]&nbsp;</a>&nbsp;</p><div class="text-ein"><p>[Inhalt]</p></div>'}
	       /* {title: 'Grid 50-50', content: '<div class="row row-content"><div class="col-xs-12 col-sm-6 col-md-6 col-lg-6"><p>[Inhalt]</p></div><div class="col-xs-12 col-sm-6 col-md-6 col-lg-6"><p>[Inhalt]</p></div></div>'},
	        {title: 'Grid 70-30', content: '<div class="row row-content"><div class="col-xs-12 col-sm-8 col-md-8 col-lg-8"><p>[Inhalt]</p></div><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><p>[Inhalt]</p></div></div>'},
	        {title: 'Grid 30-70', content: '<div class="row row-content"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><p>[Inhalt]</p></div><div class="col-xs-12 col-sm-8 col-md-8 col-lg-8"><p>[Inhalt]</p></div></div>'},*/
	    ],
	    block_formats : 'Paragraph=p;' +
		'Address=address;' +
		'Pre=pre;' +
		'Heading 1=h1;' +
		'Heading 2=h2;' +
		'Heading 3=h3;' +
		'Heading 4=h4;' +
		'Heading 5=h5;' +
		'Heading 6=h6;' +
		'Blockquote=blockquote;' +
		'div=div;' +		
		'aside=aside;' +
		'section=section',
	 // Style formats
	style_formats : [
        {title : 'Schriftfarbe rot', inline : 'span', classes: 'red'},
        {title : 'Schriftfarbe orange', inline : 'span', classes: 'orange'},
        {title : 'Schriftfarbe blau', inline : 'span', classes: 'blue'},
        //{title : 'Texthintergrund', inline : 'span', classes: 'highlighted'},
        {title : 'gro\u00DFe Schrift', inline : 'span', classes: 'big'},
        {title : 'kleine Schrift', inline : 'span', classes: 'small'},
        /*{title : 'Tabelleninhalt blau', selector : 'td,th', classes: 'table_blue'},
        {title : 'Tabelleninhalt hellblau', selector : 'td,th', classes: 'table_blue_light'},
        {title : 'Tabelleninhalt dunkelblau', selector : 'td,th', classes: 'table_blue_dark'},
        {title : 'Tabelleninhalt orange', selector : 'td,th', classes: 'table_orange'},
        {title : 'Tabelleninhalt hellorange', selector : 'td,th', classes: 'table_orange_light'},
        {title : 'Tabelleninhalt dunkelorange', selector : 'td,th', classes: 'table_orange_dark'},*/
        {title : 'Umrahmung blau', selector : 'p', classes: 'border_blue'},
        {title : 'Umrahmung orange', selector : 'p', classes: 'border_orange'},
        {title : 'Umrahmung schwarz', selector : 'p', classes: 'border_black'}
        /*{ title: 'aside', block: 'aside', wrapper: true },
        { title: 'section', block: 'section', wrapper: true, merge_siblings: false },*/
        /*{title : 'Liste MsWord', selector : 'li,ul', classes: 'wordlist'},
        {title : 'Liste MsExcel', selector : 'li,ul', classes: 'excellist'},
        {title : 'Liste MsPowerpoint', selector : 'li,ul', classes: 'pptlist'},
        {title : 'Liste PDF', selector : 'li,ul', classes: 'pdflist'},
        {title : 'Liste Image', selector : 'li,ul', classes: 'imagelist'},
        {title : 'Liste Document', selector : 'li,ul', classes: 'documentlist'},
        {title : 'Liste Intranet', selector : 'li,ul', classes: 'intranetlist'},
        {title : 'Liste Email', selector : 'li,ul', classes: 'emaillist'},
        {title : 'Liste Externer Link', selector : 'li,ul', classes: 'externallinklist'},*/
        /*{title : 'Galerie Popup', selector : 'a', classes: 'gallery-opener'},
        {title : 'Ein-/ausblenden Link', selector : 'a', classes: 'link-ein'},
        {title : 'Ein-/ausblenden Text', selector : 'div', classes: 'text-ein'}*/
  ],
  invalid_styles: 'font-size font-style color',

  file_picker_callback: function(callback, value, meta) {
      filePicker(callback, value, meta);
  },/*
	  file_browser_callback: function(field_name, url, type, win) { 
	  if (type == "file") {
	        var browseurl = brUrl + 'style=tinymcelink&tinymce_version=4';
	    }
	    else if (type == "gallery") {
	        var browseurl = brUrl + 'style=tinymcelink&otfilter=Gallery&tinymce_version=4';
	    }
	    else {
	        var browseurl = brUrl + 'style=tinymceimage&otfilter=Image&tinymce_version=4';
	    }
	  //console.log(browseurl);

	    tinyMCE.get('body').windowManager.open({
	        file: browseurl,
	        title: "XIMS File Browser",
	        width: 600, // width of XIMS File Browser pop-up
	        height: 400,
	        resizable: "yes",
	        scrollbars: "yes",
	        inline: 1,
	        //data: data,
	        classes: "ximsfilebrowser",
	        close_previous: "no",
	        buttons: [
	        {
	            text: 'Ok',
	            onclick: function(e){
	            	var path;
	            	if (type == "image") {path = $('iframe', win.document).contents().find('#input-image').val();}
	            	else { path = $('iframe', win.document).contents().find('#input-path').val();}
	            	var title = $('iframe', win.document).contents().find('#input-title').val();
	            	var target;
	            	if($('iframe', win.document).contents().find('#input-target')){
	            		target = $('iframe', win.document).contents().find('#input-target').val();
	            	}
	            	$('#'+field_name).val(path);
	            	//dirty but working by now (undocumented TinyMCE4 API)
	            	//$('#'+field_name).parents('.mce-container-body').parent().find('input').last().val(title);
	            	var fn_id = parseInt(field_name.replace("mceu_","").replace("-inp",""));
	            	var title_id = fn_id + 1;	
	            	
	            	var title_inp = "mceu_"+ (fn_id+2);
	            	if (type == "image"){
	            		var title_inp = "mceu_"+ (fn_id+1);
	            		var alt_inp = "mceu_"+ (fn_id+2);
	            	}
	            	//console.log("title inp : "+title_inp);
	            	//console.log("alt inp : "+alt_inp);
	            	$('#'+title_inp).val(title);
	            	if (type == "image"){$('#'+alt_inp).val(title);}
	            	var mywin = win;
	            	if(target != ''){
	            		$('#'+field_name).siblings('input').siblings('input').val(target);
	            	}
			        tinyMCE.activeEditor.windowManager.close();
			      }
	        },
	        {
	            text: 'Cancel',
	            onclick: 'close'
	        }
	        ],
	    }, {
	        window: win,
	        input: field_name
	    })

	    return false;
      },//end filebrowser callback
      */

      video_template_callback: function insertVideo(data){
	    	var html = '';
	    	html = (
					'<video class="media '+data.medialayout+'" width="' + data.width + '" height="' + data.height + '"' + (data.poster ? ' poster="' + data.poster + '"' : '') + ' controls="controls">\n' +
						'<source src="' + data.source1 + '"' + (data.source1mime ? ' type="' + data.source1mime + '"' : '') + ' />\n' +
						(data.source2 ? '<source src="' + data.source2 + '"' + (data.source2mime ? ' type="' + data.source2mime + '"' : '') + ' />\n' : '') +
					'</video>'
				);
	    	return html;
	    },
	    audio_template_callback: function insertVideo(data){
	    	var html = '';
	    	html = (
					'<audio class="media '+data.medialayout+'" width="' + data.width + '" height="' + data.height + '"' + (data.poster ? ' poster="' + data.poster + '"' : '') + ' controls="controls">\n' +
						'<source src="' + data.source1 + '"' + (data.source1mime ? ' type="' + data.source1mime + '"' : '') + ' />\n' +
						(data.source2 ? '<source src="' + data.source2 + '"' + (data.source2mime ? ' type="' + data.source2mime + '"' : '') + ' />\n' : '') +
					'</audio>'
				);
	    	return html;
	    }
	});
  
  function filePicker(callback, value, meta) {
	  if (meta.filetype == "file") {
	        var browseurl = brUrl + 'style=tinymcelink&tinymce_version=4';
	    }
	    else if (meta.filetype == "gallery") {
	        var browseurl = brUrl + 'style=tinymcelink&otfilter=Gallery&tinymce_version=4';
	    }
	    else {
	        var browseurl = brUrl + 'style=tinymceimage&otfilter=Image&tinymce_version=4';
	    }
	    
	    tinymce.activeEditor.windowManager.open({
	        file: browseurl,
	        title: "XIMS File Browser",
	        width: 600, // width of XIMS File Browser pop-up
	        height: 400,
	        resizable: "yes",
	        scrollbars: "yes",
	        inline: 1,
	        //data: data,
	        classes: "ximsfilebrowser",
	        close_previous: "no",
	        buttons: [
	        {
	            text: 'Ok',
	            onclick: function(e){
	            	
	            	//callback('mypage.html', {alt: 'My alt', title: 'my title'});
	            	var win = tinymce.activeEditor.windowManager.getWindows()[1];
	            	var path;
	            	//console.log(tinymce.activeEditor.windowManager.getWindows()[1].find('#input-image').value() +" --- "+ tinymce.activeEditor.windowManager.getWindows()[1].find('#input-path').value());
	            	if (meta.filetype == "image") {
	            		path = $('iframe', win.document).contents().find('#input-image').val();
	            		}
	            	else { 
	            		path = $('iframe', win.document).contents().find('#input-path').val();
	            		}
	            	var title = $('iframe', win.document).contents().find('#input-title').val();
	            	//var target;
	            	/*if($('#input-target')){
	            		target = $('#input-target').val();
	            	}*/
	            	callback(path, {alt: title, title: title});
	            	tinyMCE.activeEditor.windowManager.close();
			      }
	        },
	        {
	            text: 'Cancel',
	            onclick: 'close'
	        }
	        ],
	    }, {
	        oninsert: function (url, objVals) {
	            callback(url, objVals);
	        }
	    });
	};
  



/*
 * Custom file-browse dialog (XIMS file-browse-url)
 */
  /*
function filebrowse(field_name, url, type, win){
	alert("browse");
    win.document.getElementById(field_name).value = 'my browser value'; 
    /*if (type == "file") {
        var browseurl = brUrl + 'style=tinymcelink';
    }
    else if (type == "gallery") {
        var browseurl = brUrl + 'style=tinymcelink&otfilter=Gallery';
    }
    else {
        var browseurl = brUrl + 'style=tinymceimage&otfilter=Image';
    }

    tinyMCE.get('body').windowManager.open({
        //file: browseurl,
        url: browseurl,
        title: "XIMS File Browser",
        width: 600, // width of XIMS File Browser pop-up
        height: 400,
        resizable: "yes",
        scrollbars: "yes",
        inline: "yes", // This parameter only has an effect if you use the inlinepopups plugin!
        close_previous: "no",
        buttons: [{
            text: 'Close',
            onclick: 'close'
        }]
    }, {
        window: win,
        input: field_name
    });

    return false;
}*/
});
//}


