
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
	    /*plugins: [
	        "lists link image charmap hr anchor",
	        "code",
	        "table contextmenu",
	        "paste"
	    ],*/
	    plugins: [
	  	        "advlist autolink lists link image charmap preview hr anchor",
	  	        "searchreplace wordcount visualchars code fullscreen",
	  	        //"searchreplace wordcount visualblocks visualchars code fullscreen",
	  	        "nonbreaking table contextmenu",
	  	        "template paste "
	  	    ],
	    //menubar: false,
	  	  menu: { 
	          //file: {title: 'File', items: 'newdocument'}, 
	          edit: {title: 'Edit', items: 'undo redo | cut copy paste pastetext | selectall | searchreplace'}, 
	          insert: {title: 'Insert', items: 'advimage clearbr | media | charmap extraicons'}, //insertdatetime
	          //view: {title: 'View', items: 'visualaid visualchars visualblocks | code | fullscreen'}, 
	          view: {title: 'View', items: 'visualchars visualblocks | code | fullscreen'}, 
	          format: {title: 'Format', items: 'bold italic underline superscript subscript | formats | removeformat'}, 
	          table: {title: 'Table'}, 
	          //tools: {title: 'Tools'} 
	      },

	    toolbar1: "styleselect | formatselect | removeformat | bold italic underline superscript subscript | alignleft aligncenter alignright alignjustify | bullist numlist | outdent indent | indent2ndline outdent2ndline",
	    toolbar2: "anchor link unlink | nonbreaking | table | charmap extraicons | advhr | galleryinclude advimage clearbr | xmlinclude | media | visualchars visualblocks | code | fullscreen",
	   // toolbar3: "visualchars visualblocks | code | fullscreen",
	    content_css: 'https://www.uibk.ac.at/stylesheets/12/css/formats.css',
	    body_id: 'content',
	    element_format: 'xml',
	    external_plugins: {
	        "inoutdent2ndline": "../../../tinymce4_addons/plugins/inoutdent2ndline/plugin.js",
	        "extraicons":       "../../../tinymce4_addons/plugins/extraicons/plugin.js",
	        "xmlinclude": "../../../tinymce4_addons/plugins/xmlinclude/plugin.js",
	        "galleryinclude": "../../../tinymce4_addons/plugins//galleryinclude/plugin.js",
	        "xims_utils": "../../../tinymce4_addons/plugins/xims_utils/plugin.js",
	        "codemirror": "../../../tinymce4_addons/plugins/codemirror/plugin.js",
	        "advimage": "../../../tinymce4_addons/plugins/advimage/plugin.js",
	        "advhr": "../../../tinymce4_addons/plugins/advhr/plugin.js",
	        "media": "../../../tinymce4_addons/plugins/media/plugin.js",
	        "clearbr": "../../../tinymce4_addons/plugins/clearbr/plugin.js",
	        "visualblocks": "../../../tinymce4_addons/plugins/visualblocks/plugin.js",
	    },
	    image_advtab: true,
	    visual: true,
	    visualblocks_default_state: true,
	    end_container_on_empty_block: true,
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
	    table: {
	    	cssclasses: {
	    		
	    	}
	    },
	    advlist_number_styles: "default,lower-alpha",
	    advlist_bullet_styles: "standard", 	    
	    /*link_list: [
	                {title: 'My page 1', value: 'http://www.tinymce.com'},
	                {title: 'My page 2', value: 'http://www.moxiecode.com'}
	            ],*/
	    entity_encoding: 'raw',
	    schema: "html5",
	    //element_format : "html"
	    extended_valid_elements: "#xi:include[*],#xi:fallback[*],@[xml::lang|class|id|style],multipage,+subpage[*],iframe[*],#td[*],tr[*],-ol[start|type|compact],br[class|clear<all?left?none?right],#span[class|title|style|lang],#uibk:lv-liste[*]",
		custom_elements: 'xi:include,xi:fallback,uibk:lv-liste',
		/*protect: [
		          /\<\/?(if|endif)\>/g, // Protect <if> & </endif>
		          /\<xsl\:[^>]+\>/g, // Protect <xsl:...>
		          /<\?php.*?\?>/g // Protect php code
		      ],*/
		//video_template_callback: 'insertVideo',
	    templates: [
	        {title: 'Test template 1', content: 'Test 1'},
	        {title: 'Test template 2', content: 'Test 2'}
	    ],
	    formats: {
	        alignleft: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', classes: 'left'},
	        aligncenter: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', classes: 'center'},
	        alignright: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', classes: 'right'},
	        alignfull: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', classes: 'full'},
	        bold: {inline: 'strong'},
	        italic: {inline: 'em'},
	        underline: {inline: 'span', 'classes': 'underline', exact: true},
	        strikethrough: {inline: 'del'},
	        customformat: {inline: 'span', styles: {color: '#00ff00', fontSize: '20px'}, attributes: {title: 'My custom format'}}
	    },
	 // Style formats
	style_formats : [
	  /*{title: 'Headers', items: [
	    {title: 'h1', block: 'h1'},
	    {title: 'h2', block: 'h2'},
	  	{title: 'h3', block: 'h3'},
	  	{title: 'h4', block: 'h4'},
		{title: 'h5', block: 'h5'},
		{title: 'h6', block: 'h6'}
	  ]},*/
	  
      {title: 'Custom', items: [
        {title : 'Schriftfarbe rot', inline : 'span', classes: 'red'},
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
        {title : 'Liste Externer Link', selector : 'li,ul', classes: 'externallinklist'}
      ]},
      {title: 'Blocks', items: [
	    //{title: 'Absatz', block: 'p'},
        {title: 'div', block: 'div'},
        {title: 'pre', block: 'pre'},
        {title: 'blockquote', block: 'blockquote', wrapper: true},
        {title: 'aside', block: 'aside', wrapper: true},
        {title: 'section', block: 'section', wrapper: true, merge_siblings: false}
      ]},
      /*
      {title: 'Containers', items: [
        {title: 'section', block: 'section', wrapper: true, merge_siblings: false},
        //{title: 'article', block: 'article', wrapper: true, merge_siblings: false},
        {title: 'blockquote', block: 'blockquote', wrapper: true},
        //{title: 'hgroup', block: 'hgroup', wrapper: true},
        {title: 'aside', block: 'aside', wrapper: true},
        //{title: 'figure', block: 'figure', wrapper: true}
       ]}*/

  ],
  file_browser_callback: function(field_name, url, type, win) { 
	  if (type == "file") {
	        var browseurl = brUrl + 'style=tinymcelink';
	    }
	    else if (type == "gallery") {
	        var browseurl = brUrl + 'style=tinymcelink&otfilter=Gallery';
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
	        inline: 1,
	        //data: data,
	        classes: "ximsfilebrowser",
	        close_previous: "no",
	        buttons: [{
	            text: 'Close',
	            onclick: 'close'
	        },
	        {
	            text: 'Store Back',
	            onclick: function(e){
	            	var path = $('iframe', win.document).contents().find('#input-image').val();
	            	var title = $('iframe', win.document).contents().find('#input-title').val();
	            	var target;
	            	if($('iframe', win.document).contents().find('#input-target')){
	            		target = $('iframe', win.document).contents().find('#input-target').val();
	            	}
	            	$('#'+field_name).val(path);
	            	//dirty but working by now (undocumented TinyMCE4 API)
	            	//$('#'+field_name).parents('.mce-container-body').parent().find('input').last().val(title);
	            	var fn_id = parseInt(field_name.replace("mce_","").replace("-inp",""));
	            	var title_id = fn_id + 1;
	            	var title_inp = "mce_"+ (fn_id+1);
	            	//alert(fn_id+", "+title_id+", "+title_inp);
	            	alert(path+", "+title);
	            	$('#'+title_inp).val(title);
	            	var mywin = win;
	            	if(target != ''){
	            		$('#'+field_name).siblings('input').siblings('input').val(target);
	            	}
			        tinyMCE.activeEditor.windowManager.close();
			      }
	        }],
	    }, {
	        window: win,
	        input: field_name
	    });

	    return false;
                                                          			//alert("browse");
                                                          	        //win.document.getElementById(field_name).value = 'my browser value'; 
      },//end filebrowser callback

      video_template_callback: function insertVideo(data){
	    	var html = '';
	    	html = (
					'<video class="media '+data.medialayout+'" width="' + data.width + '" height="' + data.height + '"' + (data.poster ? ' poster="' + data.poster + '"' : '') + ' controls="controls">\n' +
						'<source src="' + data.source1 + '"' + (data.source1mime ? ' type="' + data.source1mime + '"' : '') + ' />\n' +
						(data.source2 ? '<source src="' + data.source2 + '"' + (data.source2mime ? ' type="' + data.source2mime + '"' : '') + ' />\n' : '') +
					'</video>'
				);
	    	/*html = '<div class="media '+data.medialayout+'"><a href="javascript:openVideoDlg('+data.source1+','+data.source2+')">'+
	    		'<img src="'+data.poster+'" alt="" width="'+data.width+'" height="'+data.height+'" />'+
	    		'</a>'+
	    		'</div>'+
	    		'<div id="video-dialog"><div id="video-container">Loading the player ...</div></div>'+
	    		'<script type="text/javascript" src="www.uibk.ac.at/scripts/jwplayer/jwplayer.js">// <![CDATA[// ]]></script>'+
'<script type="text/javascript">// <![CDATA['+
'$(function() {     if(typeof jwplayer!="undefined"){       jwplayer("video-container").setup({         autostart: false,         file: data.source1,         modes: [             { type: "html5" },             { type: "flash", src: "/scripts/jwplayer/jwplayer.flash.swf" }         ]       });   	} '+  
    '$("#video-dialog").dialog({       autoOpen: false,       modal: true,       width: $("#video-dialog").children().first().width() + 40,       height: $("#video-dialog").children().first().height() + 65,       open: function(){         jwplayer("video-container").pause(false);       },       close: function(){         jwplayer("video-container").pause(true);       } 	}); });'+
  'function openVideoDlg(){     $("#video-dialog").dialog( "open" );   }'+
'// ]]></script>'; */
	    	return html;
	    }
	});
  



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


