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
	tinymce.PluginManager.requireLangPack('setlang');
	
	tinymce.create('tinymce.plugins.SetLangPlugin', {
		/**
		 * Initializes the plugin, this will be executed after the plugin has been created.
		 * This call is done before the editor instance has finished it's initialization so use the onInit event
		 * of the editor instance to intercept that event.
		 *
		 * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
		 * @param {string} url Absolute URL to where the plugin is located.
		 */
		init : function(ed, url) {
			ed.addCommand('mceSetLang', function() {
				ed.windowManager.open({
					file : url + '/set_lang.html',
					width : 380 + parseInt(ed.getLang('setlang.setlang_delta_width', 0)),
					height : 380 + parseInt(ed.getLang('setlang.setlang_delta_width', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});
			
			// Register buttons
			ed.addButton('setlang', {
				title : 'setlang.desc',	
				cmd : 'mceSetLang',
				image : url + '/img/set_lang.png'});

			ed.onNodeChange.add(function(ed, cm, n, co) {
				n = ed.dom.getParent(n, 'SPAN');
				cm.setActive('setlang', 0);
				
				// Activate all
				if (n && n.className == 'lang') {
					do {
						cm.setActive('setlang', 1);
					} while (n = n.parentNode);
				}
			
			});

			ed.onInit.add(function() {
				// Fixed IE issue where it can't handle these elements correctly
				ed.dom.create('span');
			});
		},

		getInfo : function() {
			return {
				longname : 'SetLanguage Plugin',
				author : 'Heinrich Reimer, adapted from Sylvia Egger "ChangeLang Plugin"',
				authorurl : '',
				infourl : 'http://uibk.ac.at',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('setlang', tinymce.plugins.SetLangPlugin);
})();