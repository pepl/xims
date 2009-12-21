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
}

function initCreateMenu(){        
    $('.create-widget.flyout').menu({
        content: $('.create-widget.flyout').next().html(),
		maxHeight: 300,
		directionH: 'right', //horizontal direction in which the menu will open, to the right or left
		directionV: 'down',	//vertical direction in which the menu will open, up or down
		detectH: false, // horizontal collision detection
		detectV: false, // vertical collision detection
        flyOut: true
    });
}

function initHelpMenu(){             
    $('.help-widget.flyout').menu({
        content: $('.help-widget.flyout').next().html(),
        flyOut: true
    });
}

function initMenuMenu(){            
    $('.menu-widget.flyout').menu({
        content: $('.menu-widget.flyout').next().html(),
        flyOut: true
    });
}
function initAuthorsDD(){
	$('#flat-authors').menu({
		content: $('#flat-authors').next().html(), // grab content from this page
	}); 
}
function initEditorsDD(){
	$('#flat-editors').menu({
		content: $('#flat-editors').next().html(), // grab content from this page
	}); 
}
function initSerialsDD(){
	$('#flat-serials').menu({
		content: $('#flat-serials').next().html(), // grab content from this page
	}); 
}

function addProperty( property, fullname ) {
    original = eval( "document.eform.vl" + property );
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

function getTotalWidth(obj){
	return obj.width() + 
		parseInt(obj.css('margin-left').replace("px", "")) + 
		parseInt(obj.css('margin-right').replace("px", "")) + 
		parseInt(obj.css('padding-left').replace("px", "")) + 
		parseInt(obj.css('padding-right').replace("px", ""));
	
}

function findPos(obj) {    
        var position = $(obj).offset();
	    return [position.left, position.top];
	}

$(document).ready(function(){
    setARIARoles();
	
    initCreateMenu();
    initHelpMenu();
    initMenuMenu();
	initAuthorsDD();
	initEditorsDD();
	initSerialsDD();
	
	$('#help-widget, #create-widget, #menu-widget').css('display', 'inline-block');
	$('.fg-button').focus(
		function(){ $(this).removeClass('ui-state-default').addClass('ui-state-focus'); }
		//,
		//function(){ $(this).removeClass('ui-state-focus').addClass('ui-state-default'); }
	);
	$('.fg-button').hover(
		function(){ $(this).removeClass('ui-state-default').addClass('ui-state-focus'); },
		function(){ $(this).removeClass('ui-state-focus').addClass('ui-state-default'); }
	); 

    //IE hack							
    jQuery.each(jQuery.browser, function(i){
        if ($.browser.msie) {
        }
    });
    
});

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
            xmlhttp.send(ppmethod+'=1&body='+encodeURIComponent(document.eform.body.value));
            return false;
        }

    function getObjTypeFromQuery() {
        var str = document.location.search;
        var searchToken = "objtype=";
        var fromPos = str.indexOf(searchToken) + searchToken.length;
        var subStr = str.substring(fromPos, str.length);
        return(subStr.substring(0, subStr.indexOf(";")));
    }

function object_type_filter(){
	var inputs = document.getElementsByTagName("input");
    var re = new RegExp("filter_ot_");
    var el;
    for (var i = inputs.length - 1; i > 0; --i ) {
    	re.test(inputs[i].name);
        if (RegExp.rightContext.length > 0) {
        	el = document.getElementById("ot_" + RegExp.rightContext)
            if ( el )
            	el.checked = 1;
         }
	}
}


 