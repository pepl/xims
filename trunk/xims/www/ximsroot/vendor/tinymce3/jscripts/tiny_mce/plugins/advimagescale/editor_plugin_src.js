/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

(function() {
	tinymce.PluginManager.requireLangPack('advimagescale');
	
	tinymce.create('tinymce.plugins.advimagescale', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mceadvimagescale', function() {
				// Internal image object like a flash placeholder
				if (ed.dom.getAttrib(ed.selection.getNode(), 'class').indexOf('mceItem') != -1)
					return;

				ed.windowManager.open({
					file : url + '/advimagescale.html',
					width : 600 + parseInt(ed.getLang('advimagescale.delta_width', 0)),
					height : 500 + parseInt(ed.getLang('advimagescale.delta_height', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});
			
			// Register buttons
			ed.addButton('advimagescale', {
				title : 'advimagescale.desc',
				cmd : 'mceadvimagescale',
				image : url + '/img/advimagescale.gif'
			});
			
			ed.onNodeChange.add(function(ed, cm, n) {
				n = ed.dom.getParent(n, 'IMG');
				cm.setActive('advimagescale', 0);
				// Activate all
				if(n){
					do{
						//cm.setDisabled('advimagescale', 0);
						cm.setActive('advimagescale', 1);
					}
					while(n = n.parentNode);
				}
			});
		},

		getInfo : function() {
			return {
				longname : 'Advanced image scale',
				author : 'Moxiecode Systems AB',
				authorurl : 'http://tinymce.moxiecode.com',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/advimagescale',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('advimagescale', tinymce.plugins.advimagescale);
})();