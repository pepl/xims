var ImageDialog = {
	preInit : function() {
		var url;

		tinyMCEPopup.requireLangPack();

		if (url = tinyMCEPopup.getParam("external_image_list_url"))
			document.write('<script language="javascript" type="text/javascript" src="' + tinyMCEPopup.editor.documentBaseURI.toAbsolute(url) + '"></script>');
	},

	init : function(ed) {
		var f = document.forms[0], nl = f.elements, ed = tinyMCEPopup.editor, dom = ed.dom, n = ed.selection.getNode();

		tinyMCEPopup.resizeToInnerSize();
		TinyMCE_EditableSelects.init();
		

		if (n.nodeName == 'IMG') {
			var img = $(ed.selection.getNode());
			var div;
			if(img.parent().hasClass('caption')){
				div = img.parent();
				
				//set form values
				nl.vspace_top.value = div.css('margin-top').replace('px','');
				nl.vspace_bottom.value = div.css('margin-bottom').replace('px','');
				nl.hspace_left.value = div.css('margin-left').replace('px','');
				nl.hspace_right.value = div.css('margin-right').replace('px','');
				nl.border.value = div.css('border-top-width').replace('px','');
				if(div.css('float')!='none'){
					nl.align.value = div.css('float');
				}
				else if(div.css('vertical-align')!='none'){
					nl.align.value = div.css('vertical-align');
				}
				else {
					nl.align.value = '';
				} 
			}
			else{
				nl.vspace_top.value = img.css('margin-top').replace('px','');
				nl.vspace_bottom.value = img.css('margin-bottom').replace('px','');
				nl.hspace_left.value = img.css('margin-left').replace('px','');
				nl.hspace_right.value = img.css('margin-right').replace('px','');
				nl.border.value = img.css('border-top-width').replace('px','');
				
				//IE fix: replace alle form.element values of 'auto' with readable '0' 
				for(var i = 0; i < nl.length; i++)
				{
					if(f.elements[i].value == 'auto')
					{
						f.elements[i].value = '0';
					}
				}
				
				if(img.css('float')!='none'){
					nl.align.value = img.css('float');
				}
				else if(img.css('vertical-align')!='none'){
					nl.align.value = img.css('vertical-align');
				}
				else {
					nl.align.value = '';
				} 
			}
			
			nl.src.value = img.attr('src');
			nl.width.value = img.width();
			nl.height.value = img.height();
			nl.alt.value = img.attr('alt');
			nl.title.value = img.attr('title');
			
			var style = "";
			if (div) {
				style = div.attr('style');
				style = style.substr(0,style.indexOf('width')-1);
				
			}
			else if(img.attr('style')){
				style = dom.getAttrib(n, 'style');
			}
			nl.style.value = style;
			
			// classes for image popups
			if(img.attr('class') != ""){
			 nl.popup.checked = "checked";
			 nl.popupoption.value = img.attr('class');
			}
			
			nl.insert.value = ed.getLang('update');


			if (ed.settings.inline_styles) {
				// Move attribs to styles
				if (dom.getAttrib(n, 'align'))
					this.updateStyle('align');

				if (dom.getAttrib(n, 'hspace_left'))
					this.updateStyle('hspace_left');
				
				if (dom.getAttrib(n, 'hspace_right'))
					this.updateStyle('hspace_right');

				if (dom.getAttrib(n, 'border'))
					this.updateStyle('border');

				if (dom.getAttrib(n, 'vspace_top')){
					this.updateStyle('vspace_top');
				}
				if (dom.getAttrib(n, 'vspace_bottom'))
					this.updateStyle('vspace_bottom');
			}
		}

		// Setup browse button
		document.getElementById('srcbrowsercontainer').innerHTML = getBrowserHTML('srcbrowser','src','image','theme_advanced_image');
		if (isVisible('srcbrowser'))
			document.getElementById('src').style.width = '330px';
			
		// If option enabled default constrain proportions to checked
		if (ed.getParam("advimage_constrain_proportions", true))
			f.constrain.checked = true;

		this.changeAppearance();
		this.showPreviewImage(nl.src.value, 1);
	},

	insert : function(file, title) {
		
		var ed = tinyMCEPopup.editor, t = this, f = document.forms[0];

		if (f.src.value === '') {
			if (ed.selection.getNode().nodeName == 'IMG') {
				ed.dom.remove(ed.selection.getNode());
				ed.execCommand('mceRepaint');
			}

			tinyMCEPopup.close();
			return;
		}

		if (tinyMCEPopup.getParam("accessibility_warnings", 1)) {
			if (!f.alt.value) {
				tinyMCEPopup.confirm(tinyMCEPopup.getLang('advimagescale_dlg.missing_alt'), function(s) {
					if (s)
						t.insertAndClose();
				});

				return;
			}
		}

		t.insertAndClose();
	},

	insertAndClose : function() {
				
		var ed = tinyMCEPopup.editor, f = document.forms[0], nl = f.elements, v, args = {}, el;

		tinyMCEPopup.restoreSelection();

		// Fixes crash in Safari
		if (tinymce.isWebKit)
			ed.getWin().focus();

		if (!ed.settings.inline_styles) {
			args = {
				//vspace_top : nl.vspace.value_top,
				//vspace_bottom : nl.vspace.value_bottom,
				vspace_top : nl.vspace_top.value,
				vspace_bottom : nl.vspace_bottom.value,
				hspace_left : nl.hspace.value_left,
				hspace_right : nl.hspace.value_right,
				border : nl.border.value,
				align : getSelectValue(f, 'align')
			};
		} else {
			// Remove deprecated values
			args = {
				vspace_top : '',
				vspace_bottom : '',
				hspace_left : '',
				hspace_right : '',
				border : '',
				align : ''
			};
		}
		//webkit fix
		if(nl.width.value == 0) nl.width.value = '';
		if(nl.height.value == 0) nl.height.value = '';
		
		if(nl.width.value > 695){
			nl.height.value = parseInt((nl.height.value / nl.width.value)*695,10);
			nl.width.value = 695;
		}
		var imgclass = '';
		if (nl.popup.checked == true){
		  imgclass = nl.popupoption.options[nl.popupoption.options.selectedIndex].value;
		}
		tinymce.extend(args, {
			src : nl.src.value,
			width : nl.width.value,
			height : nl.height.value,
			alt : nl.alt.value,
			title : nl.title.value,			
			style : nl.style.value,			
      'class' : imgclass // classes for image popups - IE need the quotes around class
		});

		el = ed.selection.getNode();

		if (el && el.nodeName == 'IMG') {
			ed.dom.setAttribs(el, args);
			//tinyMCEPopup.editor.plugins.caption.updateCaption(tinyMCEPopup.editor); 
		} else {
			ed.execCommand('mceInsertContent', false, '<img id="__mce_tmp" />', {skip_undo : 1});
			//this.wrapLinkElement(ed.dom.get('__mce_tmp'));
			ed.dom.setAttribs('__mce_tmp', args);
			ed.dom.setAttrib('__mce_tmp', 'id', '');
			ed.undoManager.add();
			
		}
		//tinyMCEPopup.editor.plugins.caption.updateCaption(tinyMCEPopup.editor); 
		tinyMCEPopup.close();
		
	},

	getAttrib : function(e, at) {
		var ed = tinyMCEPopup.editor, dom = ed.dom, v, v2;

		if (ed.settings.inline_styles) {
			switch (at) {
				case 'align':
					if (v = dom.getStyle(e, 'float'))
						return v;

					if (v = dom.getStyle(e, 'vertical-align'))
						return v;

					break;

				case 'hspace_left':
					v = dom.getStyle(e, 'margin-left')
					//v2 = dom.getStyle(e, 'margin-right');

					if (v /*&& v == v2*/)
						return parseInt(v.replace(/[^0-9]/g, ''));
					break;
					
				case 'hspace_right':
					v = dom.getStyle(e, 'margin-right')

					if (v)
						return parseInt(v.replace(/[^0-9]/g, ''));
					break;				

				case 'vspace_top':
					v = dom.getStyle(e, 'margin-top')
					if (v)
						return parseInt(v.replace(/[^0-9]/g, ''));

					break;
					
				case 'vspace_bottom':
					v = dom.getStyle(e, 'margin-bottom');
					if (v)
						return parseInt(v.replace(/[^0-9]/g, ''));

					break;

				case 'border':
					v = 0;

					tinymce.each(['top', 'right', 'bottom', 'left'], function(sv) {
						sv = dom.getStyle(e, 'border-' + sv + '-width');

						// False or not the same as prev
						if (!sv || (sv != v && v !== 0)) {
							v = 0;
							return false;
						}

						if (sv)
							v = sv;
					});

					if (v)
						return parseInt(v.replace(/[^0-9]/g, ''));

					break;
			}
		}

		if (v = dom.getAttrib(e, at))
			return v;

		return '';
	},
	
	setCaption : function(){
		//alert(img.html());
	},

	resetImageData : function() {
		var f = document.forms[0];

		f.elements.width.value = f.elements.height.value = '';
	},

	updateImageData : function(img, st) {
		var f = document.forms[0];

		if (!st) {
			f.elements.width.value = img.width;
			f.elements.height.value = img.height;
		}

		this.preloadImg = img;
	},

	changeAppearance : function() {
		var ed = tinyMCEPopup.editor, f = document.forms[0], img = document.getElementById('alignSampleImg');

		if (img) {
			if (ed.getParam('inline_styles')) {
				ed.dom.setAttrib(img, 'style', f.style.value);
			} else {
				img.align = f.align.value;
				img.border = f.border.value;
				img.hspace_left = f.hspace_left.value;
				img.hspace_right = f.hspace_right.value;
				img.vspace_top = f.vspace_top.value;
				img.vspace_bottom = f.vspace_bottom.value;
			}
		}
	},

	changeHeight : function() {
		var f = document.forms[0], tp, t = this;

		if (!f.constrain.checked || !t.preloadImg) {
			return;
		}

		if (f.width.value == "" || f.height.value == "")
			return;

		tp = (parseInt(f.width.value) / parseInt(t.preloadImg.width)) * t.preloadImg.height;
		f.height.value = tp.toFixed(0);
	},

	changeWidth : function() {
		var f = document.forms[0], tp, t = this;

		if (!f.constrain.checked || !t.preloadImg) {
			return;
		}

		if (f.width.value == "" || f.height.value == "")
			return;

		tp = (parseInt(f.height.value) / parseInt(t.preloadImg.height)) * t.preloadImg.width;
		f.width.value = tp.toFixed(0);
	},

	updateStyle : function(ty) {
		var dom = tinyMCEPopup.dom, st, v, f = document.forms[0], img = dom.create('img', {style : dom.get('style').value});

		if (tinyMCEPopup.editor.settings.inline_styles) {
			// Handle align
			if (ty == 'align') {
				dom.setStyle(img, 'float', '');
				dom.setStyle(img, 'vertical-align', '');

				v = getSelectValue(f, 'align');
				if (v) {
					if (v == 'left' || v == 'right')
						dom.setStyle(img, 'float', v);
					else
						img.style.verticalAlign = v;
				}
			}

			// Handle border
			if (ty == 'border') {
				dom.setStyle(img, 'border', '');

				v = f.border.value;
				if (v || v == '0') {
					if (v == '0')
						img.style.border = '0';
					else
						img.style.border = v + 'px solid black';
				}
			}

			// Handle hspace
			if (ty == 'hspace_left') {
				dom.setStyle(img, 'marginLeft', '');

				v = f.hspace_left.value;
				if (v ) { //|| v == '0') {
					//if (v == '0')
					//	img.style.marginLeft = '0';
					//else
						img.style.marginLeft = v + 'px';
				}
			}
			if (ty == 'hspace_right') {
				dom.setStyle(img, 'marginRight', '');

				v = f.hspace_right.value;
				if (v) {
					img.style.marginRight = v + 'px';
				}
			}

			// Handle vspace
			if (ty == 'vspace_top') {
				dom.setStyle(img, 'marginTop', '');

				v = f.vspace_top.value;
				if (v) {
					img.style.marginTop = v + 'px';
				}
			}
			if (ty == 'vspace_bottom') {
				dom.setStyle(img, 'marginBottom', '');

				v = f.vspace_bottom.value;
				if (v) {
					img.style.marginBottom = v + 'px';
				}
			}

			// Merge
			dom.get('style').value = dom.serializeStyle(dom.parseStyle(img.style.cssText));
		}
	},

	changeMouseMove : function() {
	},

	showPreviewImage : function(u, st) {
		if (!u) {
			tinyMCEPopup.dom.setHTML('prev', '');
			return;
		}

		if (!st && tinyMCEPopup.getParam("advimage_update_dimensions_onchange", true))
			this.resetImageData();

		u = tinyMCEPopup.editor.documentBaseURI.toAbsolute(u);

		if (!st)
			tinyMCEPopup.dom.setHTML('prev', '<img id="previewImg" src="' + u + '" border="0" onload="ImageDialog.updateImageData(this);" onerror="ImageDialog.resetImageData();" />');
		else
			tinyMCEPopup.dom.setHTML('prev', '<img id="previewImg" src="' + u + '" border="0" onload="ImageDialog.updateImageData(this, 1);" />');
	}
};

ImageDialog.preInit();
tinyMCEPopup.onInit.add(ImageDialog.init, ImageDialog);
