// Image Tablropertiese Plugin for HTMLArea-3.0
// Implementation by Sergey Nikulin.
//
// htmlArea v3.0 - Copyright (c) 2002 interactivetools.com, inc.
// This notice MUST stay intact for use (see license.txt).
//
// A free WYSIWYG editor replacement for <textarea> fields.
// For full source code and docs, visit http://www.interactivetools.com/
//
// Version 3.0 developed by Mihai Bazon for InteractiveTools.
//	     http://students.infoiasi.ro/~mishoo
//
// $Id$

function ImageProperties (editor) {
	this.editor = editor;

	var cfg = editor.config;
	var tt = ImageProperties.I18N;
	var bl = ImageProperties.btnList;
	var self = this;

	// register the toolbar buttons provided by this plugin
	var btn = bl[0];
	var id = "IP-" + 'image-prop';
	cfg.registerButton(id, tt[id], editor.imgURL("image-prop.gif","ImageProperties"), false,
			   function(editor, id) {
				   // dispatch button press event
				   self.buttonPress(editor, id);
			   });

	var t = editor.config.toolbar;
	for (var i = 0; i < t.length; i++) {
	for (var x = 0; x < t[i].length; x++) {
	  if (t[i][x] == 'insertimage') {
		t[i].splice(x+1, 0, id);
		break;
	  }
	}
	}

};

/************************
 * UTILITIES
 ************************/

// retrieves the closest element having the specified tagName in the list of
// ancestors of the current selection/caret.
ImageProperties.prototype.getClosest = function(tagName) {
	var editor = this.editor;
	var ancestors = editor.getAllAncestors();
	var ret = null;
	tagName = ("" + tagName).toLowerCase();
	for (var i in ancestors) {
		var el = ancestors[i];
		alert (el.tagName.toLowerCase());
		if (el.tagName.toLowerCase() == tagName) {
			ret = el;
			break;
		}
	}
	return ret;
};

// this function requires the file PopupDiv/PopupWin to be loaded from browser
ImageProperties.prototype.dialogImageProperties = function() {
	var i18n = ImageProperties.I18N;
	// retrieve existing values
	var images = editor._doc.body.getElementsByTagName ("img");
	if (images.length == 0) {
		alert (i18n["No images in current document"]);
		return false;
	}
	var i = 0;
	var image = images[i];
	
// this function gets called when the dialog needs to be initialized
	initDialogImageProperties = function (dialog) {
		var f_width = parseInt(image.style.width);
		isNaN(f_width) && (f_width = "");
		var f_unit = /%/.test(image.style.width) ? 'percent' : 'pixels';
		var f_align = image.align;
		var f_borders = image.border;
		var f_alttext = image.alt;
		var f_titletext = image.title;

		var thumbWidth = 100;
		var thumbHeight = (100 / image.width) * image.height;

		if (thumbHeight > 100) {
			thumbHeight = 100;
			thumbWidth = (100 / image.height) * image.width;
		}

		function selected(val) {
			return val ? " selected" : "";
		};

		// dialog contents
		dialog.content.style.width = "300px";
		dialog.content.innerHTML = " \
<div class='title'\
 style='background: url(" + dialog.baseURL + dialog.editor.imgURL("image-prop.gif", "ImageProperties") + ") #fff 98% 50% no-repeat'>" + i18n["Images Properties"] + "\
</div> \
<table style='width:100%'> \
	<tr> \
		<td width='100' height='100'><img src='" + image.src + "' width='" + thumbWidth + "' height='" + thumbHeight + "' id='thumbnail'></td> \
		<td id='--HA-prev-img'></td> \
		<td id='--HA-next-img'></td> \
	</tr> \
</table> \
<table style='width:100%'> \
  <tr> \
    <td> \
      <fieldset><legend>" + i18n["Description"] + "</legend> \
       <table style='width:100%'> \
        <tr> \
          <td class='label'>" + i18n["Alt text"] + ":</td> \
          <td class='value'><input type='text' name='f_alttext' value='" + f_alttext + "'/></td> \
        </tr><tr> \
          <td class='label'>" + i18n["Title text"] + ":</td> \
          <td class='value'><input type='text' name='f_titletext' value='" + f_titletext + "'/></td> \
        </tr> \
       </table> \
      </fieldset> \
    </td> \
  </tr> \
  <tr><td id='--HA-layout'></td></tr> \
	<tr><td id='--HA-spacing'></td></tr> \
</table> \
";
		var st_layout = ImageProperties.createStyleLayoutFieldset(dialog.doc, dialog.editor, image);
		p = dialog.doc.getElementById("--HA-layout");
		p.appendChild(st_layout);

		var st_spacing = ImageProperties.createSpacingFieldset(dialog.doc, dialog.editor, image);
		p = dialog.doc.getElementById("--HA-spacing");
		p.appendChild(st_spacing);

		p = dialog.doc.getElementById("--HA-prev-img");
		var button = dialog.doc.createElement("button");
		p.appendChild(button);
		button.innerHTML = i18n["Prev"];
		button.onclick = function() {
			if (i > 0) i--;
			else i = images.length - 1;
			image = images[i];
			initDialogImageProperties (dialog);
			return false;
		};

		p	= dialog.doc.getElementById("--HA-next-img");
		button = dialog.doc.createElement("button");
		p.appendChild(button);
		button.innerHTML = i18n["Next"];
		button.onclick = function() {
			if (i < images.length - 1) i++;
			else i = 0;
			image = images[i];
			initDialogImageProperties (dialog);
			return false;
		};
		
		dialog.modal = true;
		dialog.addButtons("ok", "cancel");
		dialog.showAtElement(dialog.editor._iframe, "c");
	}
	
	var dialog = new PopupWin(this.editor, i18n["Image Properties"], function(dialog, params) {
		for (var i in params) {
			var val = params[i];
			switch (i) {
			    case "f_alttext":
				image.alt = val;
				break;
					case "f_titletext":
				image.title = val;
				break;
					case "f_st_align":
				image.align = val;
				break;
					case "f_st_hspace":
				image.hspace = val;
				break;
					case "f_st_vspace":
				image.vspace = val;
				break;
				case "f_st_width"  :
				         var width = parseInt(val || "0");
					 if ( width > 0 ) 
					     image.style.width = width;
					 break;
				case "f_st_height"  :
				         var height = parseInt(val || "0");
					 if ( height > 0 ) 
					     image.style.height = height;
					 break;
			    case "f_st_border" : img.border = parseInt(value || "0"); break;
			}
		}
		// various workarounds to refresh the table display (Gecko,
		// what's going on?! do not disappoint me!)
		dialog.editor.forceRedraw();
		dialog.editor.focusEditor();
		dialog.editor.updateToolbar();
	},
	function (dialog) {initDialogImageProperties (dialog);}
	);
};

