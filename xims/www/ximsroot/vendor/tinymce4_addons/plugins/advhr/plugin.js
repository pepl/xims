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
		var classFound;
		
		function findClasses(item, classes){
			for ( var i = 0; i < classes.length; i++ )
			{
			  if ( item.hasClass( classes[i] ) )
			  {
			    classFound = classes[i];
			    return classFound;  
			  }
			}
			return '';
		}

		function onSubmitForm() {

			var data = win.toJSON();

			if (data.width === '') {
				data.width = null;
			}

			if (data.width > 100)
				data.width = 100;

			data = {
				width : data.width,
				width2 : '%',
				align : data.align,
				style : data.style,
				colour: data. colour
			};

			if (!hrElm) {
				data.id = '__mcenew';
				editor.insertContent(dom.createHTML('hr', {
					width : data.width + data.width2,
					align : data.align,
					'class' : data.style + ' ' + data.colour,
					/*'class' : data.style,
					'class' : data.colour,*/
					id : data.id
				}));
				hrElm = dom.get('__mcenew');
				dom.setAttrib(hrElm, 'id', null);
			} else {
				dom.setAttribs(hrElm, {
					width : data.width + data.width2,
					align : data.align,
					'class' : data.style + ' ' + data.colour//,
					//'class' : data.colour
				});
			}
		}

		w = dom.getAttrib(hrElm, 'width');
		//width2 = (w.indexOf('%') != -1) ? '%' : 'px';
		w.replace('px', '').replace('%', '');
		width = parseInt(w);
		align = dom.getAttrib(hrElm, 'align') || 'center';
		//style = dom.getAttrib(hrElm, 'class') || 'solid';
		style = findClasses($(hrElm), ['solid', 'dotted', 'dashed', 'double']) || '';
		colour = findClasses($(hrElm), ['orange', 'blue', 'grey']) || '';

		if (hrElm.nodeName == 'HR' && !hrElm.getAttribute('data-mce-object')) {
			data = {
				width : width,
				//width2 : width2,
				align : align,
				style : style,
				colour: colour
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
				value: '100',
				maxLength : 3,
				size : 3,
				label : 'width'
			}, {
				type : 'label',
				//name : 'width2',
				text: '%'
				/*values : [ {
					text : 'px',
					value : 'px'
				}, {
					text : '%',
					value : '%'
				} ]*/
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
		}, {
			type : 'listbox',
			label : 'Style',
			name : 'style',
			values : [ {
				text : 'solid',
				value : 'solid'
			},{
				text : 'dotted',
				value : 'dotted'
			}, {
				text : 'dashed',
				value : 'dashed'
			}, {
				text : 'double',
				value : 'double'
			}]
			}, {
			type : 'listbox',
			label : 'Colour',
			name : 'colour',
			values : [ {
				text : 'default',
				value : ''
			},{
					text : 'orange',
					value : 'orange'
				},{
					text : 'blue',
					value : 'blue'
				},{
					text : 'light grey',
					value : 'grey'
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
		context : 'insert'
	});
});
