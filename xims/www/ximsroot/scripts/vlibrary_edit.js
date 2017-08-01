/*
# Copyright (c) 2002-2017 The XIMS Project.
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

function initVLibMenu(){
	$("#vlib-menu").button({
			icons: {
				secondary: "ui-icon-triangle-1-s"
			}
		}).each(function() {
			$(this).next().menu({
				select: function(event, ui) {
					$(this).hide();
					window.location = ui.item.children('a').attr('href');
				},
				input: $(this)
			}).hide();
		}).click(function(event) {
			var menu = $(this).next();
			if (menu.is(":visible")) {
				menu.hide();
				return false;
			}
			menu.menu().show().css({top:0, left:0}).position({
        my: "left top",
        at: "left bottom",
        of: this
      });
			/*
			menu.menu("deactivate").show().css({top:0, left:0}).position({
				my: "left top",
				at: "left bottom",
				of: this
			});
			*/
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});
}

function addProperty( property, fullname ) {
    //original = eval( "document.eform.vl" + property );
	original = "document.eform.vl" + property;
    newvalue = fullname;
    if ( original.value.length > 0 ) {
        values = original.value.split(';');
        values.push(newvalue);
        original.value = values.join(';');
    }
    else {
        original.value = newvalue;
    }
}

function initPropDescription(property){
	var pos = findPos($(property).prev());
	var inputfield = property.substr(property.indexOf('_')+1);
	inputfield = 'input-'+inputfield; 
	var offset = document.getElementById(inputfield).offsetWidth;
	$(property).css('left',pos[0]+offset+10);
	$(property).css('top',pos[1]);
	$(property).css('display', 'block');
}
function destroyInfoBox(self){
	$(self).css('display', 'none');
}
	
function initAuthDescription(auth_desc, inputfield){
	var neighbour = $(auth_desc).prev();
	while (neighbour && (neighbour.type == 'hidden' || neighbour.hasClass('hidden-content'))){
		neighbour = neighbour.prev();
	}
	var pos = findPos(neighbour);
	var offset = getTotalWidth(neighbour); 

	$(auth_desc).css('left',pos[0]+offset+10);
	$(auth_desc).css('top',pos[1]);
	$(auth_desc).css('display', 'block');
}

function removeMapping ( property, property_id ) {
    post_async("remove_mapping_async=1;property=" + property
               + ";property_id=" + property_id, property);
}

function refresh( property ) {
    $("#svl" + property + "container").load(parentpath + '?list_properties_items=1;property=' + property);

} 

function mkHandleMapResponse(data, property) {
    var mapped_properties = 'mapped_' +  property + 's';
	$('#' + mapped_properties).html(data); 	
}

function createMapping ( property, value, text ) {
    if ( value > 0 ) {
		var jsonQuery = {
			create_mapping_async: "1",
			property: property,
			property_id: value
		};
        var jsonObject = post_async(jsonQuery, property);	
		mkHandleMapResponse(jsonObject, property);					   
    }
    else {
        alert ( text );
    }
    //return false;
}

function removeMapping ( property, property_id ) {
	var jsonQuery = {
		remove_mapping_async: "1",
		property: property,
		property_id: property_id
	};
	post_async(jsonQuery, property);
	
}

function deleteProperty( property, property_id ){
	var jsonQuery = {
		property_delete: "1",
		property: property,
		property_id: property_id
	};
	$.ajax({
		type: 'GET',
		url: abspath,
		dataType: 'json',
		data: jsonQuery,
		success: function(jsonObject){
		}
	});
	document.location.replace(abspath);
	//var jsonObject = post_async(jsonQuery, property);
	
}

$(document).ready(function(){
	
	//initCreateMenu();
	initVLibMenu();

	$("#svlsubject").combobox({
		input_id: "vlsubject",
		button_type: "button",
		input_size: '43'
	});
	
	$("#svlkeyword").combobox({
		input_id: "vlkeyword",
		button_type: "button",
		input_size: '43'
	});
	$("#svlauthor").combobox({
		input_id: "vlauthor",
		button_type: "button",
		input_size: '43'
	});
	$("#svlpublication").combobox({
		input_id: "vlpublication",
		button_type: "button",
		input_size: '43'
	});
	$("#svleditor").combobox({
		input_id: "vleditor",
		button_type: "button",
		input_size: '43'
	});
	$("#svlserial").combobox({
		input_id: "vlserial",
		button_type: "button",
		input_size: '43'
	});
});

