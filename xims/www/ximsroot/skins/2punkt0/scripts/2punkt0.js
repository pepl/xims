/**
 * @author suse
 */

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
    $('#titlelogo').attr('role', 'menubar')
    $('#create').attr('role', 'menu');
    $('#create').attr('aria-expanded', false);
    $('#create li').attr('role', 'menuitem');
    $('#help').attr('role', 'menu');
    $('#help').attr('aria-expanded', false);
    $('#help li').attr('role', 'menuitem');
    $('#menu').attr('role', 'menu');
    $('#menu').attr('aria-expanded', false);
    $('#menu li').attr('role', 'menuitem');
    $('#subheader img').attr('role', 'button');
    $('.hidden').attr('aria-hidden', true);
    $(':hidden').attr('aria-hidden', true);
    $('.popuplink').attr('aria-haspopup', true);
    $("a[target='_blank']").attr('aria-haspopup', true);
}

function initCreateMenu(){
    // BUTTONS
    $('.create-widget.fg-button').focus(function(){
        $(this).removeClass('ui-state-default').addClass('ui-state-focus');
    });
    // MENU               
    $('.create-widget.flyout').menu({
        content: $('.create-widget.flyout').next().html(),
        flyOut: true
    });
}

function initHelpMenu(){
    // BUTTONS
    $('.help-widget.fg-button').focus(function(){
        $(this).removeClass('ui-state-default').addClass('ui-state-focus');
    });
    // MENU               
    $('.help-widget.flyout').menu({
        content: $('.help-widget.flyout').next().html(),
        flyOut: true
    });
}

function initMenuMenu(){
    // BUTTONS
    $('.menu-widget.fg-button').focus(function(){
        $(this).removeClass('ui-state-default').addClass('ui-state-focus');
    });
    // MENU               
    $('.menu-widget.flyout').menu({
        content: $('.menu-widget.flyout').next().html(),
        flyOut: true
    });
}

function initTabs(){
    $("#tabs").tabs().find(".ui-tabs-nav").sortable({
        axis: 'x'
    });
}

function initObjTable(){
    $.fn.dataTableExt.oSort['date-euro-asc'] = function(a, b){
        a = a.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        b = b.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        if (trim(a) != '') {
            var frDatea = trim(a).split(' ');
            var frTimea = frDatea[1].split(':');
            var frDatea2 = frDatea[0].split('.');
            var x = (frDatea2[2] + frDatea2[1] + frDatea2[0] + frTimea[0] + frTimea[1]) * 1;
        }
        else {
            var x = 10000000000000; // = l'an 1000 ...
        }
        
        if (trim(b) != '') {
            var frDateb = trim(b).split(' ');
            var frTimeb = frDateb[1].split(':');
            frDateb = frDateb[0].split('.');
            var y = (frDateb[2] + frDateb[1] + frDateb[0] + frTimeb[0] + frTimeb[1]) * 1;
        }
        else {
            var y = 10000000000000;
        }
        var z = ((x < y) ? -1 : ((x > y) ? 1 : 0));
        return z;
    };
    
    $.fn.dataTableExt.oSort['date-euro-desc'] = function(a, b){
        a = a.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        b = b.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        if (trim(a) != '') {
            var frDatea = trim(a).split(' ');
            var frTimea = frDatea[1].split(':');
            var frDatea2 = frDatea[0].split('.');
            var x = (frDatea2[2] + frDatea2[1] + frDatea2[0] + frTimea[0] + frTimea[1]) * 1;
        }
        else {
            var x = 10000000000000;
        }
        
        if (trim(b) != '') {
            var frDateb = trim(b).split(' ');
            var frTimeb = frDateb[1].split(':');
            frDateb = frDateb[0].split('.');
            var y = (frDateb[2] + frDateb[1] + frDateb[0] + frTimeb[0] + frTimeb[1]) * 1;
        }
        else {
            var y = 10000000000000;
        }
        var z = ((x < y) ? 1 : ((x > y) ? -1 : 0));
        return z;
    };
    
    /*
     * html sorting (ignore html tags)
     */
    $.fn.dataTableExt.oSort['html-string-asc'] = function(a, b){
        var x = a.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        var y = b.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
    };
    
    $.fn.dataTableExt.oSort['html-string-desc'] = function(a, b){
        var x = a.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        var y = b.replace(/&lt;(.|\n)*?&gt;/g, "").toLowerCase();
        return ((x < y) ? 1 : ((x > y) ? -1 : 0));
    };
    //TABLE
    oTable = $('#obj-table').dataTable({
        "sDom": '<"top"lf><"thetable"rt><"bottom"ip>',
        "sPaginationType": "full_numbers",
        "bLengthChange": true,
        "bStateSave": true,
        "bProcessing": true,
        "bAutoWidth": false,
        "aaSorting": [[4, "asc"]],
        "oLanguage": {
            "sUrl": langloc
        },
        "fnDrawCallback": function(){ //set arrows
            $('th.sorting a').find('span').attr('class', 'ui-icon ui-icon-triangle-2-n-s');
            $('th.sorting_asc a').find('span').attr('class', 'ui-icon ui-icon-triangle-1-n');
            $('th.sorting_desc a').find('span').attr('class', 'ui-icon ui-icon-triangle-1-s');
        },
        "aoColumns": [{
            "bSortable": false
        }, null, //{ "sType": "numeric" },
        {
            "bSortable": false
        }, {
            "sType": "html-string"
        }, {
            "sType": "date-euro"
        }, {
            "bSortable": false
        }, //
        {
            "bSortable": false
        }, ]
    });
    
}

