/**
 * plugin.js
 * 
 * @author Susanne Tober
 * @copyright Copyright 2014, University of Innsbruck Released under LGPL
 *            License.
 * 
 */

tinymce.PluginManager.requireLangPack('advhr');

tinymce.PluginManager.add('advhr', function(editor) {

	function showDialog() {
		var win, data, dom = editor.dom, hrElm = editor.selection.getNode();
		var w, width, width2, align;

		function onSubmitForm() {

			var data = win.toJSON();

			if (data.width === '') {
				data.width = null;
			}

			if (data.width2 == '%' && data.width > 100)
				data.width = 100;

			data = {
				width : data.width,
				width2 : data.width2 || 'px',
				align : data.align
			};

			if (!hrElm) {
				data.id = '__mcenew';
				editor.insertContent(dom.createHTML('hr', {
					width : data.width + data.width2,
					align : data.align,
					id : data.id
				}));
				hrElm = dom.get('__mcenew');
				dom.setAttrib(hrElm, 'id', null);
			} else {
				dom.setAttribs(hrElm, {
					width : data.width + data.width2,
					align : data.align
				});
			}
		}

		w = dom.getAttrib(hrElm, 'width');
		width2 = (w.indexOf('%') != -1) ? '%' : 'px';
		w.replace('px', '').replace('%', '');
		width = parseInt(w);
		align = dom.getAttrib(hrElm, 'align') || 'center';

		if (hrElm.nodeName == 'HR' && !hrElm.getAttribute('data-mce-object')) {
			data = {
				width : width,
				width2 : width2,
				align : align
			};
		} else {
			hrElm = null;
		}

		var generalFormItems = [ {
			type : 'container',
			label : 'Dimensions',
			layout : 'flex',
			direction : 'row',
			align : 'center',
			spacing : 5,
			items : [ {
				name : 'width',
				type : 'textbox',
				maxLength : 3,
				size : 3,
				label : 'width'
			}, {
				type : 'listbox',
				name : 'width2',
				values : [ {
					text : 'px',
					value : 'px'
				}, {
					text : '%',
					value : '%'
				} ]
			} ]
		}, {
			type : 'listbox',
			label : 'Alignment',
			name : 'align',
			values : [ {
				text : 'left',
				value : 'left'
			}, {
				text : 'center',
				value : 'center'
			}, {
				text : 'right',
				value : 'right'
			} ]
		} ];
		win = editor.windowManager.open({
			title : 'Insert horizontal ruler',
			data : data,
			body : generalFormItems,
			onSubmit : onSubmitForm
		});
	}

	editor.addButton('advhr', {
		icon : 'hr',
		tooltip : 'Insert horizontal ruler',
		onclick : showDialog,
		stateSelector : 'hr'
	});

	editor.addMenuItem('advhr', {
		icon : 'hr',
		text : 'Horizontal line',
		onclick: showDialog,
		context : 'insert'
	});
});
