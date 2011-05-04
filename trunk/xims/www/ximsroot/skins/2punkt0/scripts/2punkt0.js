/**
 * @author Susanne Tober
 */

	(function( $ ) {
		$.widget( "ui.combobox", {
			options: {
				input_id: '',
				button_type: 'button',
				input_size: 30,
				readonly: false
			},
			_create: function() {
				var self = this,
					select = this.element.hide(),
					selected = select.children( ":selected" );
					//value = selected.val() ? selected.text() : "";
					//alert("selected: "+selected.val());
				var options = self.options;
				//var input = this.input = $( "<input>" )
				var input = $("<input id = '"+options.input_id+"' name = '"+options.input_id+"' size='"+options.input_size+"' >")
					.insertAfter( select )
					//.val( value )
					.autocomplete({
						delay: 0,
						minLength: 0,
						source: function( request, response ) {
							var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
							response( select.children( "option" ).map(function() {
								var text = $( this ).text();
								if ( this.value && ( !request.term || matcher.test(text) ) )
									return {
										label: text.replace(
											new RegExp(
												"(?![^&;]+;)(?!<[^<>]*)(" +
												$.ui.autocomplete.escapeRegex(request.term) +
												")(?![^<>]*>)(?![^&;]+;)", "gi"
											), "<strong>$1</strong>" ),
										value: text,
										option: this
									};
							}) );
						},
						select: function( event, ui ) {
							ui.item.option.selected = true;
							self._trigger( "selected", event, {
								item: ui.item.option
							});
						},
						change: function( event, ui ) {
							if ( !ui.item ) {
								var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
									valid = false;
								select.children( "option" ).each(function() {
									if ( $( this ).text().match( matcher ) ) {
										this.selected = valid = true;
										return false;
									}
								});
								if ( !valid ) {
									// remove invalid value, as it didn't match anything
									$( this ).val( "" );
									select.val( "" );
									input.data( "autocomplete" ).term = "";
									return false;
								}
							}
						}
					})
					.addClass( "ui-widget ui-widget-content" );

				input.data( "autocomplete" )._renderItem = function( ul, item ) {
					return $( "<li></li>" )
						.data( "item.autocomplete", item )
						.append( "<a>" + item.label + "</a>" )
						.appendTo( ul );
				};

				this.button = $( "<button type='button'>&nbsp;</button>" )
					.attr( "tabIndex", -1 )
					.attr( "title", "Show All Items" )
					.insertAfter( input )
					.button({
						icons: {
							primary: "ui-icon-triangle-1-s"
						},
						text: false
					})
					.removeClass( "ui-corner-all" )
					.addClass( "ui-corner-right ui-button-icon" )
					.click(function() {
						// close if already visible
						if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
							input.autocomplete( "close" );
							return;
						}

						// pass empty string as value to search for, displaying all results
						input.autocomplete( "search", "" );
						input.focus();
					});
			},

			destroy: function() {
				this.input.remove();
				this.button.remove();
				this.element.show();
				$.Widget.prototype.destroy.call( this );
			}
		});
	})( jQuery );


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

function post_async(jsonQuery, property) {
	
	$.post(abspath, jsonQuery, function(data){ 		
								mkHandleMapResponse(data, property);
								initOptionsButtons();
								}, "html" );		
}

function refresh( property ) {
    $("#svl" + property + "container").load(parentpath + '?list_properties_items=1;property=' + property);

} 

function mkHandleMapResponse(data, property) {
    var mapped_properties = 'mapped_' +  property + 's';
	$('#' + mapped_properties).html(data); 	
}
	
function trim(str){
    str = str.replace(/^\s+/, '');
    for (var i = str.length - 1; i >= 0; i--) {
        if (/\S/.test(str.charAt(i))) {
            str = str.substring(0, i + 1);
            break;
        }
    }
    return str;
}

