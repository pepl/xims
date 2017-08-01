/*
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

function addSelection( from, to ) {
    if ( from.value == '' ) { return false; }
    newSelection = new Option( from.value );
    if ( ( to.length == 0 ) || ( to.options[0].text == '' )  ) {
	    to.options[0] = newSelection;
    }
    else {
	    to.options[to.length] = newSelection;
    }
    storeSelections( to );
    from.value = "";
}

function removeSelection( from ) {
    from.options[from.selectedIndex] = null;
    storeSelections( from );
}

function storeSelections( from ) {
    /* Stores options of a select-element into a hidden field */
    to = eval( "document.eform.answer_" + from.name.split('_')[1] + "_title");
    to.value = '';
    for ( index = 0; index < from.length; index++ ) {
	    to.value += from.options[index].text + "####";
    }
}
