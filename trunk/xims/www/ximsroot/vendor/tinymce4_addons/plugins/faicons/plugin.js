/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

(function(tinymce) {

	tinymce.PluginManager.requireLangPack('faicons');
	
	tinymce.PluginManager.add('faicons', function(editor, url) {
		var icons = [
		["arrow-right", "arrow-down","arrow-left","arrow-up"],
		["file-image-o", "file-text-o", "file-pdf-o", "file-word-o"],
		[ "file-excel-o", "file-powerpoint-o"],
		["envelope-o", "home" , "phone" , "globe"],
		["info-circle", "exclamation-triangle", "wheelchair", "check"],
		["lock", "external-link", "download" , "calendar"],
		["rss-square", "facebook-square", "twitter-square" , "google-plus-square"], 
		["soundcloud", "youtube-play"]
		];
		var menuItems = [];

	function getHtml() {
		var iconsHtml;

		iconsHtml = '<table role="presentation" class="mce-grid">';

		tinymce.each(icons, function(row) {
			iconsHtml += '<tr>';

			tinymce.each(row, function(icon) {
				var iconclass = 'icon_' + icon

				iconsHtml += '<td><a title="'+icon+'" href="#" data-mce-icon="' + icon + '" tabindex="-1"><i class="fa fa-'+icon+'">&#160;</i></a></td>';
			});

			iconsHtml += '</tr>';
		});

		iconsHtml += '</table>';

		return iconsHtml;
	}
	
	function getItems() {
		var iconsHtml;

		iconsHtml = '<table role="presentation" class="mce-grid">';

		tinymce.each(icons, function(row) {
			iconsHtml += '<tr>';

			tinymce.each(row, function(icon) {
				var iconclass = 'icon_' + icon

				iconsHtml += '<td><a title="'+icon+'" href="#" data-mce-icon="' + icon + '" tabindex="-1"><i class="mceButton-sprite icon_'+icon+'">&#160;</i></a></td>';
			
				menuItems.push({
					text: icon, //'<a title="'+icon+'" href="#" data-mce-icon="' + icon + '" tabindex="-1"><span class="mceButton-sprite icon_'+icon+'">&#160;</span></a>',
					onclick: function(e) {
						var linkElm = editor.dom.getParent(e.target, 'a');
						if (linkElm) {
							editor.insertContent('<span title="'+linkElm.getAttribute('data-mce-icon')+'" class="sprite icon_'+linkElm.getAttribute('data-mce-icon')+'" >&#160;</span>&#160;');
							this.hide();
						}
					}
				});
			});

			iconsHtml += '</tr>';
		});

		iconsHtml += '</table>';

		return iconsHtml;
	}
	
	
	
	editor.addButton('faicons', {
		type: 'panelbutton',
		popoverAlign: 'bc-tl',
		icon: 'extra-icons',
		
		//icon: true,
		//image: url + '/img/extra-icons.png',
		panel: {
			autohide: true,
			width: 100,
			html: getHtml,
			onclick: function(e) {
				var linkElm = editor.dom.getParent(e.target, 'a');
				if (linkElm) {
					editor.insertContent('<i title="'+linkElm.getAttribute('data-mce-icon')+'" class="fa fa-'+linkElm.getAttribute('data-mce-icon')+'" >&#160;</i>&#160;');
					this.hide();
				}
			}
		},
		tooltip: 'Extra icons'
	});
	
	// Adds a menu item to the tools menu
	editor.addMenuItem('faicons', {
		text: 'Extra icons',
		context: 'insert',
		//menu: getItems,
		menu: {
			autohide: true,
			menu: menuItems,
			//menu: getHtml,
			//html: getHtml,
			/*onclick: function(e) {
				var linkElm = editor.dom.getParent(e.target, 'a');
				if (linkElm) {
					editor.insertContent('<span title="'+linkElm.getAttribute('data-mce-icon')+'" class="sprite icon_'+linkElm.getAttribute('data-mce-icon')+'" >&#160;</span>&#160;');
					this.hide();
				}
			}*/
		},
	});
});
})(tinymce);
