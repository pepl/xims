/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

(function(tinymce) {

	tinymce.PluginManager.requireLangPack('extraicons');
	
	tinymce.PluginManager.add('extraicons', function(editor, url) {
		var icons = [
		["arrowblack", "arroworange", "new"],
		["image", "document", "pdf"],
		["word", "excel", "ppt"],
		["email", "intranet", "externallink"]
		];
		var menuItems = [];

	function getHtml() {
		var iconsHtml;

		iconsHtml = '<table role="presentation" class="mce-grid">';

		tinymce.each(icons, function(row) {
			iconsHtml += '<tr>';

			tinymce.each(row, function(icon) {
				var iconclass = 'icon_' + icon

				iconsHtml += '<td><a title="'+icon+'" href="#" data-mce-icon="' + icon + '" tabindex="-1"><span class="mceButton-sprite icon_'+icon+'">&#160;</span></a></td>';
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

				iconsHtml += '<td><a title="'+icon+'" href="#" data-mce-icon="' + icon + '" tabindex="-1"><span class="mceButton-sprite icon_'+icon+'">&#160;</span></a></td>';
			
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
	
	
	
	editor.addButton('extraicons', {
		type: 'panelbutton',
		popoverAlign: 'bc-tl',
		icon: 'extra-icons',
		//icon: true,
		//image: url + '/img/extra-icons.png',
		panel: {
			autohide: true,
			html: getHtml,
			onclick: function(e) {
				var linkElm = editor.dom.getParent(e.target, 'a');
				if (linkElm) {
					editor.insertContent('<span title="'+linkElm.getAttribute('data-mce-icon')+'" class="sprite icon_'+linkElm.getAttribute('data-mce-icon')+'" >&#160;</span>&#160;');
					this.hide();
				}
			}
		},
		tooltip: 'Extra Icons'
	});
	
	// Adds a menu item to the tools menu
	editor.addMenuItem('extraicons', {
		text: 'Extra Icons',
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
