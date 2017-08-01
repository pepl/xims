/*
 * Copyright (c) 2002-2017 The XIMS Project.
 * See the file "LICENSE" for information and conditions for use, reproduction,
 * and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 * $Id: $
 */

$.ajaxSetup({
  cache: true
});
	
function post_async(jsonQuery, property) {
    jsonQuery.token = $("input[name='token']").attr('value');
    $.post(abspath, jsonQuery, function(data){ 		
        mkHandleMapResponse(data, property);
        initOptionsButtons();
    }, "html" );		
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
			//menu.menu("deactivate").show().css({top:0, left:0}).position({
			menu.menu().show().css({top:0, left:0}).position({
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
			menu.menu().show().css({top:0, left:0}).position({
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
			//first get bookmarks for submenu
			$.get(ximsconfig.goxims + ximsconfig.personalinterface + '?bookmarks=1;tooltip=1', function(data){
				$('#bm-links li[id!="new-bm"]').remove();
				$('#bm-links').append(data);
			});
			//now create menu
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
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});
}

function containerDate(){
	//date is defined by xsl-param $sb
	if (typeof date === 'undefined') var date;
	if (!date || !date.contains('date') ) date = "date";
    $('.td-vf,.td-vt').hide();
    $('.th-lm').click(function(){
       var sortlink = $(this).parent().parent().next();
       sortlink.children().last().text($(this).text());
       $('.td-lm').show(); 
       $('.td-vf,.td-vt').hide();
       sortlink.attr('href', sortlink.attr('href').replace(date, "date")) ;
       date = "date";
    });
    $('.th-vf').click(function(){
    	var sortlink = $(this).parent().parent().next();
    	$(this).parent().parent().next().children().last().text($(this).text());
		$('.td-vf').show(); 
		$('.td-lm,.td-vt').hide();
		sortlink.attr('href', sortlink.attr('href').replace(date, "vfdate")) ;
        date = "vfdate";
     });
    $('.th-vt').click(function(){
    	var sortlink = $(this).parent().parent().next();
    	$(this).parent().parent().next().children().last().text($(this).text());
    	$('.td-vt').show(); 
    	$('.td-vf,.td-lm').hide();
     	sortlink.attr('href', sortlink.attr('href').replace(date, "vtdate")) ;
     	date = "vtdate";
     });
    $('#select-date')
    	.css('cursor', 'pointer')
       .click(function() {
    	   var menu = $( this ).next();
    	   if (menu.is(":visible")) {
    		   menu.hide();
    		   return false;
    	   }
    	   menu.menu().show().css({top:0, left:0}).position({
    		   my: "left top+5px",
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

function initOptionsButtons(){

	$(".buttonset").buttonset();
	
	$("a.button").button();
	$("button.button").button();

	$('.option-disabled').button({
			text: false,
			icons: {
				primary: 'xims-sprite sprite-option_none'
			}
		});	
	$('.option-disabled').button('disable');

	$('.status-disabled').button({
			text: false,
			icons: {
				primary: 'xims-sprite sprite-status_none'
			}
		});
	$('.status-disabled').button('disable');
	
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

	$('a.button.warn').button({
			text: false,
			icons: {
				primary: 'ui-icon-alert'
			}
		});
}

function aclTooltip(){
    $('a.option-acl').each(function(){
      var stroa = 'option-acl_';
      var currid = $(this).attr('id').substring($(this).attr('id').indexOf('option-acl') + stroa.length );
      var geturl = ximsconfig.goxims + ximsconfig.contentinterface + '?id='+currid+';obj_acllist=1;tooltip=1';
      $(this).tooltip(
        {
        content: function(response){
          $.get(geturl, response);
            return "Loading...";
          }
        },
        {open: function (event, ui) {
            ui.tooltip.css("max-width", "800px");
        }
        },
        
        {position: {my: "right-570 top+10", at: "left bottom", collision: "fit", of: '#'+stroa+currid}}
      );
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
            xmlhttp.send('test_wellformedness=1' +
                         '&token='+encodeURIComponent($("input[name='token']").attr('value')) +
                         '&body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
		
function prettyprint(container_id) {
		if (ppmethod == "htmltidy") {
			var jsonQuery = {
				htmltidy: "1",
                                token: $("input[name='token']").attr('value'),
 			        body: $(container_id).val()
			};
		}
		else {
			if (ppmethod == "prettyprintxml") {
				var jsonQuery = {
					prettyprintxml: "1",
                                        token: $("input[name='token']").attr('value'),
				        body: $(container_id).val()
				};
			}
		}
    $.ajax({
        url: url,
        type: 'POST',
        data: jsonQuery,
        success: function(tidiedstring){
			$(container_id).val(tidiedstring);
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


function keyup( what ) {
            var str = what.value;
            var len = str.length;
            var showstr = len + " " + str_of + " " + maxKeys + " " + str_entered;
            if ( len >= (maxKeys) ) {
				$("#charcount").html(showstr+' -- '+str_charlimit);
                what.value = what.value.substring(0,maxKeys-1);
                return false;
            }
			$("#charcount").html(showstr);
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
	$.datepicker.setDefaults({ 
		dateFormat: 'yy-mm-dd', 
		showOn: 'button',
		buttonImage: button_image,
		buttonImageOnly: true
	});
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

function createDocDialog(title, text){
	var dialogid = "#default-dialog";
	$(dialogid).dialog({
		title: title,
		autoOpen: false
	});
	$(dialogid).html(text);
	$(dialogid).addClass('xims-content');		
	$(dialogid).dialog('open');
}
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
			close: function(ev, ui) {
				closeDialog(dialogid.replace('#',''));
			}
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
	$('#'+dialogid).dialog('close');
	$('#'+dialogid).html('');
	$('#'+dialogid).dialog('destroy');
}

function searchFilter(){
	$('#input-search').keyup(function(){
		var searchtext = $('#input-search').val();
		$('.objrow').each(function(index){
			var re = new RegExp(searchtext, 'gi');
			var text = 	(($(this).find('.ctt_loctitle > span > a')).html()+($(this).find('.ctt_loctitle > span')).attr('title')) || 
						(($(this).find('.ctt_loctitleindex > span > a')).html()+($(this).find('.ctt_loctitleindex > span')).attr('title'));
			if(text && text.match(re, 'gi')){
				$(this).show();
			}
			else{
				$(this).hide();
			}
		});
	});
}

function hiliteObjrow(cb){
	if (cb.prop('checked')) {
		cb.parents('tr.objrow').addClass('selected');
	}else{
		cb.parents('tr.objrow').removeClass('selected');
	}
}

function selectAllObjects(){
	$("#select-all").bind("click", function(){
		var checked = $(this).prop("checked");
		$("input[name=multiselect]").each(function() {
			$(this).prop('checked', checked);
			hiliteObjrow($(this));	
		});
		if(!checked){
			$('.multi-select-action>div').hide();
		}
	});
	
	$('.ctt_select>input, #select-all').bind("click", function(){
		var showtoolbar = false;
		if ($(this).prop('checked')=='checked') {
			$(this).parents('tr.objrow').addClass('selected');
		}else{
			$(this).parents('tr.objrow').removeClass('selected');
		}
		showtoolbar = $('.obj-table').find('input[name=multiselect]:checked').length;
		if (showtoolbar) {
			$('.multi-select-action>div').show();
		}
		else{
			$('.multi-select-action>div').hide();
		}
		hiliteObjrow($(this));
	});
	
}

function selectAllOTs(){
	$("#select-all-ots").bind("click", function(){
		var checked = $(this).prop("checked");
		$(".cb_otfilter").each(function() {
			$(this).prop('checked', checked);
		});
	});	
}

function cbSwitcher(selector, cbname){
		var checked = selector.prop("checked");
		$("input[name="+cbname+"]").each(function() {
			$(this).prop('checked', checked);
		});
}

function OTFilter(){
  $('#filter-link').click(function(){
     $('#filterots').detach().appendTo($('#default-dialog'));
     $('#default-dialog').attr('title',$('#filterots').attr('title'));
     $(".ots-menue-level-2").hide();
     $("#filterots").show();
     $('#default-dialog').dialog({
         modal: true,
         close: function(event, ui){
           $("#filterots").hide();
           $('#filterots').detach().insertAfter($('form[name="multi"]'));
           $('#default-dialog').attr('title', '');
           $( "#default-dialog" ).dialog( "destroy" );
         }
         }).addClass('xims-content').dialog('open');
	   });
	  
   $('#filter-button').click(function(){
     $('#otfilter').val($('.cb_otfilter:checked').map(function(){return $(this).attr('name');}).get().join(','));
   });
   $(".otf-more").click(function(){$(".ots-menue-level-2").toggle();
   });
}

$(document).ready(function(){
	initOptionsButtons();
	if (typeof(date_lang) !== 'undefined') {
		$.datepicker.setDefaults($.datepicker.regional[date_lang]);
	}
	$.datepicker.setDefaults({ 
		dateFormat: 'yy-mm-dd', 
		showOn: 'button',
		buttonImageOnly: true		
	});
	
	
	$("button.icon-search").button({
			icons: {
				primary: 'ui-icon-search'
			}
		});
		
	//initOptionsButtons();
	
    initHelpMenu();
    initMenuMenu();
		
    if($(".option-acl").length > 0){
      aclTooltip();
    }
	
	$('#help-widget, #create-widget, #menu-widget').css('display', 'inline-block');

	//container view sprecials
	if($(".obj-table").length > 0){
		//initCreateMenu();
		selectAllObjects();
		OTFilter();
		selectAllOTs();
		containerDate();
		
	}
	if($("#create-widget").length > 0){
		initCreateMenu();
	}
	$('.status-pub, .status-pub_async, .status-locked, .option-edit, .option-copy, .option-move, .option-publish, .option-acl, .option-delete, .option-purge, .option-undelete, .option-trashcan').focusin(
			function(){ 
				$(this).removeClass('ui-state-default').addClass('ui-state-focus').addClass('ui-state-hover'); 
			}
		).focusout(
			function(){ 
				$(this).removeClass('ui-state-focus').removeClass('ui-state-hover').addClass('ui-state-default'); 
			}
		);
	$('.status-pub, .status-pub_async, .status-locked, .option-edit, .option-copy, .option-move, .option-publish, .option-acl, .option-delete, .option-purge, .option-undelete, .option-trashcan').hover(
			function(){ 
				$(this).removeClass('ui-state-default').addClass('ui-state-focus').addClass('ui-state-hover'); 
			},
			function(){ 
				$(this).removeClass('ui-state-focus').removeClass('ui-state-hover').addClass('ui-state-default'); 
			}
		);

	//save buttons
	$('.save-button').addClass('hidden');
	$('.save-button-js').removeClass('hidden');
	
	
	$('a.more').removeClass('ui-state-default');
	$('.ui-dialog').addClass('xims-content');
	
	searchFilter();				
	//initOptionsButtons();
	
	/* 
	 * workaround: target=_blank in help-menu items opens 2 windows (maybe some conflicts with jquery-ui)
	 */
	  
	$("#help-widget a").click( function() {
	    window.open(this.href);
	    return false;
	});


    
    $( "#motd" ).dialog({
        resizable: false, 
        //height:140,
        width: 450,
        modal: true,
        autoOpen: false,
        buttons: { 
            "OK": function() {
                var jsonQuery = {
				    mark_motd_read: "1",
                    token: $("input[name='token']").attr('value')
                };
                
                $.post("/goxims/user",
                         { mark_motd_read: "1",
                           token: $("input[name='token']").attr('value') },
                       function() { $( "#motd-link" ).hide(); }
                      );
                $( this ).dialog( "close" ); 
            } 
        }
    });
    
    $( "#motd-link" ).click( function() {$('#motd').dialog('open');} );
    
});

/* IE special polyfills*/
if (typeof String.prototype.contains === 'undefined') { String.prototype.contains = function(it) { return this.indexOf(it) != -1; }; }

/*  Copyright Mihai Bazon, 2002-2015  |  www.bazon.net/mishoo
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
	s["%b"] = $.datepicker.regional[date_lang].monthNamesShort[m]; //Calendar._SMN[m]; // abbreviated month name [FIXME: I18N]
	s["%B"] = $.datepicker.regional[date_lang].monthNames[m]; //Calendar._MN[m]; // full month name
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

// BEGIN: DATE OBJECT PATCHES

/** Adds the number of days array to the Date object. */
Date._MD = new Array(31,28,31,30,31,30,31,31,30,31,30,31);

/** Constants used for time computations */
Date.SECOND = 1000 /* milliseconds */;
Date.MINUTE = 60 * Date.SECOND;
Date.HOUR   = 60 * Date.MINUTE;
Date.DAY    = 24 * Date.HOUR;
Date.WEEK   =  7 * Date.DAY;

Date.parseDate = function(str, fmt) {
	var today = new Date();
	var y = 0;
	var m = -1;
	var d = 0;
	var a = str.split(/\W+/);
	var b = fmt.match(/%./g);
	var i = 0, j = 0;
	var hr = 0;
	var min = 0;
	for (i = 0; i < a.length; ++i) {
		if (!a[i])
			continue;
		switch (b[i]) {
		    case "%d":
		    case "%e":
			d = parseInt(a[i], 10);
			break;

		    case "%m":
			m = parseInt(a[i], 10) - 1;
			break;

		    case "%Y":
		    case "%y":
			y = parseInt(a[i], 10);
			(y < 100) && (y += (y > 29) ? 1900 : 2000);
			break;

		    case "%b":
		    case "%B":
			for (j = 0; j < 12; ++j) {
				if (Calendar._MN[j].substr(0, a[i].length).toLowerCase() == a[i].toLowerCase()) { m = j; break; }
			}
			break;

		    case "%H":
		    case "%I":
		    case "%k":
		    case "%l":
			hr = parseInt(a[i], 10);
			break;

		    case "%P":
		    case "%p":
			if (/pm/i.test(a[i]) && hr < 12)
				hr += 12;
			else if (/am/i.test(a[i]) && hr >= 12)
				hr -= 12;
			break;

		    case "%M":
			min = parseInt(a[i], 10);
			break;
		}
	}
	if (isNaN(y)) y = today.getFullYear();
	if (isNaN(m)) m = today.getMonth();
	if (isNaN(d)) d = today.getDate();
	if (isNaN(hr)) hr = today.getHours();
	if (isNaN(min)) min = today.getMinutes();
	if (y != 0 && m != -1 && d != 0)
		return new Date(y, m, d, hr, min, 0);
	y = 0; m = -1; d = 0;
	for (i = 0; i < a.length; ++i) {
		if (a[i].search(/[a-zA-Z]+/) != -1) {
			var t = -1;
			for (j = 0; j < 12; ++j) {
				if (Calendar._MN[j].substr(0, a[i].length).toLowerCase() == a[i].toLowerCase()) { t = j; break; }
			}
			if (t != -1) {
				if (m != -1) {
					d = m+1;
				}
				m = t;
			}
		} else if (parseInt(a[i], 10) <= 12 && m == -1) {
			m = a[i]-1;
		} else if (parseInt(a[i], 10) > 31 && y == 0) {
			y = parseInt(a[i], 10);
			(y < 100) && (y += (y > 29) ? 1900 : 2000);
		} else if (d == 0) {
			d = a[i];
		}
	}
	if (y == 0)
		y = today.getFullYear();
	if (m != -1 && d != 0)
		return new Date(y, m, d, hr, min, 0);
	return today;
};






 
