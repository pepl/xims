/*
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

function confirmDelete() {
    if (confirm("Are you sure?")) {
        return true
    }
    else {
        return false
    }
}

function genericWindow(url) {
    newWindow = window.open( url, "displayWindow", "resizable=yes,scrollbars=yes,width=400,height=400,screenX=100,screenY=300" );
}

function previewWindow(url) {
    newWindow = window.open( url, "displayWindow", "resizable=yes,scrollbars=yes,width=800,height=600,screenX=10,screenY=10" );
}

function diffWindow(url) {
    newWindow = window.open( url, "displayWindow", "resizable=yes,scrollbars=yes,width=750,height=450,screenX=30,screenY=30" );
}

function openDocWindow(topic) {
    docWindow = window.open( "http://xims.info/documentation/users/xims-user_s-reference.sdbk#" + escape(topic), "displayWindow","resizable=yes,scrollbars=yes,width=800,height=480,screenX=100,screenY=300" );
}

function getParamValue( param ) {
    var objQuery = new Object();
    var objQuery2 = new Object();
    var windowURL;
    var strQuery = location.search.substring(1);
    var aryQuery = strQuery.split(";");
    var aryQuery2 = strQuery.split("&");
    var pair = [];
    var pair2 = [];
    for (var i = 0; i < aryQuery.length; i++) {
        pair = aryQuery[i].split("=");
        if (pair.length == 2) {
            objQuery[unescape(pair[0])] = unescape(pair[1]);
        }
    }
    for (var i = 0; i < aryQuery2.length; i++) {
        pair2 = aryQuery2[i].split("=");
        if (pair2.length == 2) {
            objQuery2[unescape(pair2[0])] = unescape(pair2[1]);
        }
    }

    var hls = objQuery[param] ? objQuery[param] : objQuery2[param];
    return hls;
}

var highlighted = false;
function stringHighlight( mystring ) {
    if (highlighted || !mystring ) {
        return;
    }
    re = /\s+/;
    var splitted = mystring.split(re);
    for (var i in splitted) {
        /* should not match inside <>. browser's regex implementations are
           quite different so it matches currently. better solution pending
        */
        splittedRE = new RegExp('('+splitted[i]+')', 'gi');
        var body = document.getElementById("body");
        content = body.innerHTML;
        content = content.replace(splittedRE, '<span name="highlighted" style="background: yellow">$1</span>');
        body.innerHTML = content;
    }

    highlighted = true
}

function toggleHighlight( hls ) {
    var cssText;
    if ( highlighted == false ) {
        cssText = 'background: yellow';
        highlighted = true;
    }
    else {
        cssText = '';
        highlighted = false;
    }

    if ( document.all ) {
        var els = document.getElementsByTagName("span");
        var i;
        for(i = 0;i<els.length;i++){
            if ( els[i].name == 'highlighted' ) {
                els[i].style.cssText = cssText;
            }
        }
    }
    else {
        var els = document.getElementsByName('highlighted');
        for(i = 0;i<els.length;i++){
            els[i].style.cssText = cssText;
        }
    }
}
