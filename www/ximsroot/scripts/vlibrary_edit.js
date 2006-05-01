/*
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

function addVLProperty( property ) {
    original = eval( "document.eform.vl" + property );
    selector = eval( "document.eform.svl" + property );
    newvalue = selector.options[selector.selectedIndex].text;
    if ( original.value.length > 0 ) {
        values = original.value.split(';');
        values.push(newvalue);
        original.value = values.join(';');
    }
    else {
        original.value = newvalue;
    }

    return true;
}

