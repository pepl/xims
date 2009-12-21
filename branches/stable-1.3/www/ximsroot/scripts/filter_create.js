function add_item( type ) {
    option_add(document.getElementById(type + "1"),document.getElementById(type + "2"));
}

function remove_item( type ) {
    option_add(document.getElementById(type + "2"),document.getElementById(type + "1"));
}

function option_add(select1,select2) {
    if (select1.selectedIndex == -1) { return false; }
    newOption = new Option(select1.options[select1.selectedIndex].text, select1.options[select1.selectedIndex].value,false,true);
    select2.options[select2.length] = newOption;
    select1.options[select1.selectedIndex] = null;
}

function createFilterParams() {
    // Subject IDs
    var params = '';
    var sid = '';
    var list = document.getElementById("subject2");
    for (var i = 0; i < list.length; i++) {
        sid += list.options[i].value;
        if (i < list.length - 1) {sid += ',';}
    }
    if (sid != '') {params = "sid=" + sid + ";";}
    // Keyword IDs
    var kid = '';
    list = document.getElementById("keyword2");
    for (var i = 0; i < list.length; i++) {
        kid += list.options[i].value;
        if (i < list.length - 1) {kid += ',';}
    }
    if (kid != '') {params += "kid=" + kid + ";";}
    // Object Type
    var objecttype_list = document.getElementsByName("vlobjecttype_selected")[0];
    var otid = objecttype_list.options[objecttype_list.selectedIndex].value;
    if (otid != '') {params += "otid=" + otid + ";";}
    // Mediatype
    var mediatype_list = document.getElementsByName("vlmediatype_selected")[0];
    var mt = mediatype_list.options[mediatype_list.selectedIndex].value;
    if (mt != '') {params += "mt=" + mt + ";";}
    // Fulltext
    var vls = document.getElementsByName("vls")[0].value;
    if (vls != '') {params += "vls=" + vls + ";";}
    // Chronicle Dates
    var cf = document.getElementsByName("chronicle_from_date")[0].value;
    if (cf != '') {params += "cf=" + cf + ";";}
    var ct = document.getElementsByName("chronicle_to_date")[0].value;
    if (cf != '') {params += "ct=" + ct + ";";}
    return(params);
}