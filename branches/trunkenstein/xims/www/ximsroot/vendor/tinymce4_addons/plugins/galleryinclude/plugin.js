/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

(function(tinymce) {

	tinymce.PluginManager.requireLangPack('galleryinclude');
	
	tinymce.PluginManager.add('galleryinclude', function(editor, url) {
		var initialText = "-[Gallery]-", ns="http://www.w3.org/2001/XInclude";
		function showDialog() {
			var data = {}, selection = editor.selection, dom = editor.dom, selectedElm, xiElm;
			
			var win;

			// Focus the editor since selection is lost on WebKit in inline mode
			editor.focus();

			selectedElm = selection.getNode();
			xiElm = dom.is(selectedElm, 'span.xml_include') ? selectedElm : null; 
			if (xiElm) {
				selection.select(xiElm);
			}
			
			data.text = selection.getContent({format: 'text'}).replace(/(\r\n|\n|\r)/gm,"");			
			if(data.text == '')
				data.text = initialText;
			var spantitle = xiElm ? dom.getAttrib(xiElm, 'title').split('#') : '';
			data.href = xiElm ? dom.getAttrib(xiElm, 'title').split('#')[0] : '';
			
			var generalFormItems = [
				{type: 'label', 
			        multiline: true,
			        maxWidth: 500,
			        minHeight: 100,
			        text: 'To embed a Gallery simply type in the URL to the Gallery or browse for a local Gallery object. Set a fallback text which serves as placeholder in the editor/for the link. You can modify or delete your entry at any time.'
			    },
				{name: 'href', classes: 'xmlpath', size: 35,  type: 'filepicker', filetype: 'file', label: 'URL of XML file', autofocus: true},
				{name: 'text', type: 'textbox', size: 40, label: 'Fallback text', onchange: function() {
					data.text = this.value();
				}}
			];

			win = editor.windowManager.open({
				title: 'Insert XIMS Gallery',
				data: data,
				body: generalFormItems,
				onSubmit: function(e) {
					var data = e.data, href = data.href;

					// Delay confirm since onSubmit will move focus
					function delayedConfirm(message, callback) {
						window.setTimeout(function() {
							editor.windowManager.confirm(message, callback);
						}, 0);
					}

					function insertXi() {
						if (xiElm) {
							editor.focus();
							xiElm.innerHTML = data.text;
							dom.setAttribs(xiElm, {
								title: data.href,//+'#'+data.xpointer,
								'class': 'xml_include'
							});

							selection.select(xiElm);
						} 
						else {
							editor.focus();
							editor.insertContent(dom.createHTML('span', {
								title: data.href,
								'class': 'xml_include'
							}, data.text));
						}
					}
					// Is www. prefixed
					if (/^\s*www\./i.test(href)) {
						delayedConfirm(
							'The URL you entered seems to be an external link. Do you want to add the required http:// prefix?',
							function(state) {
								if (state) {
									href = 'http://' + href;
								}

								insertXi();
							}
						);

						return;
					}

					insertXi();
				}
			});
		}
		
		
		// Register  buttons
		editor.addButton('galleryinclude', {
			tooltip : 'Insert Gallery',
			icon: 'images', 
			//icon: true,
			//image: url + '/img/gallery.png',
			onclick: showDialog,
			stateSelector: 'xi\\:fallback,xi\\:include,span.xml_include'
		});
		
	});
})(tinymce);