function setARIARoles(){
    $('#menu-bar').attr('role', 'menubar');
    /*
	$('#create').attr('role', 'menu');
    $('#create').attr('aria-expanded', false);
    $('#create li').attr('role', 'menuitem');
	*/
	$('#create-widget').attr('role', 'menu');
    $('#create-widget').attr('aria-expanded', false);
    $('#create-widget li').attr('role', 'menuitem');
	
    $('#help-widget').attr('role', 'menu');
    $('#help-widget').attr('aria-expanded', false);
    $('#help-widget li').attr('role', 'menuitem');
	
    $('#menu-widget').attr('role', 'menu');
    $('#menu-widget').attr('aria-expanded', false);
    $('#menu-widget li').attr('role', 'menuitem');
	
	$('#flat-authors').attr('role', 'menu');
    $('#flat-authorst').attr('aria-expanded', false);
    $('#flat-authors li').attr('role', 'menuitem');
	
	
    $('#menu-bar img').attr('role', 'button');
    //$('.hidden').attr('aria-hidden', true);
	//$('.hidden-content').attr('aria-hidden', true);
    //$(':hidden').attr('aria-hidden', true);
    $('.popuplink').attr('aria-haspopup', true);
    $("a[target='_blank']").attr('aria-haspopup', true);
	
	$('#menu-search').attr('role', 'search');
	$('.input-title').attr('aria-required', true);
}

