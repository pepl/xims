/**
 * attributes.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

/*global vars */
//"markiert"-Flag
var marked = false;
//"verlinkt"-Flag
var linked = false;

var edt = tinyMCE.activeEditor;
var dom = edt.dom;
var elmNode = edt.selection.getNode();
var formObj = document.forms[0];

function init() {
	tinyMCEPopup.resizeToInnerSize();
	document.getElementById('link_row').style.display = 'none';
	
	//IE7 braucht das um aktive Editor-Instanz auszuwählen
	edt = tinyMCE.activeEditor;
	dom = edt.dom;
	elmNode = edt.selection.getNode();
	
	var onclick = dom.getAttrib(elmNode, 'onclick');
	
	//Überprüfen ob ausgewähltes Element oder übergeordnetes Element(ob markiert/unmarkiert: egal) vom Typ 'a' (Link) ist
	if(dom.is(elmNode,'a') || dom.is(elmNode.parentNode,'a')){
		//merken dass es ein Link ist um hreflang-Attribut zu aktivieren
		linked = true;
	}
	//Überprüfen ob Text markiert/ausgewählt ist
	if(!edt.selection.isCollapsed()){
		//merken dass Text markiert wurde um später span-Tag mit class=lang einfügen
		marked = true;
	}
	//wenn verlinkt - Linksprache initialisieren
	if(linked){
		enableTargetLang();
	}
	//Attribute für fokussiertes Elternelement initialisieren
	setFormValue('lang', dom.getAttrib(elmNode, 'lang'));
	setFormValue('xml:lang', dom.getAttrib(elmNode, 'xml:lang'));
	setFormValue('hreflang', dom.getAttrib(elmNode, 'hreflang'));
	
	className = dom.getAttrib(elmNode, 'class');

	addClassesToList('classlist', 'advlink_styles');
	
	selectByValue(formObj, 'classlist', className, true);
	//löst update Funktion aus wenn Sprachattribute schon vorher gesetzt sind
	if (elmNode != null && ((dom.getAttrib(elmNode, 'lang', false)) || 
							(dom.getAttrib(elmNode, 'xml:lang', false)) || 
							(dom.getAttrib(elmNode, 'hreflang', false))	)) {
		updateElement();
	}
	TinyMCE_EditableSelects.init();
}

function setFormValue(name, value) {
	if(value && document.forms[0].elements[name]){
		document.forms[0].elements[name].value = value;
	}
}

function enableTargetLang() {
	//wenn ausgewähltes Element ein Link ist -> initialisieren
	setFormValue('hreflang', dom.getAttrib(elmNode, 'hreflang'));
	//Klassenattribut ändern und damit den Style
	var ie7 = (document.all && !window.opera && window.XMLHttpRequest);
	//IE7 fix um Klassenattribut zu ändern
	if (ie7)
	{
		document.getElementById('link_row').style.display = '';
	}
	else {
		document.getElementById('link_row').style.display = 'table-row';
	}
}

function insertLang() {
	var elmNode = tinyMCE.activeEditor.selection.getNode();
	//speichert vorigen Zustand vor der Bearbeitung um wiederherstellen zu können
	tinyMCEPopup.execCommand("mceBeginUndoLevel");
	setAllAttribs(elmNode);
	tinyMCEPopup.execCommand("mceEndUndoLevel");
	tinyMCEPopup.close();
}

function setAttrib(elmNode, attrib, value) {
	var dom = tinyMCE.activeEditor.dom;
	var elmNode = tinyMCE.activeEditor.selection.getNode();
	var formObj = document.forms[0];
	var valueElmNode = formObj.elements[attrib.toLowerCase()];
	
	//Wenn kein Wert eingegeben wurde diesen nicht verarbeiten
	if (typeof(value) == "undefined" || value == null) {
		value = "";

		if (valueElmNode){
			value = valueElmNode.value;
		}
	}
	//Wenn Wert gültig (nicht null) ist
	if (value != "") {
		dom.setAttrib(elmNode, attrib.toLowerCase(), value);
		
		//wenn Style gesetzt wird
		if (attrib == "style"){
			attrib = "style.cssText";
		}
		//wenn JS-Event (beginnt mit 'on..') aktiviert wird
		if (attrib.substring(0, 2) == 'on'){
			value = 'return true;' + value;
		}
		//wenn Klasse gesetzt wird
		if (attrib == "class"){
			attrib = "className";
		}
		//alle weiteren Elemente bekommen Wert zugewiesen
		elmNode[attrib]=value;
	//sonst (wenn Wert null ist)
	} else{
		//entsprechendes Attribut (dessen Wert auf 0 gesetzt wurde) entfernen. Wert: null = entfernen
		elmNode.removeAttribute(attrib);
	}
}

function setAllAttribs(elmNode) {
	var f = document.forms[0];
	
	if(linked){
		setAttrib(elmNode, 'hreflang');
	}
	if(marked) {
		insertLangTag();
	}
	if(!marked){
		setAttrib(elmNode, 'class', getSelectValue(f, 'classlist'));
		setAttrib(elmNode, 'lang');
		setAttrib(elmNode, 'xml:lang');
	}
	
}

function updateElement() {
	var elmNode = tinyMCE.activeEditor.selection.getNode();
	//setzt Wert von submit von "Einfügen" auf "Update" wenn vorher schon lang-Attribute vorhanden
	document.getElementById("insert").setAttribute("value","Update");
	//Entfernen-Button anzeigen wenn entfernbare Sprachattribute vorhanden
	document.getElementById('remove').style.display = 'inline';
}

function removeLang() {
	removeAllAttributes();
	tinyMCEPopup.close();
}

//Alle Sprachattribute entfernen
function removeAllAttributes() {
	var elmNode = tinyMCE.activeEditor.selection.getNode();
	if(elmNode){
		tinyMCEPopup.execCommand('mceBeginUndoLevel');
		//Entfernt lang, xml:lang und hreflang-attribute wenn gesetzt
		if(elmNode.getAttribute('lang')) {
			elmNode.setAttribute('lang', '');
			elmNode.removeAttribute('lang');
		}
		if(elmNode.getAttribute('xml:lang')) {
			elmNode.setAttribute('xml:lang', '');
			elmNode.removeAttribute('xml:lang');
		}
		if(elmNode.getAttribute('hreflang')) {
			elmNode.setAttribute('hreflang', '');
			elmNode.removeAttribute('hreflang');
		}
		//Entfernt <span>-Tag und class=span darin und die gesetzten Attribute
		if(dom.hasClass(elmNode, 'lang')) {
			dom.removeClass(elmNode, 'lang');
			if(elmNode.parentNode, 'span'){
				removeLangTag();
			}
		}
		if(dom.hasClass(elmNode.parentNode, 'lang')) {
			dom.removeClass(elmNode.parentNode, 'lang');
			if(elmNode, 'span'){
				removeLangTag();
			}
		}
		tinyMCEPopup.execCommand('mceEndUndoLevel');
	}
}

function initLangTag() {
	initTagElement('span');
	if (SXE.currentAction == "update") {
		SXE.showRemoveButton();
	}
}

function insertLangTag() {		
	insertTagElement(tinymce.isIE6 == false ? 'span' : 'html:span');
}

function removeLangTag() {
	SXE.removeElement('span');
}


tinyMCEPopup.onInit.add(init);
tinyMCEPopup.requireLangPack();
