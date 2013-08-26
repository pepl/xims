/**
 * @author Susanne Tober
 */

tinyMCEPopup.requireLangPack();
//var settings;
 var CaptionDialog = {
 	preInit : function() {
		var url;

		//tinyMCEPopup.requireLangPack();

		/*if (url = tinyMCEPopup.getParam("external_image_list_url"))
			document.write('<script language="javascript" type="text/javascript" src="' + tinyMCEPopup.editor.documentBaseURI.toAbsolute(url) + '"></script>');
			*/
	},		
	init: function(ed){
		settings = {
			wrapperElement: 'div',
			wrapperClass: 'caption',
			captionElement: 'p',
			imageAttr: 'alt',
			requireText: true,
			copyStyle: false,
			removeStyle: true,
			removeAlign: true,
			copyAlignmentToClass: false,
			copyFloatToClass: true,
			autoWidth: true,
			animate: false,
			show: {opacity: 'show'},
			showDuration: 200,
			hide: {opacity: 'hide'},
			hideDuration: 200	
		};
		var image = $(ed.selection.getNode());
		if (image.parent().hasClass('caption')) {
			$('form #insert').val(ed.getLang('update'));
		}
		//applyCaption(ed.selection);
	},
		applyCaption: function(){
			var settings = {
				wrapperElement: 'div',
				wrapperClass: 'caption',
				captionElement: 'p',
				imageAttr: 'alt',
				copyStyle: true,
				removeStyle: true,
				removeAlign: true,
				copyAlignmentToClass: false,
				copyFloatToClass: true,
				autoWidth: true,
			};
			var ed = tinyMCEPopup.editor;
			var image = $(ed.selection.getNode());
			var captiontext = '';
			if ($('form #caption_text').val()) {
				captiontext = $('form #caption_text').val();
			}
			else {
				captiontext = image.attr(settings.imageAttr);
			}
				
			if (image.parent().hasClass('caption')) {
				//update caption				
				var ctextStyle = "padding:2px;text-align:" + $('form #caption_alignment').val() + ";"
				var ctextFormat = $('form #caption_text_style').val();
				if (ctextFormat != 'default') {
					captiontext = "<" + ctextFormat + ">" + captiontext + "</" + ctextFormat + ">";
				}
				image.next().replaceWith('<' + settings.captionElement + ' class="captiontext" style=' + ctextStyle + '>' + captiontext + '</' + settings.captionElement + '>');
				if (settings.removeStyle){ 
					image.removeAttr('style');
					image.removeAttr('_mce_style');
				}			
			}
			else {
				//create caption

				//wrap image with caption div
				image.wrap("<" + settings.wrapperElement + " class='" + settings.wrapperClass + "'></" + settings.wrapperElement + ">");
				
				//save image style
				var imageStyle = image.attr('style') + image.attr('_mce_style');
				if (settings.removeStyle) 
					image.removeAttr('style');
				
				//add caption text
				var ctextStyle = "padding:2px;text-align:" + $('form #caption_alignment').val() + ";"
				var ctextFormat = $('form #caption_text_style').val();
				if (ctextFormat != 'default') {
					captiontext = "<" + ctextFormat + ">" + captiontext + "</" + ctextFormat + ">";
				}
				var div = image.parent().append('<' + settings.captionElement + ' class="captiontext" style=' + ctextStyle + '>' + captiontext + '</' + settings.captionElement + '>');
				
				//set old image styles to div
				div.attr('style', imageStyle); //image.attr('style'));
				div.width(image.width());
				div.height('');
				//append empty paragraph so users can still put content behind the div 
				div.append('<p> </p>');
			}
				tinyMCEPopup.close();
		},
		removeCaption: function(){
			var ed = tinyMCEPopup.editor;
			var image = $(ed.selection.getNode());
			var parent = $(image).parent();
			while (!parent.hasClass('caption')) {
				parent = parent.parent();
			}
			style = parent.attr('style');
			style = style.substr(0,style.indexOf('width')-1);
			image.attr('style', style);
			image.unwrap();
			image.next().remove();
			tinyMCEPopup.close();
		},
		setValues: function(){
			//alert("setting values");
			var ed = tinyMCEPopup.editor;
			var image = $(ed.selection.getNode());
			var caption = image.next();
			var captiontext = '';
			if(caption.is('p')){
				$('form #caption_alignment').val(caption.css('text-align')) ? caption.css('text-align') : $('form #caption_alignment').val('default'); 
				if(caption.contents().is('em')){
					$('form #caption_text_style').val('em');
					captiontext = caption.contents().html();
				}
				else if(caption.contents().is('b')){
					$('form #caption_text_style').val('b');
					captiontext = caption.contents().html();
				}
				else{
					$('form #caption_text_style').val('default');
					captiontext = caption.html();
				}
			}
			else{
				captiontext = image.attr('alt');
			}
			$('form #caption_text').val(captiontext);
			
			
		}
	};
CaptionDialog.preInit();
tinyMCEPopup.onInit.add(CaptionDialog.init, CaptionDialog);


