/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

/**
* InOutdent2ndLine Plugin that adds two toolbar buttons. Sets the class of a p-element to "indent"/"outdent"
*/
(function(tinymce) {

	tinymce.PluginManager.requireLangPack('inoutdent2ndline');
	
tinymce.PluginManager.add('inoutdent2ndline', function(editor, url) {
	editor.on('init', function() {
	
	//Register Formats
	editor.formatter.register('indent2ndline', {
		selector: 'p',
		   attributes: {'class': 'indent'}
		 });
	
	editor.formatter.register('outdent2ndline', {
		selector: 'p',
		attributes: {'class': 'outdent'}
		 });
	});

	// Register  buttons
	editor.addButton('indent2ndline', {
		tooltip : 'Indent first line',
		icon: 'indent2ndline', 
		//icon: true,
		//image: url + '/img/indent.png',
		onPostRender: function() {
			var self = this;

		// TODO: Fix this
		if (editor.formatter) {
			editor.formatter.formatChanged('indent2ndline', function(state) {
				self.active(state);
			});
		} else {
			editor.on('init', function() {
				editor.formatter.formatChanged('indent2ndline', function(state) {
					self.active(state);
				});
			});
		}
		},
		onclick: function(){
			editor.formatter.toggle('indent2ndline');
		}
	});
	editor.addButton('outdent2ndline', {
		tooltip : 'Outdent first line',
		icon: 'outdent2ndline', 
		//icon: true,
		//image: tinyMCE.baseURL + '/../../../tinymce_xims/inoutdent2ndline/img/outdent.png',
		onPostRender: function() {
			var self = this;

			// TODO: Fix this
			if (editor.formatter) {
				editor.formatter.formatChanged('outdent2ndline', function(state) {
					self.active(state);
				});
			} else {
				editor.on('init', function() {
					editor.formatter.formatChanged('outdent2ndline', function(state) {
						self.active(state);
					});
				});
			}
		},
		onclick: function(){
			editor.formatter.toggle('outdent2ndline');
		}
	});
	
	editor.addCommand('mceIndent2ndLine', function() {
		editor.formatter.toggle('indent2ndline');		
	});
	editor.addCommand('mceOutdent2ndLine', function() {
		editor.formatter.toggle('outdent2ndline');
	});

});
})(tinymce);
