var AdvHRDialog = {
	init : function(ed) {
		var dom = ed.dom, f = document.forms[0], n = ed.selection.getNode(), w, hr;
		
		hr = $(ed.selection.getNode());
		if (hr.is('hr')) {
			w = hr.css('width');
			f.alignment.value = hr.css('text-align') || 'center';
			f.width2.value = (w.indexOf('%') != -1) ? '%' : 'px';
			w.replace('px', '').replace('%', '');
			f.width.value = parseInt(w);
		}
		else{
			f.alignment.value = 'center'; 
			f.width2.value = 'px';
			f.width.value = '';
			
		}
	},

	update : function() {
		var ed = tinyMCEPopup.editor, h, f = document.forms[0], st = '';

		h = '<hr';

		if (f.width.value) {
			//h += ' width="' + f.width.value + (f.width2.value == '%' ? '%' : '') + '"';
			st += ' width:' + f.width.value + (f.width2.value == '%' ? '%' : 'px') + ';';
		}
		if (f.alignment.value) {
			//h += ' width="' + f.width.value + (f.width2.value == '%' ? '%' : '') + '"';
			st += ' text-align:' + f.alignment.value + ';';
			if(f.alignment.value == 'left'){
				st += ' margin: 0 auto 0 0';
			}
			else if(f.alignment.value == 'right'){
				st += ' margin: 0 0 0 auto;';
			}
		}

		//if (ed.settings.inline_styles)
			h += ' style="' + tinymce.trim(st) + '"';

		h += ' />';

		ed.execCommand("mceInsertContent", false, h);
		tinyMCEPopup.close();
	}
};

tinyMCEPopup.requireLangPack();
tinyMCEPopup.onInit.add(AdvHRDialog.init, AdvHRDialog);
