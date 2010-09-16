/**
 * @author suse
 */
$(document).ready(function(){
    
    $("#input-location").change(function(){
        testlocation();
    });
	$("#input-title").change(function(){
        testtitle();
    });
    
    /*
$("#dialog_link").live("click", function(){
        $('#dialog').dialog('open');
    });
*/
	$("#dialog_link").click(function(){
        $('#dialog').dialog('open');
    });
    
	$('#location-dialog').dialog({
        autoOpen: false,
        width: 600
		});
	$('#dialog').dialog({
        autoOpen: false,
        width: 600
		});

});

function updateDialog(suggestedLength, suggestedLocation){ 
	var warningMessage = locWarnText1 + "<strong>" + suggestedLength + " </strong>" + locWarnText2 +
	"<strong>" + suggestedLocation + "</strong> ? ";
	var jsonOptions = {};
	var buttons = {};
	buttons[locWarnButton] = function() { setLocation(suggestedLocation);
							$("#dialog_link").hide();
							$(this).dialog("close"); }
	$('#dialog').dialog('option', 'buttons', buttons );
	$("#dialog").html(warningMessage);
}

function setLocation(loc){
    $("#input-location").val(loc);
}

/*
//<!-- give notice that location needs to be set first -->
function enterCheckLoc(){
	
	var loc = $('#input-location').val();
	
    // <!-- open il-popup when location has not been entered yet -->
    if (loc.length < 1) {
		notice = textLocFirst;
		buttons[btnOK] = function(){
			$('#input-location').focus();
			$(this).dialog('close');
		}
		$("#location-dialog").dialog('option', 'buttons', buttons );
	    $("#location-dialog").html(notice);
		
		$('#dialog').dialog('open');
	
	}
}
*/

//<!-- returns objtype query param value -->
function getObjTypeFromQuery(){
    var str = document.location.search;
    var searchToken = "objtype=";
    var fromPos = str.indexOf(searchToken) + searchToken.length;
    var subStr = str.substring(fromPos, str.length);
    return (subStr.substring(0, subStr.indexOf(";")));
}
 
//<!-- main function for testlocation event handling -->
function testlocation(){

    var location = $("#input-location").val();
	location = location.replace(/[<]/g,'');
	location = location.replace(/[>]/g,'');
    location = appendSuffixes(location);

	var jsonQuery = {
        test_location: "1",
        objtype: obj,
        name: location
    };

    var statusCode;
    var processedLocation;
    var defaultReason;
    var validChars;
    var suggestedLength;
    var suggestedLocation;
	
    $.ajax({
        type: 'GET',
        url: abspath,
        dataType: 'json',
        data: jsonQuery,
        success: function(jsonObject){
            statusCode = jsonObject.status;
            processedLocation = jsonObject.location;
            defaultReason = jsonObject.reason;
            validChars = jsonObject.valChars;
            suggestedLength = jsonObject.suggLength;
            suggestedLocation = jsonObject.suggLocation;

        	if(setLocationDialog(location, processedLocation, statusCode, validChars)){
        		$("#location-dialog").dialog('open');
        	}
            
            if ((processedLocation != suggestedLocation) && (jQuery.inArray(new Array('Document', 'Image', 'File'), obj))) {
                //updateWarning(suggestedLength, suggestedLocation);
                updateDialog(suggestedLength, suggestedLocation);
                var loc = $("#input-location").val();
                
                if ((loc.length > suggestedLength) && (loc != suggestedLocation)) {
                    $('#dialog_link').fadeIn(3000);
                }
                else {
                    $('#dialog_link').fadeOut('fast');
                }
            }
        }
    });
}