$(document).ready(function(){
    setARIARoles();
	
    initCreateMenu();
    initHelpMenu();
    initMenuMenu();
	$('.help-widget, .create-widget, .menu-widget').css('display', 'block');
    initfgButtons();
    //inituiDatepicker();
    var calendarIcon = imageFolder + 'calendar.gif';
    $.datepicker.setDefaults($.datepicker.regional['de']);
    
    $('#input-validfrom').datepicker({
        showOn: 'button',
        buttonImage: calendarIcon,
        buttonText: calendarSelector,
        buttonImageOnly: true,
        showMonthAfterYear: false,
        dateFormat: 'DD, d MM, yy'
    });
    
    $('#input-validto').datepicker({
        showOn: 'button',
        buttonImage: calendarIcon,
        buttonText: calendarSelector,
        buttonImageOnly: true,
        showMonthAfterYear: false,
        dateFormat: 'DD, d MM, yy'
    });
    $('#input-validfrom').next('img').attr('role', 'aria-button');
    $('#input-validto').next('img').attr('role', 'aria-button');
    
    initAccordion();
    
    //initTabs();
    //initObjTable();
    //IE hack							
    jQuery.each(jQuery.browser, function(i){
        if ($.browser.msie) {
        }
    });
    $(':hidden').attr('display', '');
    $(':hidden').attr('position', 'absolute');
    $(':hidden').attr('left', '-10000px');
    
});
function initfgButtons(){

    $("button.fg-button").focus(function(){
        $(this).addClass("ui-state-hover");
    });
}

function inituiDatepicker(){
    $.datepicker.setDefaults($.datepicker.regional['de']);
    $('.hasDatepicker').datepicker({
        showOn: 'button',
        buttonImage: 'http://testlx1.uibk.ac.at/ximsroot/skins/default/images/calendar.gif',
        buttonImageOnly: true,
        showMonthAfterYear: false
    });
    
}

function initAccordion(){
	$("#accordion").accordion({
		autoHeight: false,
		collapsible: true

	});
/*
        $('#accordion .head').click(function(){
            $(this).next().toggle('blind');
            return false;
        }).next().hide();
*/
}

    function getXMLHTTPObject() {
        var xmlhttp=false;
        /*@cc_on @*/
        /*@if (@_jscript_version &gt;= 5)
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
            //var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?test_wellformedness=1')"/>";
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not check well-formedness.")
                    }
                    else {
                        alert(xmlhttp.responseText + '\n');
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('test_wellformedness=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
		
function prettyprint() {
            var xmlhttp = getXMLHTTPObject();
            //var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?', $ppmethod, '=1')"/>";
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not pretty print.")
                    }
                    else {
                        document.eform.body.value=xmlhttp.responseText;
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('<xsl:value-of select="$ppmethod"/>=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }

    function getObjTypeFromQuery() {
        var str = document.location.search;
        var searchToken = "objtype=";
        var fromPos = str.indexOf(searchToken) + searchToken.length;
        var subStr = str.substring(fromPos, str.length);
        return(subStr.substring(0, subStr.indexOf(";")));
    }

 