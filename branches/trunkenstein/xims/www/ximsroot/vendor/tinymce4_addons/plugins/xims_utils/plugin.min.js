/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */
	tinymce.PluginManager.add('xims_utils', function(editor) {
		var data, ns="http://www.w3.org/2001/XInclude";

	//parse span tags to xi:include tags to display in source view
		editor.on('PreProcess', function(e){
			return span2xi(editor);
		});
		
		//parse span tags to xi:include for saving
		editor.on('SaveContent', function(e){
			return xi2span(editor);
		});

		//parse xi:include back to span tags so editor can handle them
		editor.on('SetContent', function(e){
			return xi2span(editor);
		});
	  
		function span2xi(editor) {
			var elm;
			tinymce.each(editor.dom.select('span.xml_include'), function(n) {
				var title = editor.dom.getAttrib(n, 'title').split('#');
				var xi_href = title[0] || '';
				var xi_xp = title[1] || '';
				 xi_title = $(n).attr('title');
				if(xi_xp != ''){
	               elm = '<xi:include href="'+xi_href+'" xpointer="'+xi_xp+'" xmlns:xi="'+ns+'" ><xi:fallback>'+$(n).html()+'</xi:fallback></xi:include>';
				}
				else{
					elm = '<xi:include href="'+xi_href+'" xmlns:xi="'+ns+'" ><xi:fallback>'+$(n).html()+'</xi:fallback></xi:include>';
				}					
				$(n).parent().replaceWith(elm);
			});				
		}
		
		function xi2span(editor){
			var doc = editor.getDoc();
				$(doc).find('xi\\:include').each(function(index, element) {
					var n = element;
					var xp = '';
					if(editor.dom.getAttrib(n, 'xpointer')){ xp = '#' + editor.dom.getAttrib(n, 'xpointer')}
					var elm = '<p><span title="'+ $(n).attr('href') + xp + '" class="xml_include">'+$(n).text()+'</span></p>';
					$(n).replaceWith(elm);
				});
		}
	});
	