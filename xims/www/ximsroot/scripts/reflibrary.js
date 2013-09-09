/*
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

function getRefTypeDescription( reftype_id ) {
    return document.getElementById( 'reftype' + reftype_id ).innerHTML;
}

function submitReferenceTypeUpdate( reftype ) {
    document.reftypechangeform.reference_type_id.value = reftype;
    document.reftypechangeform.submit();
    return true;
}

function blocking(nr) {
    if (document.layers) {
        current = (document.layers[nr].display == 'none') ? 'block' : 'none';
        document.layers[nr].display = current;
    }
    else if (document.all) {
        current = (document.all[nr].style.display == 'none') ? 'block' : 'none';
        document.all[nr].style.display = current;
    }
    else if (document.getElementById) {
        vista = (document.getElementById(nr).style.display == 'none') ? 'block' : 'none';
        document.getElementById(nr).style.display = vista;
    }
}
