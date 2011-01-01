/*
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

function testValue( regex, text, alerttext ) {
    if ( text.value.length > 0 ) {
        var re = new RegExp(regex);
        if ( ! text.value.match(re) ) {
            alert(alerttext);
            text.value = '';
        }
    }
}

function checkPropertyType ( select ) {
    if ( select.options ) {
        if ( select.options[select.selectedIndex].value == 'stringoptions' ) {
            document.getElementById("tr-regex").style.display="none";
            document.getElementById("tr-stringoptions").style.display="table-row";
        }
        else {
            document.getElementById("tr-regex").style.display="table-row";
            document.getElementById("tr-stringoptions").style.display="none";
        }
    }
}

function addSelection( from, to ) {
    if ( from.value == '' ) { return false; }
    from.value = from.value.replace(/\|/g, '_'); // check for the separator

    newSelection = new Option( from.value );
    if ( ( to.length == 0 ) || ( to.options[0].text == '' )  ) {
        to.options[0] = newSelection
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
    to = document.eform.sdbp_regex;
    to.value = '';
    for ( index = 0; index < from.length; index++ ) {
        to.value += escapeRegex( from.options[index].text );
        if ( from.length > 1 && index != from.length - 1 ) {
            to.value += "|";
        }
    }
    to.value = '^(' + to.value + ')$';
}

function escapeRegex( s ) {
    return s.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1');
}