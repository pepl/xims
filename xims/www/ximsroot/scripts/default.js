/*
# Copyright (c) 2002-2003 The XIMS Project.
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
function openDocWindow(topic) {
    docWindow = window.open( "/goxims/content/xims/xims-doku/users-reference.dkb#" + escape(topic), "displayWindow","resizable=yes,scrollbars=yes,width=800,height=480,screenX=100,screenY=300" );
}