function setLocationDialog(location, processedLocation, statusCode, validChars){
	
    var controlHtml;
	var buttons = {};
	
    /*<!-- choose response according to statusCode. remember: 
     0 => Location (is) OK
     1 => Location already exists (in container)
     2 => No location provided (or location is not convertible)
     3 => Dirty (no sane) location (location contains hilarious characters)
     -->*/

    switch (statusCode) {
        case '0':
            //OK (see if location has been mangled and we dont have an URLLink Object)
            if ((obj.toUpperCase() != 'URLLINK') && (location != processedLocation)) {
                //we would change location on save so report this to user                                         
                notice = textChange + "<br/><br/>";
                notice += '<pre style="color: Maroon;">' + processedLocation + "</pre>";
				buttons[btnIgnore] = function(){
					setLocation(processedLocation);
					$(this).dialog('close');
				}
				buttons[btnChange] = function(){ 
					$('#input-location').focus(); $(this).dialog('close'); 
				}
            }
			else return 0;
            break;
        case '1':
            //loc exists       
			notice = textExists;
				buttons[btnOK] = function(){
					$('#input-location').focus(); $(this).dialog('close');
				}
            break;
        // no need for popup, location will be generated from title
		case '2':
			/*
            //no loc
			notice = textNoLoc;
				buttons[btnOK] = function(){
					$('#input-location').focus(); $(this).dialog('close');
				}
				*/
			return 0;
            break;
        case '3':
            //dirty loc
			notice = textDirtyLoc + validChars;
				buttons[btnOK] = function(){
					$('#input-location').focus(); $(this).dialog('close');
				} 
            break;
        default:
            //debug message
			notice = "Unknown response code of event 'test_location'!";
				buttons[btnOK] = function(){
					$('#input-location').focus(); $(this).dialog('close');
				}
            break;
    }
	$("#location-dialog").dialog('option', 'buttons', buttons );
    $("#location-dialog").html(notice);
	return 1;
	
}

function appendSuffixes(location){
    // append suffixes with no lang-extension 
    if (location.length != 0 && obj.search(/(Document|sDocBookXML)$/i) != -1) {
        var searchres = location.search(/.*\.(html|sdbk)(\.[^.]+)?$/);
        if (searchres == -1) {
            // handle .html and .sdbk
            if (obj.search(/Document$/i) != -1) {
                location += '.html';
            }
            else {
                location += '.sdbk';
            }
        }
    }
    else {
        var searchres = location.search(/.*(\.[^.]+)$/);
        if (searchres == -1) {
            // append mime-type suffixes
            switch (obj) {
                case "AxPointPresentation":
                    location += '.axp';
                    break;
                case "CSS":
                    location += '.css';
                    break;
                case "JavaScript":
                    location += '.js';
                    break;
                case "Portlet":
                    location += '.ptlt';
                    break;
                case "TAN_List":
                    location += '.tls';
                    break;
                case "Text":
                    location += '.txt';
                    break;
                case "SQLReport":
                    location += '.html';
                    break;
                case "XSLStylesheet":
                    location += '.xsl';
                    break;
                case "XML":
                    location += '.xml';
                    break;
            }
        }
    }
    return location;
}

//<!-- main function for testtitle event handling -->
function testtitle(){

    var title = $("#input-title").val();
	var location = title; // = $("#input-location").val();
	location = location.replace(/[<]/g,'');
	location = location.replace(/[>]/g,'');
    location = appendSuffixes(location);

	var jsonQuery = {
        test_title: "1",
        objtype: obj,
        name: location
    };

    var statusCode;
    var processedTitle;
    var defaultReason;
    var validChars;
    var suggestedLength;
    var suggestedTitle;
	var suggestedLocation;
	
    $.ajax({
        type: 'GET',
        url: abspath,
        dataType: 'json',
        data: jsonQuery,
        success: function(jsonObject){
            statusCode = jsonObject.status;
            processedLocation = jsonObject.location;
            defaultReason = jsonObject.reason;
            validChars = jsonObject.valChars;
            suggestedLength = jsonObject.suggLength;
			suggestedLocation = jsonObject.suggLocation;

        	
			/*
if(setTitleDialog(location, processedTitle, statusCode, validChars)){
			        		$("#location-dialog").dialog('open');
			        	}
*/
			
			if($("#input-location").val() == ''){
				$("#input-location").val(suggestedLocation);
			}

            
            /*
if ((processedLocation != suggestedLocation) && (jQuery.inArray(new Array('Document', 'Image', 'File'), obj))) {
                //updateWarning(suggestedLength, suggestedLocation);
                updateDialog(suggestedLength, suggestedLocation);
                var loc = $("#input-location").val();
                
                if ((loc.length > suggestedLength) && (loc != suggestedLocation)) {
                    $('#dialog_link').fadeIn(3000);
                }
                else {
                    $('#dialog_link').fadeOut('fast');
                }
            }
*/
        }
    });
}


