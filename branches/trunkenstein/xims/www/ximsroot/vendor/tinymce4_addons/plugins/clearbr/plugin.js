/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

tinymce.PluginManager.requireLangPack('clearbr');

tinymce.PluginManager.add('clearbr', function(editor, url) {

	editor.addCommand('mceClearBr', function() {
		editor.insertContent(
			'<br class="clear"/>'
		);
	});

	editor.addButton('clearbr', {
		title: 'Stop text flow',
		cmd: 'mceClearBr',
		icon: 'clearbr' 
	});

	editor.addMenuItem('clearbr', {
		text: 'Stop text flow',
		cmd: 'mceClearBr',
		context: 'insert',
		icon: 'clearbr'
	});

});
