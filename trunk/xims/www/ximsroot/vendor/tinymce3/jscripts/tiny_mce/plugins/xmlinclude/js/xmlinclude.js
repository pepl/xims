/* Functions for the xmlinclude plugin popup */

tinyMCEPopup.requireLangPack();

var templates = {
	"window.open" : "window.open('${url}','${target}','${options}')"
};

function init() {
	tinyMCEPopup.resizeToInnerSize();
	var formObj = document.forms[0];
	var inst = tinyMCEPopup.editor;
	var elm = inst.selection.getNode();
	var action = "insert";
	var ed = tinyMCEPopup.editor;
	
	//for IE, set focus on first input element of form
	document.forms[0].href.focus();
	//document.getElementById('srcbrowsercontainer').innerHTML = getBrowserHTML('hrefbrowser','href','image','advanced_image');

	// Resize some elements
	if (isVisible('urlbrowser'))
	{
		document.getElementById('href').style.width = '260px';
	}
	
	elm = inst.dom.getParent(elm, "SPAN");
	if (elm != null && elm.nodeName == "SPAN" && elm.className == "xml_include")
	{
		action = ed.getLang('update');
	}

	formObj.insert.value = tinyMCEPopup.getLang('insert');
	
	//retrieve previously inserted data for update
	if (action == ed.getLang('update')) {
		tinyMCEPopup.execCommand('mceBeginUndoLevel');
		var url = inst.dom.getAttrib(elm, 'title');
		var onclick = inst.dom.getAttrib(elm, 'onclick');
		//var linktitle = inst.dom.getAttrib(elm, 'id');
		//var linktitle = elm.childNodes[0].innerHTML;
	var linktitle = elm.innerHTML;
	var classes = inst.dom.getAttrib(elm, 'class');
		var urlArray = splitURL(url);
		//alert(url);
		var urlxml = urlArray[0];
		var xpointer = urlArray[1];
		/*if(!inst.dom.getAttrib(elm, 'id'))
		{
			//alert(elm.innerHTML);
			alert(elm.childNodes[0].innerHTML);
			linktitle = elm.childNodes[0].innerHTML;
		}*/
		// Setup form data
		//NOT REAL TITLE - ONLY URL TO THE XML FILE, but stored in 'title'
		setFormValue('href', urlxml);
		//the xpointer expression (if set)
		if(xpointer)
		{
			setFormValue('xpointer', xpointer);
		}
		//THIS IS FOR THE actual TITLE
		setFormValue('linktitle', linktitle);
		formObj.insert.value = ed.getLang('update');
		//Entfernen-Button anzeigen wenn entfernbare Sprachattribute vorhanden
		document.getElementById('remove').style.display = 'inline';
		tinyMCEPopup.execCommand("mceEndUndoLevel");
	}
	//prefill form when inserting new element
	else {
		if(!inst.selection.isCollapsed())
		{
			setFormValue("linktitle", inst.selection.getContent({format : 'text'}));
		}
		else
		{
			setFormValue("linktitle", "-[XML Document]-");
		}
	}
}

