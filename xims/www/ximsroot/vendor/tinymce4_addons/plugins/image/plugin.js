/**
 * plugin.js
 *
 * Released under LGPL License.
 * Copyright (c) 1999-2015 Ephox Corp. All rights reserved
 *
 * License: http://www.tinymce.com/license
 * Contributing: http://www.tinymce.com/contributing
 */

/*global tinymce:true */

tinymce.PluginManager.requireLangPack('image');

tinymce.PluginManager.add('image', function(editor) {
	function getImageSize(url, callback) {
		var img = document.createElement('img');

		function done(width, height) {
			if (img.parentNode) {
				img.parentNode.removeChild(img);
			}

			callback({width: width, height: height});
		}

		img.onload = function() {
			//
			//console.log('maxWidth: '+editor.settings.image_maxWidth);
			
			if(editor.settings.image_maxWidth){
				var maxWidth = editor.settings.image_maxWidth;
				console.log(img.width +' - '+ maxWidth)
				//done(Math.max(img.width, maxWidth), Math.max(img.height, (maxWidth/img.height)*img.height));
				done(Math.min(img.width, maxWidth), Math.min(img.height, (maxWidth/img.height)*img.height));
			}
			else{
				done(Math.max(img.width, img.clientWidth), Math.max(img.height, img.clientHeight));
			}
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

			if (typeof imageList == "string") {
				tinymce.util.XHR.send({
					url: imageList,
					success: function(text) {
						callback(tinymce.util.JSON.parse(text));
					}
				});
			} else if (typeof imageList == "function") {
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

					if (!isNaN(newHeight)) {
						heightCtrl.value(newHeight);
					}
				} else {
					newWidth = Math.round((newHeight / height) * newWidth);

					if (!isNaN(newWidth)) {
						widthCtrl.value(newWidth);
					}
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
							width: 'auto', //imgElm.clientWidth,
							height: 'auto' //imgElm.clientHeight
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

			if (!data.title) {
				data.title = '';
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
				
				imgElm.classList.toggle('popup-image-gallery', false);
				imgElm.classList.toggle('popup-image', false);
				imgClass = imgElm.className.trim();
			}
			// Setup new data excluding style properties
			/*eslint dot-notation: 0*/
			data = {
				src: data.src,
				alt: data.alt,
				title: data.title,
				width: data.width,
				height: data.height,
				style: data.style,
				caption: data.caption,
				"class":  (imgClass+' '+(data.popupclass||'')).trim() //data["class"]
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

				if (data.title === "") {
					data.title = null;
				}

				if (!imgElm) {
					data.id = '__mcenew';
					editor.focus();
					editor.selection.setContent(dom.createHTML('img', data));
					imgElm = dom.get('__mcenew');
					dom.setAttrib(imgElm, 'id', null);
				} else {
					console.log(data);
					
					//remove float, verticalAlign and margins from image if figure present
					if(figureElm){
						console.log ("figure present");
						var imgData = data;
						var figureData = {
								style: data.style
						}
						var imgcss, figurecss;
						console.log(imgData.style);
						imgcss = dom.parseStyle(imgData.style);
						console.log(imgcss);
						imgcss['float'] = '';
						imgcss['vertical-align'] = '';
						imgcss['margin'] = '';
						imgcss['margin-top'] = '';
						imgcss['margin-right'] = '';
						imgcss['margin-bottom'] = '';
						imgcss['margin-left'] = '';
						imgData.style = dom.serializeStyle(dom.parseStyle(dom.serializeStyle(imgcss)));
						
						figurecss = dom.parseStyle(figureData.style);
						figurecss['border'] = '';
						figureData.style = dom.serializeStyle(dom.parseStyle(dom.serializeStyle(figurecss)))
						
						//figureData.style.border = '';
						
						dom.setAttribs(imgElm, imgData);
						dom.setAttribs(figureElm, figureData);

						console.log(imgData);
						console.log(figureData);
					}
					else{
						dom.setAttribs(imgElm, data);
					}
					//editor.editorUpload.uploadImagesAuto();
				}
				
				editor.editorUpload.uploadImagesAuto();
				
				//caption
				if (data.caption === false) {
					if (dom.is(imgElm.parentNode, 'figure.image')) {
						figureElm = imgElm.parentNode;
						//reapply figure styles to image
						imgElm.style.float = figureElm.style.float;
						imgElm.style.verticalAlign = figureElm.style.verticalAlign;
						imgElm.style.marginTop = figureElm.style.marginTop;
						imgElm.style.marginRight = figureElm.style.marginRight;
						imgElm.style.marginBottom = figureElm.style.marginBottom;
						imgElm.style.marginLeft = figureElm.style.marginLeft;
						dom.insertAfter(imgElm, figureElm);
						dom.remove(figureElm);
					}
				}

				function isTextBlock(node) {
					return editor.schema.getTextBlockElements()[node.nodeName];
				}

				if (data.caption === true) {
					
					if (!dom.is(imgElm.parentNode, 'figure.image')) {
						console.log("create figure element");
						oldImg = imgElm;
						imgElm = imgElm.cloneNode(true);
						figureElm = dom.create('figure', {'class': 'image'});
						figureElm.appendChild(imgElm);
						figureElm.appendChild(dom.create('figcaption', {contentEditable: true}, 'Image caption'));
						figureElm.contentEditable = false;
						//apply img styles to figure and remove them from img
						figureElm.style.float = imgElm.style.float;
						figureElm.style.verticalAlign = imgElm.style.verticalAlign;
						figureElm.style.marginTop = imgElm.style.marginTop;
						figureElm.style.marginLeft = imgElm.style.marginLeft;
						figureElm.style.marginBottom = imgElm.style.marginBottom;
						figureElm.style.marginRight = imgElm.style.marginRight;
						imgElm.style.float = '';
						imgElm.style.verticalAlign = '';
						imgElm.style.marginTop = '';
						imgElm.style.marginLeft = '';
						imgElm.style.marginBottom = '';
						imgElm.style.marginRight = '';

						//var textBlock = dom.getParent(oldImg, isTextBlock);
						var textBlock = isTextBlock(dom.getParent(oldImg));
						if (textBlock) {
							console.log("split from text node");
							dom.split(textBlock, oldImg, figureElm);
						} else {
							dom.replace(figureElm, oldImg);
						}

						editor.selection.select(figureElm);
					}

					return;
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
			console.log("srcChange");
			var srcURL, prependURL, absoluteURLPattern, meta = e.meta || {};

			if (imageListCtrl) {
				imageListCtrl.value(editor.convertURL(this.value(), 'src'));
			}

			tinymce.each(meta, function(value, key) {
				win.find('#' + key).value(value);
			});

			//if (!meta.width && !meta.height) {
				srcURL = editor.convertURL(this.value(), 'src');

				// Pattern test the src url and make sure we haven't already prepended the url
				prependURL = editor.settings.image_prepend_url;
				absoluteURLPattern = new RegExp('^(?:[a-z]+:)?//', 'i');
				if (prependURL && !absoluteURLPattern.test(srcURL) && srcURL.substring(0, prependURL.length) !== prependURL) {
					srcURL = prependURL + srcURL;
				}

				this.value(srcURL);
				
				console.log("getImageSize");
				console.log(data.width +" - "+ data.height +" - "+ imageDimensions);
				getImageSize(editor.documentBaseURI.toAbsolute(this.value()), function(data) {
					
					if (data.width && data.height && imageDimensions) {
						width = data.width;
						height = data.height;

						win.find('#width').value(width);
						win.find('#height').value(height);
					}
				});
			//}
		}
		
		imgElm = editor.selection.getNode();
		figureElm = dom.getParent(imgElm, 'figure.image');
		if (figureElm) {
			imgElm = dom.select('img', figureElm)[0];
		}

		if (imgElm && (imgElm.nodeName != 'IMG' || imgElm.getAttribute('data-mce-object') || imgElm.getAttribute('data-mce-placeholder'))) {
			imgElm = null;
		}

		if (imgElm) {
			width = dom.getAttrib(imgElm, 'width');
			height = dom.getAttrib(imgElm, 'height');

			data = {
				src: dom.getAttrib(imgElm, 'src'),
				alt: dom.getAttrib(imgElm, 'alt'),
				title: dom.getAttrib(imgElm, 'title'),
				"class": dom.getAttrib(imgElm, 'class'),
				width: width,
				height: height,
				caption: !!figureElm
			};
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
					/*eslint consistent-this: 0*/
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
		var generalFormItems = [
			{
				name: 'src',
				type: 'filepicker',
				filetype: 'image',
				label: 'Source',
				autofocus: true,
				onchange: srcChange
			},
			imageListCtrl
		];

		if (editor.settings.image_description !== false) {
			generalFormItems.push({name: 'alt', type: 'textbox', label: 'Image description'});
		}

		if (editor.settings.image_title) {
			generalFormItems.push({name: 'title', type: 'textbox', label: 'Image title'});
		}

		generalFormItems.push(classListCtrl);
		
		//if (editor.settings.image_caption && tinymce.Env.ceFalse) {
		if (editor.settings.image_caption) {
			generalFormItems.push({name: 'caption', type: 'checkbox', label: 'Image caption'});
		}
		
		var advancedFormItems = [
		    //Alignment                     
			{
				type: 'listbox',
				label: 'Alignment',
				name: 'align',
				onselect: updateStyle,
				values: [
				         {text: '- none -', value: ''},
				         {text: 'top', value: 'top'},
				         {text: 'center', value: 'middle'},
				         {text: 'bottom', value: 'bottom'},
				         {text: 'left', value: 'left'},
				         {text: 'right', value: 'right'}
				]
			},
			//Horizontal and vertical Space
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

			{name: 'border', type: 'textbox', maxLength: 20, size: 15, label: 'Rahmen',onchange: updateStyle},
			{
				label: 'Style',
				name: 'style',
				type: 'textbox',
				onchange: updateVSpaceHSpaceBorder
			},
		    ];
		
		if (imageDimensions) {
			advancedFormItems.push({
				type: 'container',
				label: 'Dimensions',
				layout: 'flex',
				direction: 'row',
				align: 'center',
				spacing: 5,
				items: [
						{name: 'width', type: 'textbox', maxLength: 4, size: 4, onchange: recalcSize, ariaLabel: 'Width'},
						{type: 'label', text: 'x'},
						{name: 'height', type: 'textbox', maxLength: 4, size: 4, onchange: recalcSize, ariaLabel: 'Height'},
						{name: 'constrain', type: 'checkbox', checked: true, text: 'Constrain proportions'}
					]
			});
		}
		
		advancedFormItems.push({
				type: 'listbox',
				layout: 'flex',
				label: 'Create Popup for large image view',
				name: 'popupclass',
					values: [
					         {text: '- none -', value: ''},
					         {text: 'Popup for single image', value: 'popup-image'},
					         {text: 'Popup gallery for several images', value: 'popup-image-gallery'}
					]
			});

		function mergeMargins(css) {
			if (css.margin) {

				var splitMargin = css.margin.split(" ");

				switch (splitMargin.length) {
					case 1: //margin: toprightbottomleft;
						css['margin-top'] = css['margin-top'] || splitMargin[0];
						css['margin-right'] = css['margin-right'] || splitMargin[0];
						css['margin-bottom'] = css['margin-bottom'] || splitMargin[0];
						css['margin-left'] = css['margin-left'] || splitMargin[0];
						break;
					case 2: //margin: topbottom rightleft;
						css['margin-top'] = css['margin-top'] || splitMargin[0];
						css['margin-right'] = css['margin-right'] || splitMargin[1];
						css['margin-bottom'] = css['margin-bottom'] || splitMargin[0];
						css['margin-left'] = css['margin-left'] || splitMargin[1];
						break;
					case 3: //margin: top rightleft bottom;
						css['margin-top'] = css['margin-top'] || splitMargin[0];
						css['margin-right'] = css['margin-right'] || splitMargin[1];
						css['margin-bottom'] = css['margin-bottom'] || splitMargin[2];
						css['margin-left'] = css['margin-left'] || splitMargin[1];
						break;
					case 4: //margin: top right bottom left;
						css['margin-top'] = css['margin-top'] || splitMargin[0];
						css['margin-right'] = css['margin-right'] || splitMargin[1];
						css['margin-bottom'] = css['margin-bottom'] || splitMargin[2];
						css['margin-left'] = css['margin-left'] || splitMargin[3];
				}
				delete css.margin;
			}
			return css;
		}

		function updateStyle() {
			function addPixelSuffix(value) {
				if (value.length > 0 && /^[-]?[0-9]+$/.test(value)) {
					value += 'px';
				}

				return value;
			}

			if (!editor.settings.image_advtab) {
				return;
			}

			var data = win.toJSON(),
				css = dom.parseStyle(data.style);

			css = mergeMargins(css);

			if (data.vspace_top) {
				css['margin-top'] = addPixelSuffix(data.vspace_top);
			}
			if (data.vspace_bottom) {
				css['margin-bottom'] = addPixelSuffix(data.vspace_bottom);
			}
			if (data.hspace_left) {
				css['margin-left'] = addPixelSuffix(data.hspace_left);
			}
			if (data.hspace_right) {
				css['margin-right'] = addPixelSuffix(data.hspace_right);
			}
			/*if (data.border) {
				css['border-width'] = addPixelSuffix(data.border);
			}*/
			if (data.border) {
				var reg = new RegExp(/^\d+$/);
				if(reg.test(data.border)){
					css['border'] = data.border + 'px solid black';
				}
				else {
					css['border'] = data.border;
				}
			}
			
			if(data.align=='top'|| data.align=='center' || data.align=='bottom'){
				css['vertical-align'] = data.align;
				css['float'] = '';
			}
			if(data.align=='left'|| data.align=='right'){
				css['float'] = data.align;
				css['vertical-align'] = '';
			}

			win.find('#style').value(dom.serializeStyle(dom.parseStyle(dom.serializeStyle(css))));
		}

		function updateVSpaceHSpaceBorder() {
			if (!editor.settings.image_advtab) {
				return;
			}

			var data = win.toJSON(),
				css = dom.parseStyle(data.style);

			win.find('#vspace_top').value("");
			win.find('#vspace_bottom').value("");
			win.find('#hspace_left').value("");
			win.find('#hspace_right').value("");
			
			win.find('#align').value("");

			css = mergeMargins(css);

			//Move opposite equal margins to vspace/hspace field
			if ((css['margin-top'] && css['margin-bottom']) || (css['margin-right'] && css['margin-left'])) {
				if (css['margin-top']) {
					win.find('#vspace_top').value(removePixelSuffix(css['margin-top']));
				} else {
					win.find('#vspace_top').value('');
				}
				if (css['margin-bottom']) {
					win.find('#vspace_bottom').value(removePixelSuffix(css['margin-bottom']));
				} else {
					win.find('#vspace').value('');
				}
				if (css['margin-left']) {
					win.find('#hspace_left').value(removePixelSuffix(css['margin-left']));
				} else {
					win.find('#hspace_left').value('');
				}
				if (css['margin-right']) {
					win.find('#hspace_right').value(removePixelSuffix(css['margin-right']));
				} else {
					win.find('#hspace_right').value('');
				}
			}

			//Move border-width
			if (css['border']) {
				var reg = new RegExp(/^\d+$/);
				if(reg.test(css['border'])){
					win.find('#border').value(css['border'] + 'px solid black');
				}
				else{
					win.find('#border').value(css['border']);
				}
			}
			else if (css['border-width']) {
				win.find('#border').value(removePixelSuffix(css['border-width']) + "px solid black");
			}
			
			//Alignment
			if (css['float'] == 'left' || css['float'] == 'right'){
				win.find('#align').value(css['float']);
			}
			else {
				win.find('#align').value('');
			}
			
			if (!css['float'] && css['vertical-align']){
				win.find('#align').value(css['vertical-align'])
			}

			win.find('#style').value(dom.serializeStyle(dom.parseStyle(dom.serializeStyle(css))));

		}

		if (editor.settings.image_advtab) {			
			// Parse styles from img
			if (imgElm) {
				//Parse styles from figure element
				if (figureElm){
					//margins and alignment/float from figure
					if (figureElm.style.marginLeft) {
						data.hspace_left = removePixelSuffix(figureElm.style.marginLeft);
					}
					if (figureElm.style.marginRight) {
						data.hspace_right = removePixelSuffix(figureElm.style.marginRight);
					}
					if (figureElm.style.marginTop) {
						data.vspace_top = removePixelSuffix(figureElm.style.marginTop);
					}
					if (figureElm.style.marginBottom) {
						data.vspace_bottom = removePixelSuffix(figureElm.style.marginBottom);
					}
					if (figureElm.style.float && (figureElm.style.float == 'left' || figureElm.style.float == 'right')) {
						data.align = figureElm.style.float;
					}
					else if(figureElm.style.verticalAlign){
						data.align = figureElm.style.verticalAlign;
					}
					//border and classes from img
					if (imgElm.style.border) {
						data.border = imgElm.style.border; //removePixelSuffix(imgElm.style.border);
					}
					else if (imgElm.style.borderWidth) {
						data.border = removePixelSuffix(imgElm.style.borderWidth) + 'px solid black';
					}
					if(imgElm.className.indexOf('popup-image-gallery') != -1){
						data.popupclass = 'popup-image-gallery';
					}
					else if(imgElm.className.indexOf('popup-image') != -1){
						data.popupclass = 'popup-image';
					}
					data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(imgElm, 'style'))) + editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(figureElm, 'style')));
				}
				else{
					if (imgElm.style.marginLeft) {
						data.hspace_left = removePixelSuffix(imgElm.style.marginLeft);
					}
					if (imgElm.style.marginRight) {
						data.hspace_right = removePixelSuffix(imgElm.style.marginRight);
					}
					if (imgElm.style.marginTop) {
						data.vspace_top = removePixelSuffix(imgElm.style.marginTop);
					}
					if (imgElm.style.marginBottom) {
						data.vspace_bottom = removePixelSuffix(imgElm.style.marginBottom);
					}
					/*if (imgElm.style.borderWidth) {
						data.border = removePixelSuffix(imgElm.style.borderWidth);
					}*/
					if (imgElm.style.border) {
						var reg = new RegExp(/^\d+$/);
						if(reg.test(data.border)){
							data.border = imgElm.style.border + 'px solid black';
						}
						else{
							data.border = imgElm.style.border; //removePixelSuffix(imgElm.style.border);
						}
					}
					else if (imgElm.style.borderWidth) {
						data.border = removePixelSuffix(imgElm.style.borderWidth) + 'px solid black';
					}
					if (imgElm.style.float && (imgElm.style.float == 'left' || imgElm.style.float == 'right')) {
						data.align = imgElm.style.float;
					}
					else if(imgElm.style.verticalAlign){
						data.align = imgElm.style.verticalAlign;
					}
					if(imgElm.className.indexOf('popup-image-gallery') != -1){
						data.popupclass = 'popup-image-gallery';
					}
					else if(imgElm.className.indexOf('popup-image') != -1){
						data.popupclass = 'popup-image';
					}
					data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(imgElm, 'style')));
				}

				//data.style = editor.dom.serializeStyle(editor.dom.parseStyle(editor.dom.getAttrib(imgElm, 'style'))+editor.dom.parseStyle(editor.dom.getAttrib(figureElm, 'style')));
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
	
	editor.on('preInit', function() {
		function hasImageClass(node) {
			var className = node.attr('class');
			return className && /\bimage\b/.test(className);
		}

		function toggleContentEditableState(state) {
			return function(nodes) {
				var i = nodes.length, node;

				function toggleContentEditable(node) {
					node.attr('contenteditable', state ? 'true' : null);
				}

				while (i--) {
					node = nodes[i];

					if (hasImageClass(node)) {
						node.attr('contenteditable', state ? 'false' : null);
						tinymce.each(node.getAll('figcaption'), toggleContentEditable);
					}
				}
			};
		}

		editor.parser.addNodeFilter('figure', toggleContentEditableState(true));
		editor.serializer.addNodeFilter('figure', toggleContentEditableState(false));
	});

	editor.addButton('image', {
		icon: 'image',
		tooltip: 'Insert/edit image',
		onclick: createImageList(showDialog),
		stateSelector: 'img:not([data-mce-object],[data-mce-placeholder])'
	});

	editor.addMenuItem('image', {
		icon: 'image',
		text: 'Insert/edit image',
		onclick: createImageList(showDialog),
		context: 'insert',
		prependToContext: true
	});

	editor.addCommand('mceImage', createImageList(showDialog));
	
	
});
