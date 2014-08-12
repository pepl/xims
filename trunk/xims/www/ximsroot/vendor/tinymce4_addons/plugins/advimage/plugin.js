/**
 * plugin.js
 *
 * Copyright, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://www.tinymce.com/license
 * Contributing: http://www.tinymce.com/contributing
 */

/*global tinymce:true */
tinymce.PluginManager.requireLangPack('advimage');

tinymce.PluginManager.add('advimage', function(editor) {
	function getImageSize(url, callback) {
		var img = document.createElement('img');

		function done(width, height) {
			if (img.parentNode) {
				img.parentNode.removeChild(img);
			}

			callback({width: width, height: height});
		}

		img.onload = function() {
			done(img.clientWidth, img.clientHeight);
		};

		img.onerror = function() {
			done();
		};

		var style = img.style;
		style.visibility = 'hidden';
		style.position = 'fixed';
		style.bottom = style.left = 0;
		style.width = style.height = 'auto';

		document.body.appendChild(img);
		img.src = url;
	}

	function buildListItems(inputList, itemCallback, startItems) {
		function appendItems(values, output) {
			output = output || [];

			tinymce.each(values, function(item) {
				var menuItem = {text: item.text || item.title};

				if (item.menu) {
					menuItem.menu = appendItems(item.menu);
				} else {
					menuItem.value = item.value;
					itemCallback(menuItem);
				}

				output.push(menuItem);
			});

			return output;
		}

		return appendItems(inputList, startItems || []);
	}

	function createImageList(callback) {
		return function() {
			var imageList = editor.settings.image_list;

			if (typeof(imageList) == "string") {
				tinymce.util.XHR.send({
					url: imageList,
					success: function(text) {
						callback(tinymce.util.JSON.parse(text));
					}
				});
			} else if (typeof(imageList) == "function") {
				imageList(callback);
			} else {
				callback(imageList);
			}
		};
	}

	function showDialog(imageList) {
		var win, data = {}, dom = editor.dom, imgElm = editor.selection.getNode();
		var width, height, imageListCtrl, classListCtrl, imageDimensions = editor.settings.image_dimensions !== false;

		function recalcSize() {
			var widthCtrl, heightCtrl, newWidth, newHeight;

			widthCtrl = win.find('#width')[0];
			heightCtrl = win.find('#height')[0];

			if (!widthCtrl || !heightCtrl) {
				return;
			}

			newWidth = widthCtrl.value();
			newHeight = heightCtrl.value();

			if (win.find('#constrain')[0].checked() && width && height && newWidth && newHeight) {
				if (width != newWidth) {
					newHeight = Math.round((newWidth / width) * newHeight);
					heightCtrl.value(newHeight);
				} else {
					newWidth = Math.round((newHeight / height) * newWidth);
					widthCtrl.value(newWidth);
				}
			}

			width = newWidth;
			height = newHeight;
		}

		function onSubmitForm() {
			function waitLoad(imgElm) {
				function selectImage() {
					imgElm.onload = imgElm.onerror = null;

					if (editor.selection) {
						editor.selection.select(imgElm);
						editor.nodeChanged();
					}
				}

				imgElm.onload = function() {
					if (!data.width && !data.height && imageDimensions) {
						dom.setAttribs(imgElm, {
							width: imgElm.clientWidth,
							height: imgElm.clientHeight
						});
					}

					selectImage();
				};

				imgElm.onerror = selectImage;
			}

			updateStyle();
			recalcSize();

			data = tinymce.extend(data, win.toJSON());

			if (!data.alt) {
				data.alt = '';
			}

			if (data.width === '') {
				data.width = null;
			}

			if (data.height === '') {
				data.height = null;
			}

			if (!data.style) {
				data.style = null;
			}

			var imgClass = '';
			if (imgElm && imgElm.hasAttribute('class')){
				imgClass = imgElm.className;
				imgElm.classList.toggle('popup-image-gallery', false);
				imgElm.classList.toggle('popup-image', false);
			}
			// Setup new data excluding style properties
			data = {
				src: data.src,
				title: data.title,
				alt: data.alt,
				width: data.width,
				height: data.height,
				style: data.style,
				//"class": data["class"]
				'class': imgClass+' '+(data.popupclass||'')
			};

			editor.undoManager.transact(function() {
				if (!data.src) {
					if (imgElm) {
						dom.remove(imgElm);
						editor.focus();
						editor.nodeChanged();
					}

					return;
				}
				if(data.captiontext && data.captiontext != ''){
					var figdata = {
							style: data.style,
							width: data.width,
							height: data.height
					};
					var imgdata = {
							src: data.src,
							title: data.title,
							alt: data.alt,
							width: data.width,
							height: data.height,
							'class': imgClass+' '+(data.popupclass||'')
						};
					var inner = dom.createHTML('img', imgdata)+' '+dom.createHTML('figcaption',{},data.captiontext);
					if (!imgElm) {
						figdata.id = '__mcenew';						
						editor.selection.setContent(dom.createHTML('figure', figdata, inner));
						imgElm = dom.get('__mcenew');
						dom.setAttrib(imgElm, 'id', null);
					} else {
						if(imgElm.parentNode.tagName != 'FIGURE'){
							editor.selection.setContent(dom.createHTML('figure', figdata, inner));
						}
						else{
							dom.setAttribs(imgElm.parentNode, figdata);
							dom.setAttribs(imgElm, imgdata);
							var figcElm = imgElm.nextElementSibling;
							if(figcElm.tagName=='FIGCAPTION'){
								figcElm.innerHTML = data.captiontext;
							}
						}
					}
				}
				else{
					if (!imgElm) {
						data.id = '__mcenew';
						editor.focus();
						editor.selection.setContent(dom.createHTML('img', data));
						imgElm = dom.get('__mcenew');
						dom.setAttrib(imgElm, 'id', null);
					} else {
						dom.setAttribs(imgElm, data);
					}
				}

				waitLoad(imgElm);
			});
		}

		function removePixelSuffix(value) {
			if (value) {
				value = value.replace(/px$/, '');
			}

			return value;
		}

		function srcChange(e) {
			var meta = e.meta || {};

			if (imageListCtrl) {
				imageListCtrl.value(editor.convertURL(this.value(), 'src'));
			}

			tinymce.each(meta, function(value, key) {
				win.find('#' + key).value(value);
			});

			if (!meta.width && !meta.height) {
				getImageSize(this.value(), function(data) {
					if (data.width && data.height && imageDimensions) {
						width = data.width;
						height = data.height;

						win.find('#width').value(width);
						win.find('#height').value(height);
					}
				});
			}
		}

		width = dom.getAttrib(imgElm, 'width');
		height = dom.getAttrib(imgElm, 'height');
		if(imgElm.nodeName == 'IMG'){
			if (!imgElm.getAttribute('data-mce-object') && !imgElm.getAttribute('data-mce-placeholder')) {
				data = {
					src: dom.getAttrib(imgElm, 'src'),
					title: dom.getAttrib(imgElm, 'title'),
					alt: dom.getAttrib(imgElm, 'alt'),
					"class": dom.getAttrib(imgElm, 'class'),
					width: width,
					height: height
				};
			}
			if (imgElm.parentNode.nodeName == 'FIGURE') {
				data = {
					src: dom.getAttrib(imgElm, 'src'),
					title: dom.getAttrib(imgElm, 'title'),
					alt: dom.getAttrib(imgElm, 'alt'),
					"class": dom.getAttrib(imgElm, 'class'),
					width: width,
					height: height,
					//caption: true,
					captiontext: imgElm.parentNode.getElementsByTagName("FIGCAPTION")[0].innerHTML
				};
			}
		}
		else if(imgElm.nodeName == 'FIGURE') {
			data = {
					captiontext: imgElm.getElementsByTagName("FIGCAPTION")[0].innerHTML,
					style: imgElm.style
				};
		}
		else {
			imgElm = null;
		}

		if (imageList) {
			imageListCtrl = {
				type: 'listbox',
				label: 'Image list',
				values: buildListItems(
					imageList,
					function(item) {
						item.value = editor.convertURL(item.value || item.url, 'src');
					},
					[{text: 'None', value: ''}]
				),
				value: data.src && editor.convertURL(data.src, 'src'),
				onselect: function(e) {
					var altCtrl = win.find('#alt');

					if (!altCtrl.value() || (e.lastControl && altCtrl.value() == e.lastControl.text())) {
						altCtrl.value(e.control.text());
					}

					win.find('#src').value(e.control.value()).fire('change');
				},
				onPostRender: function() {
					imageListCtrl = this;
				}
			};
		}

		if (editor.settings.image_class_list) {
			classListCtrl = {
				name: 'class',
				type: 'listbox',
				label: 'Class',
				values: buildListItems(
					editor.settings.image_class_list,
					function(item) {
						if (item.value) {
							item.textStyle = function() {
								return editor.formatter.getCssText({inline: 'img', classes: [item.value]});
							};
						}
					}
				)
			};
		}

		// General settings shared between simple and advanced dialogs
		/*var generalFormItems = [
			{
				name: 'src',
				type: 'filepicker',
				filetype: 'image',
				label: 'Source',
				autofocus: true,
				onchange: srcChange
			},
			imageListCtrl
		];*/
		// General settings shared between simple and advanced dialogs
		var generalFormItems = [
		    {name: 'src', type: 'filepicker', filetype: 'image', label: 'Source', autofocus: true, onchange: recalcSize},
			{name: 'title', type: 'textbox', label: 'Title', 'class': 'id-input-title'},
			{name: 'alt', type: 'textbox', label: 'Image description'},
			//{label: '', name: 'caption', type: 'checkbox', checked: checkCaption(), text: 'Insert as caption'},
			{name: 'captiontext', type: 'textbox', label: 'Image caption', multiline: true},
		];
		
		var advancedFormItems = [
			{
				type: 'listbox',
				label: 'Alignment',
				name: 'align',
				onselect: updateStyle,
				values: [
				         {text: '- none -', value: ''},
				         {text: 'top', value: 'top'},
				         {text: 'center', value: 'center'},
				         {text: 'bottom', value: 'bottom'},
				         {text: 'left', value: 'left'},
				         {text: 'right', value: 'right'}
				]
			},
			{
				type: 'container',
				label: 'Dimensions',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				items: [
					{name: 'width', type: 'textbox', maxLength: 3, size: 3, onchange: recalcSize},
					{type: 'label', text: 'x'},
					{name: 'height', type: 'textbox', maxLength: 3, size: 3, onchange: recalcSize},
					{name: 'constrain', type: 'checkbox', checked: true, text: 'Constrain proportions'}
				]
			},
			{
				type: 'container',
				label: 'Vertical space top',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				onchange: updateStyle,
				items: [
				        {name: 'vspace_top', type: 'textbox', maxLength: 3, size: 3},
				        {type: 'label', text: 'px'}
				]
			},
			{
				type: 'container',
				label: 'Vertical space bottom',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				onchange: updateStyle,
				items: [
				        {name: 'vspace_bottom', type: 'textbox', maxLength: 3, size: 3},
				        {type: 'label', text: 'px'}
				]
			},
			{
				type: 'container',
				label: 'Horizontal space left',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				onchange: updateStyle,
				items: [
				        {name: 'hspace_left', type: 'textbox', maxLength: 3, size: 3},
				        {type: 'label', text: 'px'}
				]
			},
			{
				type: 'container',
				label: 'Horizontal space right',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				onchange: updateStyle,
					items: [
					        {name: 'hspace_right', type: 'textbox', maxLength: 3, size: 3},
					        {type: 'label', text: 'px'}
				]
			},
			{name: 'border', type: 'textbox', maxLength: 3, size: 3, label: 'Rahmen',onchange: updateStyle},
			{
				type: 'listbox',
				layout: 'flex',
				label: 'Create Popup for large image view',
				name: 'popupclass',
					values: [
					         {text: '- none -', value: ''},
					         {text: 'Popup for single image', value: 'popup-image'},
					         {text: 'Popup gallery for several images', value: 'popup-image-gallery'}
					]
			},
			{
				label: 'Style',
				name: 'style',
				type: 'textbox'
			}
		];
/*
		if (editor.settings.image_description !== false) {
			generalFormItems.push({name: 'alt', type: 'textbox', label: 'Image description'});
		}

		if (imageDimensions) {
			generalFormItems.push({
				type: 'container',
				label: 'Dimensions',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				items: [
					{name: 'width', type: 'textbox', maxLength: 5, size: 3, onchange: recalcSize, ariaLabel: 'Width'},
					{type: 'label', text: 'x'},
					{name: 'height', type: 'textbox', maxLength: 5, size: 3, onchange: recalcSize, ariaLabel: 'Height'},
					{name: 'constrain', type: 'checkbox', checked: true, text: 'Constrain proportions'}
				]
			});
		}

		generalFormItems.push(classListCtrl);
*/
		function updateStyle() {
			function addPixelSuffix(value) {
				if (value.length > 0 && /^[0-9]+$/.test(value)) {
					value += 'px';
				}

				return value;
			}

			if (!editor.settings.image_advtab) {
				return;
			}

			var data = win.toJSON();
			var css = dom.parseStyle(data.style);

			delete css.margin;
			/*css['margin-top'] = css['margin-bottom'] = addPixelSuffix(data.vspace);
			css['margin-left'] = css['margin-right'] = addPixelSuffix(data.hspace);
			css['border-width'] = addPixelSuffix(data.border);*/
			css['margin-top'] = addPixelSuffix(data.vspace_top);
			css['margin-bottom'] = addPixelSuffix(data.vspace_bottom);
			css['margin-left'] = addPixelSuffix(data.hspace_left);
			css['margin-right'] = addPixelSuffix(data.hspace_right);
			//css['border-width'] = addPixelSuffix(data.border);
			if(data.border != ""){
				css['border'] = addPixelSuffix(data.border)+ " solid black";
			}
			
			if(data.align=='top'|| data.align=='center' || data.align=='bottom'){
				css['vertical-align'] = data.align;
				css['float'] = '';
			}
			if(data.align=='left'|| data.align=='right'){
				css['float'] = data.align;
				css['vertical-align'] = '';
			}
				css['width'] = addPixelSuffix(data.width);
				css['height'] = addPixelSuffix(data.height);

			win.find('#style').value(dom.serializeStyle(dom.parseStyle(dom.serializeStyle(css))));
		}

		if (editor.settings.image_advtab) {
			// Parse styles from img
			/*if (imgElm) {
				data.hspace = removePixelSuffix(imgElm.style.marginLeft || imgElm.style.marginRight);
				data.vspace = removePixelSuffix(imgElm.style.marginTop || imgElm.style.marginBottom);
				data.border = removePixelSuffix(imgElm.style.borderWidth);
				data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(imgElm, 'style')));
			}*/
			if (imgElm && imgElm.nodeName == 'IMG') {
				if(imgElm.parentNode.nodeName == 'FIGURE'){
					data.hspace_left = removePixelSuffix(imgElm.parentNode.style.marginLeft);
					data.hspace_right = removePixelSuffix(imgElm.parentNode.style.marginRight);
					data.vspace_top = removePixelSuffix(imgElm.parentNode.style.marginTop);
					data.vspace_bottom = removePixelSuffix(imgElm.parentNode.style.marginBottom);
					data.border = removePixelSuffix(imgElm.parentNode.style.borderWidth);
					data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(imgElm.parentNode, 'style')));
				}
				else{
					data.hspace_left = removePixelSuffix(imgElm.style.marginLeft);
					data.hspace_right = removePixelSuffix(imgElm.style.marginRight);
					data.vspace_top = removePixelSuffix(imgElm.style.marginTop);
					data.vspace_bottom = removePixelSuffix(imgElm.style.marginBottom);
					data.border = removePixelSuffix(imgElm.style.borderWidth);
					data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(imgElm, 'style')));
				}
				if(imgElm.className.indexOf('popup-image-gallery') != -1){
					data.popupclass = 'popup-image-gallery';
				}
				else if(imgElm.className.indexOf('popup-image') != -1){
					data.popupclass = 'popup-image';
				}
			}
			else if (imgElm && imgElm.nodeName == 'FIGURE') {
				var figElm = imgElm;
				data.hspace_left = removePixelSuffix(figElm.style.marginLeft);
				data.hspace_right = removePixelSuffix(figElm.style.marginRight);
				data.vspace_top = removePixelSuffix(figElm.style.marginTop);
				data.vspace_bottom = removePixelSuffix(figElm.style.marginBottom);
				data.border = removePixelSuffix(figElm.style.borderWidth);
				data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(figElm, 'style')));
			}

			// Advanced dialog shows general+advanced tabs
			win = editor.windowManager.open({
				title: 'Insert/edit image',
				data: data,
				bodyType: 'tabpanel',
				body: [
								{
									title: 'General',
									type: 'form',
									items: generalFormItems
								},

								{
									title: 'Advanced',
									type: 'form',
									pack: 'start',
									items: advancedFormItems
								}
							],
				onSubmit: onSubmitForm
			});
		} else {
			// Simple default dialog
			win = editor.windowManager.open({
				title: 'Insert/edit image',
				data: data,
				body: generalFormItems,
				onSubmit: onSubmitForm
			});
		}
	}

	editor.addButton('advimage', {
		icon: 'image',
		tooltip: 'Insert/edit image',
		onclick: createImageList(showDialog),
		stateSelector: 'img:not([data-mce-object],[data-mce-placeholder])'
	});

	editor.addMenuItem('advimage', {
		icon: 'image',
		text: 'Insert image',
		onclick: createImageList(showDialog),
		context: 'insert',
		prependToContext: true
	});

	editor.addCommand('mceImage', createImageList(showDialog));
});
