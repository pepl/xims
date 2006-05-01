/*
# Copyright (c) 2002-2006 The XIMS Project.
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