// this function gets called when some button from the ImageProperties toolbar
// was pressed.
ImageProperties.prototype.buttonPress = function(editor, button_id) {
	this.editor = editor;
	var mozbr = HTMLArea.is_gecko ? "<br />" : "";
	var i18n = ImageProperties.I18N;
	
	switch (button_id) {
		// PROPERTIES
	    case "IP-image-prop":
		this.dialogImageProperties();
		break;

	    default:
		alert("Button [" + button_id + "] not yet implemented");
	}
};

// the list of buttons added by this plugin
ImageProperties.btnList = [
	// Image properties button
	null,
	["image-prop"]
	];



//// GENERIC CODE [style of any element; this should be moved into a separate
//// file as it'll be very useful]
//// BEGIN GENERIC CODE -----------------------------------------------------

ImageProperties.getLength = function(value) {
	var len = parseInt(value);
	if (isNaN(len)) {
		len = "";
	}
	return len;
};



ImageProperties.createStyleLayoutFieldset = function(doc, editor, el) {
	var i18n = ImageProperties.I18N;
	var fieldset = doc.createElement("fieldset");
	var legend = doc.createElement("legend");
	fieldset.appendChild(legend);
	legend.innerHTML = i18n["Layout"];
	var table = doc.createElement("table");
	fieldset.appendChild(table);
	table.style.width = "100%";
	var tbody = doc.createElement("tbody");
	table.appendChild(tbody);

	var tagname = el.tagName.toLowerCase();
	var tr, td, input, select, option, options, i;

	if (tagname != "td" && tagname != "tr" && tagname != "th") {
		tr = doc.createElement("tr");
		tbody.appendChild(tr);
		td = doc.createElement("td");
		td.className = "label";
		tr.appendChild(td);
		td.innerHTML = i18n["Alignment"] + ":";
		td = doc.createElement("td");
		tr.appendChild(td);
		select = doc.createElement("select");
		td.appendChild(select);
		select.name = "f_st_align";
		options = ["left", "right", "texttop", "absmiddle", "baseline", "absbottom", "bottom", "middle", "top"];
		if (el.align == "") el.align = "baseline";
		for (i in options) {
			var Val = options[i];
			var val = options[i].toLowerCase();
			option = doc.createElement("option");
			option.innerHTML = i18n[Val];
			option.value = val;
			option.selected = (("" + el.align).toLowerCase() == val);
			select.appendChild(option);
		}
	}

	tr = doc.createElement("tr");
	tbody.appendChild(tr);
	td = doc.createElement("td");
	td.className = "label";
	tr.appendChild(td);
	td.innerHTML = i18n["Width"] + ":";
	td = doc.createElement("td");
	tr.appendChild(td);
	input = doc.createElement("input");
	input.type = "text";
	input.value = ImageProperties.getLength(el.style.width);
	input.size = "5";
	input.name = "f_st_width";
	input.style.marginRight = "0.5em";
	td.appendChild(input);
//	select = doc.createElement("select");
//	select.name = "f_st_widthUnit";
//	option = doc.createElement("option");
//	option.innerHTML = i18n["percent"];
//	option.value = "%";
//	option.selected = /%/.test(el.style.width);
//	select.appendChild(option);
//	option = doc.createElement("option");
//	option.innerHTML = i18n["pixels"];
//	option.value = "px";
//	option.selected = /px/.test(el.style.width);
//	select.appendChild(option);
//	td.appendChild(select);
//	select.style.marginRight = "0.5em";

	tr = doc.createElement("tr");
	tbody.appendChild(tr);
	td = doc.createElement("td");
	td.className = "label";
	tr.appendChild(td);
	td.innerHTML = i18n["Height"] + ":";
	td = doc.createElement("td");
	tr.appendChild(td);
	input = doc.createElement("input");
	input.type = "text";
	input.value = ImageProperties.getLength(el.style.height);
	input.size = "5";
	input.name = "f_st_height";
	input.style.marginRight = "0.5em";
	td.appendChild(input);
//	select = doc.createElement("select");
//	select.name = "f_st_heightUnit";
//	option = doc.createElement("option");
//	option.innerHTML = i18n["percent"];
//	option.value = "%";
//	option.selected = /%/.test(el.style.height);
//	select.appendChild(option);
//	option = doc.createElement("option");
//	option.innerHTML = i18n["pixels"];
//	option.value = "px";
//	option.selected = /px/.test(el.style.height);
//	select.appendChild(option);
//	td.appendChild(select);

	return fieldset;
};

