/*
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

function setBg(elid){
    var els = document.getElementsByName(elid);
    /*
       This relies on the fact, that the second assigned stylesheet has
       sane background-color values defined in the first two rules.
    */

    var color0;
    var color1;

    /* IE and the Gecko behaves differently */
    if (document.all) {
        color0 = document.styleSheets[1].rules.item(0).style.backgroundColor;
        color1 = document.styleSheets[1].rules.item(1).style.backgroundColor;
    }
    else {
        color0 = document.styleSheets[1].cssRules[0].style.backgroundColor
        color1 = document.styleSheets[1].cssRules[1].style.backgroundColor
    }

    var i;
    for(i = 0;i<els.length;i++){
        eval("els[i].style.backgroundColor = color"+(i%2));
    }
}
 

function genericVLibraryPopup (url, action) {

    var window_sizes = {
        'subject'    : ['870', '500'],
        'author'     : ['620', '320'],
        'keyword'    : ['550', '200'],
        'publication': ['600', '260'],
        'delete'     : ['550', '340'],
    }

    genericWindow(url, window_sizes[action][0], window_sizes[action][1]);

}
