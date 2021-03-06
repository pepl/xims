/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

(function(tinymce) {

	tinymce.PluginManager.requireLangPack('xmlinclude');
	
	tinymce.PluginManager.add('xmlinclude', function(editor, url) {
		
		function showDialog() {
			var data = {}, selection = editor.selection, dom = editor.dom, selectedElm, xiElm;
			var initialText = "-[XML-Dokument]-", ns="http://www.w3.org/2001/XInclude";
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
			data.xpointer = xiElm ? dom.getAttrib(xiElm, 'title').split('#')[1] : '';
			
			var generalFormItems = [
				{
					type: 'label', 
			        multiline: true,
			        maxWidth: 500,
			        minHeight: 100,
					text: 'To embed or link to an XML document simply type in the URL to the XML file or browse for a local XML document and optionally add a xPointer expression. Optionally set a fallback text which serves as placeholder in the editor/for the link. You can modify or delete your entry at any time.'
				},
				{name: 'href', classes: 'xmlpath', size: 35,  type: 'filepicker', filetype: 'file', label: 'URL of XML file', autofocus: true},
				{name: 'text', type: 'textbox', size: 40, label: 'Fallback text', onchange: function() {
					data.text = this.value();
				}},
				{name: 'xpointer', type: 'textbox', label: 'xPointer Expression'},
			];

			win = editor.windowManager.open({
				title: 'Include external XML data',
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
								title: data.href+'#'+data.xpointer,
								'class': 'xml_include'
							});

							selection.select(xiElm);
						} 
						else {
							editor.focus();
							editor.insertContent(dom.createHTML('span', {
								title: data.href+'#'+data.xpointer,
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
		editor.addButton('xmlinclude', {
			tooltip : 'Include external XML data',
			icon: 'xml', 
			//icon: true,
			//image: url + '/img/xml.png',
			onclick: showDialog,
			stateSelector: 'xi\\:fallback,xi\\:include,span.xml_include'
		});
		
	});
})(tinymce);