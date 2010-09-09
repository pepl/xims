/**
 * @author suse
 */

(function($) {
		$.widget("ui.combobox", {
			options: {
				input_id: '',
				button_type: 'button',
				input_size: 30,
				readonly: false
			},
			_create: function() {
				var self = this;
				var options = self.options;
				var select = this.element.hide();
				var input = $("<input id = '"+options.input_id+"' name = '"+options.input_id+"' size='"+options.input_size+"' >").insertAfter(select).autocomplete({
						source: function(request, response) {
							var matcher = new RegExp(request.term, "i");
							response(select.children("option").map(function() {
								var text = $(this).text();
								if (!request.term || matcher.test(text))
									return {
										id: $(this).val(),
										label: text.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(" + request.term.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi, "\\$1") + ")(?![^<>]*>)(?![^&;]+;)", "gi"), "<strong>$1</strong>"),
										value: text
									};
							}));
						},
						delay: 0,
						select: function(e, ui) {
							if (!ui.item) {
								// remove invalid value, as it didn't match anything
								$(this).val("");
								return false;
							}
							$(this).focus();
							select.val(ui.item.id);
							self._trigger("selected", null, {
								item: select.find("[value='" + ui.item.id + "']")
							});
							
						},
						minLength: 0
					}).addClass("ui-widget ui-widget-content");	 //.addClass("ui-widget ui-widget-content ui-corner-left");	
					if(options.readonly){
						input.attr("readonly", "readonly");
					}
				//$("<button type='"+options.button_type+"'>&nbsp;</button>").insertAfter(input).button({
				$("<button type='button'>&nbsp;</button>").insertAfter(input).button({
					icons: {
						primary: "ui-icon-triangle-1-s"
					},
					text: false
				}).removeClass("ui-corner-all").addClass("ui-corner-right ui-button-icon").position({
					my: "left center",
					at: "right center",
					of: input,
					offset: "-1 0"
				}).css("top", "").click(function() {
					// close if already visible
					if (input.autocomplete("widget").is(":visible")) {
						input.autocomplete("close");
						return false;
					}
					// pass empty string as value to search for, displaying all results
					input.autocomplete("search", "");
					//input.focus();
					return false;
				});
				
			}
		});

	})(jQuery);


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
								mkHandleMapResponse(data, property)}, "html" );		
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
			$('ul.more').menu({
				select: function(event, ui) {
					$(this).hide();
					window.location = ui.item.children('a').attr('href');
				},
				input: $(this)
			}).hide();
		}).click(function(event) {
			var menu = $('ul.more');
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
		})
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
	 
	$(".buttonset").buttonset();

	$('.option-edit').button({
			text: false,
			icons: {
				primary: 'sprite-option_edit'
			}
		});
	 $('.option-edit span:first-child').addClass('sprite');
		
	$('.option-copy').button({
			text: false,
			icons: {
				primary: 'sprite-option_copy'
			}
		});
	$('.option-copy span:first-child').addClass('sprite');
		
	$('.option-move').button({
			text: false,
			icons: {
				primary: 'sprite-option_move'
			}
		});
	$('.option-move span:first-child').addClass('sprite');
		
	$('.option-publish').button({
			text: false,
			icons: {
				primary: 'sprite-option_pub'
			}
		});
	$('.option-publish span:first-child').addClass('sprite');
		
	$('.option-acl').button({
			text: false,
			icons: {
				primary: 'sprite-option_acl'
			}
		});
	$('.option-acl span:first-child').addClass('sprite');
		
		
	$('.option-delete').button({
			text: false,
			icons: {
				primary: 'sprite-option_delete'
			}
		});
	$('.option-delete span:first-child').addClass('sprite');
		
	$('.option-purge').button({
			text: false,
			icons: {
				primary: 'sprite-option_purge'
			}
		});
	$('.option-purge span:first-child').addClass('sprite');
		
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
	$('.option-send_mail span:first-child').addClass('sprite');
	
	$('.option-disabled').button({
			text: false,
			icons: {
				primary: 'sprite-option_none'
			}
		});	
	$('.option-disabled').button('disable');
	$('.option-disabled span:first-child').addClass('sprite');
	
	$('.status-pub').button({
			text: false,
			icons: {
				primary: 'sprite-status_pub'
			}
		});
	$('.status-pub span:first-child').addClass('sprite');
	$('.status-pub_async').button({
			text: false,
			icons: {
				primary: 'sprite-status_pub_async'
			}
		});
	$('.status-pub_async span:first-child').addClass('sprite');
	$('.status-locked').button({
			text: false,
			icons: {
				primary: 'sprite-locked'
			}
		});
	$('.status-locked span:first-child').addClass('sprite');
	
	$('.status-disabled').button({
			text: false,
			icons: {
				primary: 'sprite-status_none'
			}
		});
	$('.status-disabled').button('disable');
	$('.status-disabled span:first-child').addClass('sprite');
	
	
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



$(document).ready(function(){

/*$(function(){*/
	
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
	
	/*initAuthorsDD();
	initEditorsDD();
	initSerialsDD();*/
	//initVLibViews();
	initVLibMenu();
	
	$('#help-widget, #create-widget, #menu-widget').css('display', 'inline-block');
	
	/*
$('.obj-table a').focusin(
		function(){
			$(this).parents('tr').children('td').addClass('table_hilite');
		}
	);
	$('.obj-table a').focusout(
		function(){
			$(this).parents('tr').children('td').removeClass('table_hilite');
		}
	);
*/
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

$('a.more').removeClass('ui-state-default');

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
	s["%a"] = Calendar._SDN[w]; // abbreviated weekday name [FIXME: I18N]
	s["%A"] = Calendar._DN[w]; // full weekday name
	s["%b"] = Calendar._SMN[m]; // abbreviated month name [FIXME: I18N]
	s["%B"] = Calendar._MN[m]; // full month name
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
	if (!Calendar.is_ie5 && !Calendar.is_khtml)
		return str.replace(re, function (par) { return s[par] || par; });

	var a = str.match(re);
	for (var i = 0; i < a.length; i++) {
		var tmp = s[a[i]];
		if (tmp) {
			re = new RegExp(a[i], 'g');
			str = str.replace(re, tmp);
		}
	}

	return str;
};




 
