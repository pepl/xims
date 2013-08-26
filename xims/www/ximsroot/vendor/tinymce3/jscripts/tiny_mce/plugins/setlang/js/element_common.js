/**
 * element_common.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

tinyMCEPopup.requireLangPack();

function initCommonAttributes(elm) {
	
	
	var formObj = document.forms[0], dom = tinyMCEPopup.editor.dom;

	// Setup form data for common element attributes
	selectByValue(formObj, 'class', dom.getAttrib(elm, 'class'), true);
	setFormValue('lang', dom.getAttrib(elm, 'lang'));
	//setFormValue('hreflang', dom.getAttrib(elmNode, 'hreflang'));
	setFormValue('xml:lang', dom.getAttrib(elm, 'xml:lang'));
	setFormValue('onfocus', dom.getAttrib(elm, 'onfocus'));
	setFormValue('onblur', dom.getAttrib(elm, 'onblur'));
	setFormValue('onclick', dom.getAttrib(elm, 'onclick'));
	setFormValue('ondblclick', dom.getAttrib(elm, 'ondblclick'));
	setFormValue('onmousedown', dom.getAttrib(elm, 'onmousedown'));
	setFormValue('onmouseup', dom.getAttrib(elm, 'onmouseup'));
	setFormValue('onmouseover', dom.getAttrib(elm, 'onmouseover'));
	setFormValue('onmousemove', dom.getAttrib(elm, 'onmousemove'));
	setFormValue('onmouseout', dom.getAttrib(elm, 'onmouseout'));
	setFormValue('onkeypress', dom.getAttrib(elm, 'onkeypress'));
	setFormValue('onkeydown', dom.getAttrib(elm, 'onkeydown'));
	setFormValue('onkeyup', dom.getAttrib(elm, 'onkeyup'));
}

function setFormValue(name, value) {
	if(document.forms[0].elements[name]) {
		document.forms[0].elements[name].value = value;
	}
}

function insertDateTime(id) {
	document.getElementById(id).value = getDateTime(new Date(), "%Y-%m-%dT%H:%M:%S");
}

function getDateTime(d, fmt) {
	fmt = fmt.replace("%D", "%m/%d/%y");
	fmt = fmt.replace("%r", "%I:%M:%S %p");
	fmt = fmt.replace("%Y", "" + d.getFullYear());
	fmt = fmt.replace("%y", "" + d.getYear());
	fmt = fmt.replace("%m", addZeros(d.getMonth()+1, 2));
	fmt = fmt.replace("%d", addZeros(d.getDate(), 2));
	fmt = fmt.replace("%H", "" + addZeros(d.getHours(), 2));
	fmt = fmt.replace("%M", "" + addZeros(d.getMinutes(), 2));
	fmt = fmt.replace("%S", "" + addZeros(d.getSeconds(), 2));
	fmt = fmt.replace("%I", "" + ((d.getHours() + 11) % 12 + 1));
	fmt = fmt.replace("%p", "" + (d.getHours() < 12 ? "AM" : "PM"));
	fmt = fmt.replace("%%", "%");

	return fmt;
}

function addZeros(value, len) {
	var i;

	value = "" + value;

	if (value.length < len) {
		for (i=0; i<(len-value.length); i++)
			value = "0" + value;
	}

	return value;
}

function selectByValue(form_obj, field_name, value, add_custom, ignore_case) {
	if (!form_obj || !form_obj.elements[field_name])
		return;

	var sel = form_obj.elements[field_name];

	var found = false;
	for (var i=0; i<sel.options.length; i++) {
		var option = sel.options[i];

		if (option.value == value || (ignore_case && option.value.toLowerCase() == value.toLowerCase())) {
			option.selected = true;
			found = true;
		} else
			option.selected = false;
	}

	if (!found && add_custom && value != '') {
		var option = new Option('Value: ' + value, value);
		option.selected = true;
		sel.options[sel.options.length] = option;
	}

	return found;
}

function setAttributes(elm, attrib, value) {
	var formObj = document.forms[0];
	var valueElem = formObj.elements[attrib.toLowerCase()];
	tinyMCEPopup.editor.dom.setAttrib(elm, attrib, value || valueElem.value);
}

function setAllCommonAttribs(elm) {
	setAttributes(elm, 'class', 'lang');
	setAttributes(elm, 'lang');
	setAttributes(elm, 'xml:lang');
}

//global Object SXE (JSON)
SXE = {
	currentAction : "insert",
	inst : tinyMCEPopup.editor,
	updateElement : null
}

SXE.focusElement = SXE.inst.selection.getNode();

function initTagElement(element_name) {
	
	addClassesToList('class', 'setlang_styles');

	element_name = element_name.toLowerCase();
	//elm = parent tag of focused/selected element
	var elm = SXE.inst.dom.getParent(SXE.focusElement, element_name.toUpperCase());
	//if element exists and the class "lang", it is possible to update and delete it
	if (elm != null && (SXE.containsClass(elm,'lang')) && elm.nodeName.toUpperCase() == element_name.toUpperCase()) {
		SXE.currentAction = "update";
	}
	if (SXE.currentAction == "update") {
		initCommonAttributes(elm);
		SXE.updateElement = elm;
	}
	//sets the value of the Submit-Button to "Insert" or "Update", depending on selected language and existence of attributes
	document.forms[0].insert.value = tinyMCEPopup.getLang(SXE.currentAction, 'Insert', true);	
}

function insertTagElement(element_name) {
	var elm = SXE.inst.dom.getParent(SXE.focusElement, element_name.toUpperCase()), h, tagName;
	
	tinyMCEPopup.execCommand('mceBeginUndoLevel');
	//if no parent of focused Element is found
	if (elm == null) {
		var s = SXE.inst.selection.getContent();
		if(s.length > 0) {
			tagName = element_name;
			insertInlineElement(element_name);
			//filter items with name [element_name] and save in elementArray (e.g. all span-Elements)
			var elementArray = tinymce.grep(SXE.inst.dom.select(element_name));
			//loop Array..
			for (var i=0; i<elementArray.length; i++) {
				//store filtered elements in variable "elm"
				var elm = elementArray[i];
				//check if elm has attribute "_mce_new"
				if (SXE.inst.dom.getAttrib(elm, '_mce_new')) {
					//set attributes and check if not empty
					setAllCommonAttribs(elm);
					//if no language attributes are set, might as well delete the span-Tag and class attribute
					if(SXE.containsClass(elm, 'lang') && elm == emptyValues(elm)){
						tinyMCEPopup.execCommand('mceBeginUndoLevel');
						if(tinyMCE.isWebKit){
							//alert("_mce_new set on element " + elm.nodeName + "? " + SXE.inst.dom.getAttrib(elm, '_mce_new'));
							//tinyMCE.execCommand('mceRemoveNode', false, elm);		//Chrome & Safari (Webkit) delete wrong item (selection box) instead of recently created, empty span tag with class="lang"
							return;
						}
						else {	//keeps child elements and content of node but deletes node itself
								tinyMCE.execCommand('mceRemoveNode', false, elm);
							} 
						
						SXE.inst.nodeChanged();
						tinyMCEPopup.execCommand('mceEndUndoLevel');
						//alert("elm deleted");
					}
					//remove and delete id and _mce_new attribute if attributes are set
					elm.id = '';
					elm.setAttribute('id', '');
					elm.removeAttribute('id');
					elm.removeAttribute('_mce_new');
				}
			}
		}
	} else {
		setAllCommonAttribs(elm);
	}
	
	SXE.inst.nodeChanged();
	tinyMCEPopup.execCommand('mceEndUndoLevel');
}

SXE.removeElement = function(element_name){
	element_name = element_name.toLowerCase();
	elm = SXE.inst.dom.getParent(SXE.focusElement, element_name.toUpperCase());
	if(elm && elm.nodeName.toUpperCase() == element_name.toUpperCase()){
		tinyMCEPopup.execCommand('mceBeginUndoLevel');
		tinyMCE.execCommand('mceRemoveNode', false, elm);
		SXE.inst.nodeChanged();
		tinyMCEPopup.execCommand('mceEndUndoLevel');
	}
}

SXE.showRemoveButton = function() {
		document.getElementById("remove").style.display = '';
}

SXE.containsClass = function(elm,cl) {
	return (elm.className.indexOf(cl) > -1) ? true : false;
}

SXE.removeClass = function(elm,cl) {
	if(elm.className == null || elm.className == "" || !SXE.containsClass(elm,cl)) {
		return true;
	}
	var classNames = elm.className.split(" ");
	var newClassNames = "";
	for (var x = 0, cnl = classNames.length; x < cnl; x++) {
		if (classNames[x] != cl) {
			newClassNames += (classNames[x] + " ");
		}
	}
	elm.className = newClassNames.substring(0,newClassNames.length-1); //removes extra space at the end
}

SXE.addClass = function(elm,cl) {
	if(!SXE.containsClass(elm,cl)) elm.className ? elm.className += " " + cl : elm.className = cl;
	return true;
}

//checks if none of the available attributes has been set to delete an empty span-Tag later
function emptyValues(e) {
	if((SXE.inst.dom.getAttrib(e, 'lang') == "") && (SXE.inst.dom.getAttrib(e, 'xml:lang') == "") && (SXE.inst.dom.getAttrib(e, 'hreflang') == "")){
		return e;
	}	
}

//Wraps <span>-Tag around selected text to later add class=lang
function insertInlineElement(en) {
	var ed = tinyMCEPopup.editor, dom = ed.dom;
	//set FontName to "mceinline"
	ed.getDoc().execCommand('FontName', false, 'mceinline');
	//Iterate dom.select-Array where span/font-attribute exists and exec function(n) when true
	tinymce.each(dom.select('span,font'), function(n) {
		//when font is "Mceinline"
		if (n.style.fontFamily == 'mceinline' || n.face == 'mceinline'){
			//replace old element "n" with new created "en" and set "_mce_new" Attribute to true
			dom.replace(dom.create(en, {_mce_new : 1}), n, 1);
		}
	});
}
