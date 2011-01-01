/*
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

/* function for inline pop-ups */
function openCloseInlinePopup(action, fadelayer, popup, selectButton) {
    var displayProperty;
    var selBtn;
    /* when no parameter is given as to which button to select,
       select button with id "xims_ilp_btn_select" */
    if (!selectButton) {
        selBtn = "xims_ilp_btn_select";
    }
    else {
        selBtn = selectButton;
    }
    if (action == "open") {
        // IE hack for ilp-height
        if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
            document.getElementById(fadelayer).style.height = 1000;
        }
        displayProperty = "block";
    }
    else { 
        displayProperty = "none";
    }
    document.getElementById(fadelayer).style.display = displayProperty;
    document.getElementById(popup).style.display = displayProperty;
    // finally select default button, in order to avoid a form-submit
    if (action == "open") {
        document.getElementById(selBtn).focus();
    }
}
