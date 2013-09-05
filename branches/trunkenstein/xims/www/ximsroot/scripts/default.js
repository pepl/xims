/*
 # Copyright (c) 2002-2011 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id$
 */
function confirmDelete(){
    if (confirm("Are you sure?")) {
        return true
    }
    else {
        return false
    }
}

function genericWindow(url, width, height){
    var height = (height == null) ? "400" : height;
    var width = (width == null) ? "400" : width;
    
    newWindow = window.open(url, "displayWindow", "resizable=yes,scrollbars=yes,width=" +
    width +
    ",height=" +
    height +
    ",screenX=100,screenY=300");
}

function previewWindow(url){
    newWindow = window.open(url, "displayWindow", "resizable=yes,scrollbars=yes,width=800,height=600,screenX=10,screenY=10");
}

function diffWindow(url){
    newWindow = window.open(url, "displayWindow", "resizable=yes,scrollbars=yes,width=750,height=450,screenX=30,screenY=30");
}

function openDocWindow(topic){
    docWindow = window.open("http://xims.info/documentation/users/xims-user_s-reference.sdbk#" + escape(topic), "displayWindow", "resizable=yes,scrollbars=yes,width=800,height=480,screenX=100,screenY=300");
}

function createFilterWindow(url){
    newWindow = window.open(url, "displayWindow", "resizable=no,scrollbars=no,width=660,height=575,screenX=10,screenY=10");
}

function getParamValue(param){
    var objQuery = new Object();
    var objQuery2 = new Object();
    var windowURL;
    var strQuery = location.search.substring(1);
    var aryQuery = strQuery.split(";");
    var aryQuery2 = strQuery.split("&");
    var pair = [];
    var pair2 = [];
    var i;
    for (i = 0; i < aryQuery.length; i++) {
        pair = aryQuery[i].split("=");
        if (pair.length == 2) {
            objQuery[unescape(pair[0])] = unescape(pair[1]);
        }
    }
    for (i = 0; i < aryQuery2.length; i++) {
        pair2 = aryQuery2[i].split("=");
        if (pair2.length == 2) {
            objQuery2[unescape(pair2[0])] = unescape(pair2[1]);
        }
    }
    
    var hls = objQuery[param] ? objQuery[param] : objQuery2[param];
    return hls;
}

var highlighted = false;
function stringHighlight(mystring){
    if (highlighted || !mystring) {
        return;
    }
    re = /\s+/;
    var splitted = mystring.split(re);
    var highlightStart = '<span name="highlighted" style="background: yellow">';
    var highlightEnd = '</span>';
    
    for (var i in splitted) {
        var body = document.getElementById("body");
        var content = body.innerHTML;
        var lcContent = content.toLowerCase();
        var newContent = '';
        var searchTerm = splitted[i];
        var j = -1;
        var lcSearchTerm = searchTerm.toLowerCase();
        
        while (content.length > 0) {
            j = lcContent.indexOf(lcSearchTerm, j + 1);
            if (j < 0) {
                newContent += content;
                content = '';
            }
            else {
                // skip anything inside a tag
                if (content.lastIndexOf(">", j) >= content.lastIndexOf("<", j)) {
                    // skip anything inside scripts
                    if (lcContent.lastIndexOf("/script>", j) >= lcContent.lastIndexOf("<script", j)) {
                        newContent += content.substring(0, j) + highlightStart + content.substr(j, searchTerm.length) + highlightEnd;
                        content = content.substr(j + searchTerm.length);
                        lcContent = content.toLowerCase();
                        j = -1;
                    }
                }
            }
        }
        body.innerHTML = newContent;
    }
    
    highlighted = true
}

function toggleHighlight(hls){
    var cssText;
    if (highlighted == false) {
        cssText = 'background: yellow';
        highlighted = true;
    }
    else {
        cssText = '';
        highlighted = false;
    }
    
    var els;
    var i;
    if (document.all) {
        els = document.getElementsByTagName("span");
        for (i = 0; i < els.length; i++) {
            if (els[i].name == 'highlighted') {
                els[i].style.cssText = cssText;
            }
        }
    }
    else {
        els = document.getElementsByName('highlighted');
        for (i = 0; i < els.length; i++) {
            els[i].style.cssText = cssText;
        }
    }
}

/*
   function which selects 'trytobalance' input form element to a
   given value (e.g. from cookie); see 'document_edit.xsl'
*/
      function selTryToBalance(selElement, toSelect) {
          if ( !toSelect ) {
              toSelect = 'true';
          }   
          toSelect = toSelect.toLowerCase();
          for (var i=0; i < selElement.length; i++) {
              if ( selElement[i].value.toString().toLowerCase() == toSelect ) {
                  selElement[i].checked = true;
              }   
          }   
      }

      function createCookie(name,value,days) {
          if (days) {
              var date = new Date();
              date.setTime(date.getTime()+(days*24*60*60*1000));
              var expires = "; expires="+date.toGMTString();
          }
          else var expires = "";
          document.cookie = name+"="+value+expires+"; path=/";
      }

      function readCookie(name) {
          var nameEQ = name + "=";
          var ca = document.cookie.split(';');
          for (var i=0;i < ca.length;i++) {
              var c = ca[i];
              while (c.charAt(0)==' ') c = c.substring(1,c.length);
              if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
          }
          return null;
      }

      function setSel(selObj, toselect) {
          if ( !toselect ) {
                  toselect = 'plain';
          }
          toselect = toselect.toLowerCase();
          opts=selObj.options,
          i=opts.length;
          while (i-- > 0) {
              if(opts[i].value.toLowerCase()==toselect) {
                  selObj.selectedIndex=i;
                  return true;
              }
          }
          return false;
      }
      
      function checkBodyFromSel (selection, type) {

        createCookie('xims_'+type+'editor',selection,90);

        if ( hasBodyChanged() ) {
            $('#xims_'+type+'editor').attr("disabled",true);
            alert(bodyContentChanged);
            return false;
        }
      /*
      reload with param 'true' in order to fetch (clean) content from
      server again; this interfears the least with JS-WYSIWYG editors
      */
        window.location.reload(true);

        return true;
    }

      function hasBodyChanged () {
          var currentbody;

          // check for TinyMCE editor content
          if (window.tinyMCE){
              currentbody = tinyMCE.get('body').getContent();
          }
          // Plain Textarea
          else {
              var body = document.getElementById('body');
              if ( body && body.value ) {
                  currentbody = body.value;
              }
          }
          // now lets check if there are any changes ;-)
          if ( currentbody && currentbody != origbody ) {
              return true;
          }
          // return false otherwise
          else {
              return false;
          }
      }
      
      /*
      Disable possibility of changing editors for "timeout"
      seconds. This prevents false-positive errors of "hasBodyChanged()"
      due to switching to another editor too fast.
      type : one of 'wysiwyg' or 'code'
      */
      function timeoutEditorChange(timeout, type) {
        $('#xims_'+type+'editor').attr("disabled",true);;
        //document.getElementById('xims_wysiwygeditor').disabled = true;
        window.setTimeout(function(){$('#xims_'+type+'editor').removeAttr('disabled');},timeout*1000);
    }