// Returns an HTML element containing the style attributes for the given
// element.  This can be easily embedded into any dialog; the functionality is
// also provided.
ImageProperties.createSpacingFieldset = function(doc, editor, el) {
	var i18n = ImageProperties.I18N;
	var fieldset = doc.createElement("fieldset");
	var legend = doc.createElement("legend");
	fieldset.appendChild(legend);
	legend.innerHTML = i18n["Spacing"];
	var table = doc.createElement("table");
	fieldset.appendChild(table);
	table.style.width = "100%";
	var tbody = doc.createElement("tbody");
	table.appendChild(tbody);

	tr = doc.createElement("tr");
	tbody.appendChild(tr);
	td = doc.createElement("td");
	td.className = "label";
	tr.appendChild(td);
	td.innerHTML = i18n["Horizontal"] + ":";
	td = doc.createElement("td");
	tr.appendChild(td);
	input = doc.createElement("input");
	input.type = "text";
	input.value = ImageProperties.getLength(el.hspace);
	input.size = "5";
	input.name = "f_st_hspace";
	input.style.marginRight = "0.5em";
	td.appendChild(input);

	tr = doc.createElement("tr");
	tbody.appendChild(tr);
	td = doc.createElement("td");
	td.className = "label";
	tr.appendChild(td);
	td.innerHTML = i18n["Vertical"] + ":";
	td = doc.createElement("td");
	tr.appendChild(td);
	input = doc.createElement("input");
	input.type = "text";
	input.value = ImageProperties.getLength(el.vspace);
	input.size = "5";
	input.name = "f_st_vspace";
	input.style.marginRight = "0.5em";
	td.appendChild(input);
	
	return fieldset;
};

ImageProperties._pluginInfo = {
	name          : "ImageProperties",
	version       : "1.0",
	developer     : "Sergey Nikulin",
	developer_url : "",
	sponsor       : "",
	sponsor_url   : "",
	license       : "htmlArea"
};


//// END GENERIC CODE -------------------------------------------------------