function insertAction() {
	tinyMCEPopup.execCommand('mceBeginUndoLevel');
	//variables
	var status = document.forms[0].insert.value;
	var inst = tinyMCEPopup.editor;
	var elm, elementArray, i, selected;
	var element_name = 'span';
	var collapsed = inst.selection.isCollapsed();
	//get selected node, check prefix
	checkPrefix(document.forms[0].href);

	//get parent of selected node
	elm = inst.dom.getParent(inst.selection.getNode(), element_name.toUpperCase());
	
	if(elm == null)
	{
		//no update, just inserting element the first time
		if(status == inst.getLang('insert'))
		{
			//tagName = element_name;
			if (tinyMCE.activeEditor.selection.isCollapsed())
			{
				selected = collapsedInsertInlineElement(element_name);
			}
			else
			{
				selected = insertInlineElement(element_name);
				//insertInlineElement(element_name);
			}
		}
		//filter items with name [element_name] and save in elementArray (e.g. all span-Elements)
		var elementArray = tinymce.grep(inst.dom.select(element_name));
		//loop Array..
		for (var i=0; i<elementArray.length; i++) {
			//store filtered elements in variable "elm"
			var elm = elementArray[i];
			//check if elm has attribute "_mce_new"
			if (inst.dom.getAttrib(elm, '_mce_new') || (elm.id == '_mce_new')) {
				//remove and delete id and _mce_new attribute if attributes are set
				elm.id = '';
				elm.setAttribute('id', '');
				elm.removeAttribute('id');
				elm.removeAttribute('_mce_new');
			}
			//Temporary fix
			if (tinymce.isIE)
			{
				addClass(elm, 'xml_include');
			}
		}
	}
	else 
	{
		selected = elm;
	}
	setAllAttribs(selected);
	
	// Remove element if there is no url in first form of popup (title-textbox)
	if (!document.forms[0].href.value) {
		tinyMCEPopup.execCommand("mceEndUndoLevel");
		if(collapsed && status == "Insert")
		{
			selected.innerHTML = "";
		}
		tinyMCEPopup.execCommand("mceBeginUndoLevel");
		inst.dom.remove(selected, true);
		tinyMCEPopup.execCommand("mceEndUndoLevel");
	}
	
	tinyMCE.activeEditor.selection.collapse(false);
	inst.nodeChanged();
	tinyMCEPopup.execCommand("mceEndUndoLevel");
	tinyMCEPopup.close();
}

//inserts <span>-Tag at cursor position, returns recently inserted, selected element
function collapsedInsertInlineElement(element_name)
{                                                                                                                                          
	var elmname = element_name.toLowerCase();
	var ed = tinyMCE.activeEditor;
	var desctext = "", textblock, selectedElm;
	if (document.forms[0].linktitle.value)
	{
		desctext = document.forms[0].linktitle.value;
	}
	else 
	{
		desctext = "-[XML Document]-";
	}
	textblock = '<' + elmname + ' _mce_new id = "_mce_new" class = "xml_include" >' + desctext + '</' + elmname + '>';
	tinyMCEPopup.execCommand('mceInsertContent', false, textblock);
	selectedElm = ed.selection.select(ed.dom.get("_mce_new"));
	return selectedElm;
}

//Wraps <span>-Tag around selected text to later add attributes
function insertInlineElement(en) {
	var ed = tinyMCEPopup.editor, elm;
	//set FontName to "mceinline"
	ed.getDoc().execCommand('FontName', false, 'mceinline');
	//Iterate dom.select-Array where span/font-attribute exists and exec function(n) when true
	tinymce.each(ed.dom.select('span,font'), function(n) {
		//when font is "mceinline"
		if (n.style.fontFamily == 'mceinline' || n.face == 'mceinline'){
			//replace old element "n" with new created "en" and set "_mce_new" Attribute to true
			elm = ed.dom.create(en, {_mce_new : 1, 'class': 'xml_include'});
			ed.dom.replace(elm, n, 1);
		}
	});
	return elm;
}

function setAllAttribs(elm) {
	var formObj = document.forms[0];
	var urlxml = formObj.href.value.replace(/ /g, '%20');
	var xpointer = formObj.xpointer.value.replace(/ /g, '%20');
	var linktitle = formObj.linktitle.value;
	var url = urlxml;
	if(xpointer){
		url += "#" + xpointer;
	}
	setAttrib(elm, 'title', url);
	//setAttrib(elm, 'id', linktitle);
	if(!linktitle)
	{
		if(tinyMCE.activeEditor.selection.isCollapsed()){
			elm.innerHTML = "-[XML Document]-";
		}
	}
	else
	{
		elm.innerHTML = linktitle;
	}
	addClass(elm, 'xml_include');
}

