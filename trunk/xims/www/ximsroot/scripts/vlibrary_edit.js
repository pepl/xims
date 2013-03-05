/*
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

//Jokar: Maybe these functions should be moved to vlibrary_default.js
//       because also the "create" stylesheets make use of them

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
function addVLProperty2( property ) {
  $("#svl"+property).append('<option value="" selected="selected">'+$("#vl"+property).val()+'</option>');
}

function submitOnValue ( field, text, selectfield ) {
    if ( field.value.replace(/\s+/g,"").length > 0 ) {
        return document.eform.submit();
    }
    else {
        if (selectfield) { selectfield.focus(); }
    }
    return false;
}

function submitOnId ( property, text ) {
    var selectfield = eval("document.eform.svl"  + property);
    var hiddenfield = eval("document.eform.vl" + property);
    if ( selectfield.value > 0 ) {
        hiddenfield.value = selectfield.value;
        return document.eform.submit();
    }
    else {
        if (selectfield) { selectfield.focus(); }
    }
    return false;
}

function createMapping ( property, text ) {
    var selectfield = eval("document.eform.svl"  + property);
    if ( selectfield.value > 0 ) {
        post_async("create_mapping_async=1;property=" + property
                   + ";property_id=" + selectfield.value, property);
    }
    else {
        if (selectfield) { selectfield.focus(); }
    }
    return false;
}

function removeMapping ( property, property_id ) {
    post_async("remove_mapping_async=1;property=" + property
               + ";property_id=" + property_id, property);
}