function initCreateMenu(){
	$("#create-widget button").button({
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
			menu.menu("deactivate").show().css({top:0, left:0}).position({
				my: "left top",
				at: "left bottom",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});
	$("#create-widget a.more").button({
			icons: {
				primary: null,
				secondary: "ui-icon-triangle-1-e"
			}
		}).each(function() {
			$('#create-widget ul.more').menu({
				select: function(event, ui) {
					$(this).hide();
					window.location = ui.item.children('a').attr('href');
				},
				input: $(this)
			}).hide();
		}).click(function(event) {
			var menu = $('#create-widget ul.more');
			if (menu.is(":visible")) {
				menu.hide();
				return false;
			}
			menu.menu("deactivate").show().css({top:0, left:0}).position({
				my: "left top",
				at: "right top",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});
		
}

function initHelpMenu(){
		$("#help-widget button").button({
			icons: {
				primary: "ui-icon-help"
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
			menu.menu("deactivate").show().css({top:0, left:0}).position({
				my: "left top",
				at: "left bottom",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		})
}

function initMenuMenu(){            
	$("#menu-widget button").button({
			icons: {
				primary: "ui-icon-gear"
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
			menu.menu("deactivate").show().css({top:0, left:0}).position({
				my: "left top",
				at: "left bottom",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});
	
	//load bookmarks			
			$.get('/goxims/user?bookmarks=1;tooltip=1', function(data){
				$('#bm-links').html(data)
			});	
	$("#menu-widget a.more").button({
			icons: {
				primary: null,
				secondary: "ui-icon-triangle-1-e"
			}
		}).each(function() {
			$('#menu-widget ul.more').menu({
				select: function(event, ui) {
					$(this).hide();
					window.location = ui.item.children('a').attr('href');
				},
				input: $(this)
			}).hide();
		}).click(function(event) {
				var menu = $('#menu-widget ul.more');
				if (menu.is(":visible")) {
					menu.hide();
					return false;
				}
				menu.menu("deactivate").show().css({top:0, left:0}).position({
					my: "left top",
					at: "right top",
					of: this
				});
				$(document).one("click", function() {
					menu.hide();
				});
				return false;		
			});
		
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
			menu.menu("deactivate").show().css({top:0, left:0}).position({
				my: "left top",
				at: "left bottom",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});
}

function findPos(obj) {    
        var position = $(obj).offset();
	    return [position.left, position.top];
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

/*
function getTotalWidth(obj){
	return obj.width() + 
		parseInt(obj.css('margin-left').replace("px", "")) + 
		parseInt(obj.css('margin-right').replace("px", "")) + 
		parseInt(obj.css('padding-left').replace("px", "")) + 
		parseInt(obj.css('padding-right').replace("px", ""));
	
}
*/

function initOptionsButtons(){
	 
	//$(".buttonset").buttonset();

	$('.option-edit').button({
			text: false,
			icons: {
				primary: 'sprite-option_edit'
			}
		});
	 $('.option-edit span:first-child').addClass('xims-sprite');
		
	$('.option-copy').button({
			text: false,
			icons: {
				primary: 'sprite-option_copy'
			}
		});
	$('.option-copy span:first-child').addClass('xims-sprite');
		
	$('.option-move').button({
			text: false,
			icons: {
				primary: 'sprite-option_move'
			}
		});
	$('.option-move span:first-child').addClass('xims-sprite');
		
	$('.option-publish').button({
			text: false,
			icons: {
				primary: 'sprite-option_pub'
			}
		});
	$('.option-publish span:first-child').addClass('xims-sprite');
		
	$('.option-acl').button({
			text: false,
			icons: {
				primary: 'sprite-option_acl'
			}
		});
	$('.option-acl span:first-child').addClass('xims-sprite');
		
		
	$('.option-delete').button({
			text: false,
			icons: {
				primary: 'sprite-option_delete'
			}
		});
	$('.option-delete span:first-child').addClass('xims-sprite');
		
	$('.option-purge').button({
			text: false,
			icons: {
				primary: 'sprite-option_purge'
			}
		});
	$('.option-purge span:first-child').addClass('xims-sprite');
		
	$('.option-undelete').button({
			text: false,
			icons: {
				primary: 'sprite-option_undelete'
			}
		});
	$('.option-undelete span:first-child').addClass('sprite');
	
	$('.option-send_mail').button({
			text: false,
			icons: {
				primary: 'sprite-option_email'
			}
		});
	$('.option-send_mail span:first-child').addClass('xims-sprite');
	
	$('.option-disabled').button({
			text: false,
			icons: {
				primary: 'sprite-option_none'
			}
		});	
	$('.option-disabled').button('disable');
	$('.option-disabled span:first-child').addClass('xims-sprite');
	
	$('.status-pub').button({
			text: false,
			icons: {
				primary: 'sprite-status_pub'
			}
		});
	$('.status-pub span:first-child').addClass('xims-sprite');
	$('.status-pub_async').button({
			text: false,
			icons: {
				primary: 'sprite-status_pub_async'
			}
		});
	$('.status-pub_async span:first-child').addClass('xims-sprite');
	$('.status-locked').button({
			text: false,
			icons: {
				primary: 'sprite-locked'
			}
		});
	$('.status-locked span:first-child').addClass('xims-sprite');
	
	$('.status-disabled').button({
			text: false,
			icons: {
				primary: 'sprite-status_none'
			}
		});
	$('.status-disabled').button('disable');
	$('.status-disabled span:first-child').addClass('xims-sprite');
	
	
	$('.up').button({
			text: false,
			icons: {
				primary: 'ui-icon-triangle-1-n'
			}
		});
	$('.down').button({
			text: false,
			icons: {
				primary: 'ui-icon-triangle-1-s'
			}
		});
	
	$('.arrow-right').button({
			text: false,
			icons: {
				primary: 'ui-icon-arrowthick-1-e'
			}
		});
	$('.arrow-left').button({
			text: false,
			icons: {
				primary: 'ui-icon-arrowthick-1-w'
			}
		});
	$('.button-search').button({
			text: true,
			icons: {
				primary: 'ui-icon-search'
			}
		});
	/*$('.button-delete').button({
			text: false,
			icons: {
				primary: 'ui-icon-closethick'
			}
		});*/
}

function aclTooltip(){
	
	$( ".button option-acl" ).tooltip({ 
		content: function(response) {
  			$.getJSON("tooltipcontent.html", response);
		} 
	});
}
function getXMLHTTPObject() {
        var xmlhttp=false;
        /*@cc_on @*/
        /*@if (@_jscript_version >= 5)
        // JScript gives us Conditional compilation, we can cope with old IE versions.
        // and security blocked creation of the objects.
        try {
            xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
            try {
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch (E) {
                xmlhttp = false;
            }
        }
        @end @*/
        if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
            xmlhttp = new XMLHttpRequest();
        }
        return xmlhttp;
    }
	
function wfcheck() {
            var xmlhttp = getXMLHTTPObject();
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not check well-formedness.");
                    }
                    else {
                        alert(xmlhttp.responseText + '\n');
                    }
                }
            };
            xmlhttp.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=UTF-8');
            xmlhttp.send('test_wellformedness=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
		
function prettyprint(container_id) {
			
		if (ppmethod == "htmltidy") {
			var jsonQuery = {
				htmltidy: "1",
			body: $('#'+container_id).val()
			};
		}
		else {
			if (ppmethod == "prettyprintxml") {
				var jsonQuery = {
					prettyprintxml: "1",
				body: $('#'+container_id).val()
				};
			}
		}

    var tidiestring;
	
    $.ajax({
        type: 'POST',
        url: url,
        dataType: 'json',
        data: jsonQuery,
        success: function(jsonObject){
            tidiedstring = jsonObject.tidiedstring;
			$('#'+container_id).val(tidiedstring);
        }
    });
}

function object_type_filter(){
	var inputs = document.getElementsByTagName("input");
    var re = new RegExp("filter_ot_");
    var el;
    for (var i = inputs.length - 1; i > 0; --i ) {
		re.test(inputs[i].name);
		if(RegExp.rightContext.length > 0) {
			el = document.getElementById("ot_" + RegExp.rightContext);
			if (el) {
				el.checked = 1;
			}
		}
	}
}

/*
function txtshow( txt2show ) {
            var viewer = $("#charcount");
            viewer.html(txt2show);
        }
*/

function keyup( what ) {
            var str = what.value;
            var len = str.length;
            var showstr = len + " " + str_of + " " + maxKeys + " " + str_entered;
            if ( len > maxKeys ) {
                alert( str_charlimit );
                what.value = what.value.substring(0,maxKeys);
                return false;
            }
			$("#charcount").html(showstr);
            //txtshow( showstr );
        }

function customRange(input){
					
	var fromid = "input-validfrom";
	var toid = "input-validto";
	var min = new Date(); //Set this to your absolute minimum date
	var dateMin = null; //min;
	var dateMax = null;

    if (input.id == fromid) {
        if ($("#"+toid).datepicker("getDate") !== null) {
            dateMax = $("#"+toid).datepicker("getDate");
         }    
    }
    else if (input.id == toid) {
            if ($("#"+fromid).datepicker("getDate") !== null){
                    dateMin = $("#"+fromid).datepicker("getDate");  
            }
    }
    return {
                minDate: dateMin,
                maxDate: dateMax
            };

}

function initDatepicker() {
	/*if (typeof(date_lang) !== 'undefined') {
		$.datepicker.setDefaults($.datepicker.regional[date_lang]);
		$.timepicker.setDefaults($.datepicker.regional[date_lang]);
	}*/
	$.datepicker.setDefaults({ 
		dateFormat: 'yy-mm-dd', 
		showOn: 'button',
		buttonImage: button_image,
		buttonImageOnly: true
	});
		/*
		$("#" + id).datepicker({
			showOn: 'button',
			buttonImage: button_image,
			buttonImageOnly: true,
			buttonText: button_text,
			altField: "#" + formfield_id,
			altFormat: 'yy-mm-dd',
			onSelect: function(date){
				//date = $(this).datepicker('getDate');	
				//alert("date : "+date);
				//$("#"+formfield_id).val(date.print("%Y-%m-%d %H:%M"));
				$(this).datepicker("hide");
			},
			beforeShow: customRange
		});
		if (!((year && month && day) || value)) {
			$("#" + id).datepicker('setDate', null);
		//$("#"+id).val('<xsl:value-of select="$i18n/l/Valid_from_default"/>');
		}
		else {
			if (year && month && day) {
				$("#" + id).datepicker('setDate', new Date(year, month - 1, day));
			}
			else {
				//alert("value : "+value);
				$("#" + id).datepicker('setDate', new Date(value.substr(0, 3), value.substr(5, 6), value.substr(8, 9)));
			}
		}
		*/
}

function initDateTimepicker() {
	if (typeof(date_lang) !== 'undefined') {
		$.timepicker.setDefaults($.timepicker.regional[date_lang]);
	}
	$.timepicker.setDefaults({ 
		dateFormat: 'yy-mm-dd', 
		showOn: 'button',
		buttonImage: button_image,
		buttonImageOnly: true		
	});
};

function createImageDialog(url, dialogid, title){
	dialogid= "#"+dialogid;
	$(dialogid).dialog({
		autoOpen: false,
		modal: true,
		title: title,
		width: 420
	});
	$(dialogid).html('<image src="'+url+'" width="400px" />');
		
	$(dialogid).addClass('xims-content');		
	$(dialogid).dialog('open');
}

function createTinyMCEDialog(url, dialogid, title, txtareaid){
	dialogid = "#"+dialogid;
	var textareaid = "#"+txtareaid;
	$.get(url, function(data){
		$(dialogid).dialog({
			autoOpen: false,
			modal: true,
			title: title,
			width: '500px',
			open: function() {
                $(textareaid).tinymce({
		            theme:'advanced',
		            mode:'none',
					language: lang,
					plugins : 'paste,inlinepopups',
			theme_advanced_buttons1 : "bold,italic,underline,separator,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,undo,redo,link,unlink,code,help",
			theme_advanced_buttons2 : "",
			theme_advanced_buttons3 : "",
			theme_advanced_toolbar_location : "top",
			theme_advanced_toolbar_align : "left",
			theme_advanced_statusbar_location : "bottom",
			theme_advanced_path_location : 'bottom',
			theme_advanced_resizing : true,
			entity_encoding : 'raw'
		        });
            },
			beforeclose: function(event,ui){
				tinyMCE.execCommand('mceRemoveControl',false,txtareaid);
			}
			}).html(data).addClass('xims-content').dialog('open');

		$(".button").button();
		
		});
}

				
function createDialog(url, dialogid, title){
	dialogid = "#"+dialogid;
	$.get(url, function(data){
		$(dialogid).dialog({
			autoOpen: false,
			modal: true,
			title: title,
			width: 'auto',
			maxWidth: 800,
			maxHeight: 400,
			close: function(ev, ui) { $(this).close(); $(dialogid).html('')}
			}).html(data).addClass('xims-content').dialog('open');

		$(".button").button();

	});
}

function reloadDialog(url, dialogid){
	dialogid = "#"+dialogid;
	$.get(url, function(data){		
		$(dialogid).html(data);
	});
}

function closeDialog(dialogid){
	//dialogid = '#'+dialogid;
	//alert("close1");
	$('#'+dialogid).dialog('close');
	//alert("close2");
	$('#'+dialogid).dialog('destroy');
	//alert("close3");
}

$(document).ready(function(){
	
	if (typeof(date_lang) !== 'undefined') {
		$.datepicker.setDefaults($.datepicker.regional[date_lang]);
	}
	$.datepicker.setDefaults({ 
		dateFormat: 'yy-mm-dd', 
		showOn: 'button',
		buttonImageOnly: true		
	});
	
    setARIARoles();
	
	$("button").button();
	$("a.button").button();
	
	$("button.icon-search").button({
			icons: {
				primary: 'ui-icon-search'
			}
		});
		
	initOptionsButtons();
	
    initCreateMenu();
    initHelpMenu();
    initMenuMenu();

	initVLibMenu();
	
	$('#help-widget, #create-widget, #menu-widget').css('display', 'inline-block');

	
$('.obj-table tr').focusin(
		function(){
			$(this).children('td').addClass('table_hilite');
		}
	);
	$('.obj-table tr').focusout(
		function(){
			$(this).children('td').removeClass('table_hilite');
		}
	);
	
	$('.button').focusin(
		function(){ 
			$(this).removeClass('ui-state-default').addClass('ui-state-focus').addClass('ui-state-hover'); 
		}
	);
	$('.button').focusout(
		function(){ 
			$(this).removeClass('ui-state-focus').removeClass('ui-state-hover').addClass('ui-state-default'); 
		}
	);
	/*
$('.button').hover(
		function(){ $(this).removeClass('ui-state-default').addClass('ui-state-focus'); },
		function(){ $(this).removeClass('ui-state-focus').addClass('ui-state-default'); }
	); 
*/
	
	//save buttons
	$('.save-button').addClass('hidden');
	$('.save-button-js').removeClass('hidden');
	
	//$.datepicker.setDefaults($.datepicker.regional['de']); 

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

	$('a.more').removeClass('ui-state-default');
	$('.ui-dialog').addClass('xims-content');


    //IE hack							
    jQuery.each(jQuery.browser, function(i){
        if ($.browser.msie) {
        }
    });
    
});


/*  Copyright Mihai Bazon, 2002-2005  |  www.bazon.net/mishoo
 * -----------------------------------------------------------
 *
 * The DHTML Calendar, version 1.0 "It is happening again"
 *
 * Details and latest version at:
 * www.dynarch.com/projects/calendar
 *
 * This script is developed by Dynarch.com.  Visit us at www.dynarch.com.
 *
 * This script is distributed under the GNU Lesser General Public License.
 * Read the entire license text here: http://www.gnu.org/licenses/lgpl.html
 */
/** Prints the date in a string according to the given format. */
Date.prototype.print = function (str) {
	var m = this.getMonth();
	var d = this.getDate();
	var y = this.getFullYear();
	var wn = this.getWeekNumber();
	var w = this.getDay();
	var s = {};
	var hr = this.getHours();
	var pm = (hr >= 12);
	var ir = (pm) ? (hr - 12) : hr;
	var dy = this.getDayOfYear();
	if (ir == 0)
		ir = 12;
	var min = this.getMinutes();
	var sec = this.getSeconds();
	s["%a"] = $.datepicker.regional[date_lang].dayNamesShort[w]; //Calendar._SDN[w]; // abbreviated weekday name [FIXME: I18N]
	s["%A"] = $.datepicker.regional[date_lang].dayNames[w]; //Calendar._DN[w]; // full weekday name
	s["%b"] = $.datepicker.regional[date_lang].monthNamesShort[w]; //Calendar._SMN[m]; // abbreviated month name [FIXME: I18N]
	s["%B"] = $.datepicker.regional[date_lang].monthNames[w]; //Calendar._MN[m]; // full month name
	// FIXME: %c : preferred date and time representation for the current locale
	s["%C"] = 1 + Math.floor(y / 100); // the century number
	s["%d"] = (d < 10) ? ("0" + d) : d; // the day of the month (range 01 to 31)
	s["%e"] = d; // the day of the month (range 1 to 31)
	// FIXME: %D : american date style: %m/%d/%y
	// FIXME: %E, %F, %G, %g, %h (man strftime)
	s["%H"] = (hr < 10) ? ("0" + hr) : hr; // hour, range 00 to 23 (24h format)
	s["%I"] = (ir < 10) ? ("0" + ir) : ir; // hour, range 01 to 12 (12h format)
	s["%j"] = (dy < 100) ? ((dy < 10) ? ("00" + dy) : ("0" + dy)) : dy; // day of the year (range 001 to 366)
	s["%k"] = hr;		// hour, range 0 to 23 (24h format)
	s["%l"] = ir;		// hour, range 1 to 12 (12h format)
	s["%m"] = (m < 9) ? ("0" + (1+m)) : (1+m); // month, range 01 to 12
	s["%M"] = (min < 10) ? ("0" + min) : min; // minute, range 00 to 59
	s["%n"] = "\n";		// a newline character
	s["%p"] = pm ? "PM" : "AM";
	s["%P"] = pm ? "pm" : "am";
	// FIXME: %r : the time in am/pm notation %I:%M:%S %p
	// FIXME: %R : the time in 24-hour notation %H:%M
	s["%s"] = Math.floor(this.getTime() / 1000);
	s["%S"] = (sec < 10) ? ("0" + sec) : sec; // seconds, range 00 to 59
	s["%t"] = "\t";		// a tab character
	// FIXME: %T : the time in 24-hour notation (%H:%M:%S)
	s["%U"] = s["%W"] = s["%V"] = (wn < 10) ? ("0" + wn) : wn;
	s["%u"] = w + 1;	// the day of the week (range 1 to 7, 1 = MON)
	s["%w"] = w;		// the day of the week (range 0 to 6, 0 = SUN)
	// FIXME: %x : preferred date representation for the current locale without the time
	// FIXME: %X : preferred time representation for the current locale without the date
	s["%y"] = ('' + y).substr(2, 2); // year without the century (range 00 to 99)
	s["%Y"] = y;		// year with the century
	s["%%"] = "%";		// a literal '%' character

	var re = /%./g;
	//if (!Calendar.is_ie5 && !Calendar.is_khtml)
		return str.replace(re, function (par) { return s[par] || par; });
/*
	var a = str.match(re);
	for (var i = 0; i < a.length; i++) {
		var tmp = s[a[i]];
		if (tmp) {
			re = new RegExp(a[i], 'g');
			str = str.replace(re, tmp);
		}
	}

	return str;
	*/
};

/** Returns the number of day in the year. */
Date.prototype.getDayOfYear = function() {
	var now = new Date(this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0);
	var then = new Date(this.getFullYear(), 0, 0, 0, 0, 0);
	var time = now - then;
	return Math.floor(time / Date.DAY);
};

/** Returns the number of the week in year, as defined in ISO 8601. */
Date.prototype.getWeekNumber = function() {
	var d = new Date(this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0);
	var DoW = d.getDay();
	d.setDate(d.getDate() - (DoW + 6) % 7 + 3); // Nearest Thu
	var ms = d.valueOf(); // GMT
	d.setMonth(0);
	d.setDate(4); // Thu in Week 1
	return Math.round((ms - d.valueOf()) / (7 * 864e5)) + 1;
};





 