function setAttrib(elm, attrib, value) {
	var formObj = document.forms[0];
	var valueElm = formObj.elements[attrib.toLowerCase()];
	var dom = tinyMCEPopup.editor.dom;

	if (typeof(value) == "undefined" || value == null) {
		value = "";
		if (valueElm)
		{
			value = valueElm.value;
		}
	}
	// Clean up the style
	if (attrib == 'style')
	{
		value = dom.serializeStyle(dom.parseStyle(value), 'span');
	}
	dom.setAttrib(elm, attrib, value);
}

function setFormValue(name, value) {
	document.forms[0].elements[name].value = value;
}

function splitURL(url){
	var urlArray = url.split('#', 2);
	return urlArray;
}

//check if email address or external link
function checkPrefix(n) {
	//asks for inserting the "mailto:" prefix if an email address (@) is detected
	if (n.value && Validator.isEmail(n) && !/^\s*mailto:/i.test(n.value) && confirm(tinyMCEPopup.getLang('xmlinclude_dlg.is_email')))
		n.value = 'mailto:' + n.value;

	//asks for inserting "http://" if a link (www) is detected /to be improved (www.[mind. 1 char].[min 1 char])
	if (n.value && /^\s*www\./i.test(n.value) && confirm(tinyMCEPopup.getLang('xmlinclude_dlg.is_external')))
		n.value = 'http://' + n.value;
}

function getSelectValue(form_obj, field_name) {
	var elm = form_obj.elements[field_name];
	if (!elm || elm.options == null || elm.selectedIndex == -1)
	{
		return "";
	}
	return elm.options[elm.selectedIndex].value;
}

function changeClass() {
	var f = document.forms[0];
	f.classes.value = getSelectValue(f, 'classlist');
}

function containsClass(elm,cl) {
	return (elm.className.indexOf(cl) > -1) ? true : false;
}

function getMatchingClass(elm) {
	var cls, clslist = document.getElementById('classlist');
	var clstag = elm.className.split(/\s/);
	outerloop: for(var i = 0;i<clslist.length;i++)
	{
		for(var j in clstag)
		{
			if(clslist.options[i].value == clstag[j])
			{
				cls = clslist.options[i].value;
				break outerloop;
			}
		}
	}
	return cls; 
}

function addClass(elm,cl) {
	if(!containsClass(elm,cl)) elm.className ? elm.className += " " + cl : elm.className = cl;
	return true;
}

//removeClass
function removeClass(elm,cl) {
	if(elm.className == null || elm.className == "" || !containsClass(elm,cl)) {
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

function beforeRemoveXML() {
	var inst = tinyMCEPopup.editor, elm;
	var element_name = 'SPAN';
	elm = inst.dom.getParent(inst.selection.getNode(), element_name.toLowerCase());
	elm.innerHTML = "";
	removeXML(elm);
}

function removeXML(element) {
	var inst = tinyMCEPopup.editor;
	var element_name = 'SPAN', elm;
	if(!arguments[0])
	{
		elm = inst.dom.getParent(inst.selection.getNode(), element_name.toLowerCase());
	}
	else
	{
		elm = element;
	}
	tinyMCEPopup.execCommand('mceBeginUndoLevel');
	tinyMCE.execCommand('mceRemoveNode', false, elm);
	inst.nodeChanged();
	tinyMCEPopup.execCommand('mceEndUndoLevel');
	tinyMCEPopup.close();
}

function inserthyperlink() {
	var title = document.selectform.input-title.value;
	var win = tinyMCEPopup.getWindowArg("window");
	var hyperlinkvalue = document.selectform.httpLink.value;
	win.document.getElementById("href").value = hyperlinkvalue;
	win.document.getElementById("linktitle").value = title;
	tinyMCEPopup.close();
} 

// While loading
tinyMCEPopup.onInit.add(init);
tinyMCEPopup.requireLangPack();
