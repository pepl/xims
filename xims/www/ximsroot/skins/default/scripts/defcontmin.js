function confirmDelete(){if(confirm("Are you sure?")){return true}else{return false}}function previewWindow(a){newWindow=window.open(a,"displayWindow","resizable=yes,scrollbars=yes,width=800,height=600,screenX=10,screenY=10")}function diffWindow(a){newWindow=window.open(a,"displayWindow","resizable=yes,scrollbars=yes,width=750,height=450,screenX=30,screenY=30")}function openDocWindow(a){docWindow=window.open("http://xims.info/documentation/users/xims-user_s-reference.sdbk#"+escape(a),"displayWindow","resizable=yes,scrollbars=yes,width=800,height=480,screenX=100,screenY=300")}function createFilterWindow(a){newWindow=window.open(a,"displayWindow","resizable=no,scrollbars=no,width=660,height=575,screenX=10,screenY=10")}function getParamValue(d){var e=new Object();var k=new Object();var j;var h=location.search.substring(1);var b=h.split(";");var c=h.split("&");var f=[];var l=[];var g;for(g=0;g<b.length;g++){f=b[g].split("=");if(f.length==2){e[unescape(f[0])]=unescape(f[1])}}for(g=0;g<c.length;g++){l=c[g].split("=");if(l.length==2){k[unescape(l[0])]=unescape(l[1])}}var a=e[d]?e[d]:k[d];return a}var highlighted=false;function stringHighlight(l){if(highlighted||!l){return}re=/\s+/;var k=l.split(re);var m='<span name="highlighted" style="background: yellow">';var a="</span>";for(var e in k){var f=document.getElementById("body");var g=f.innerHTML;var b=g.toLowerCase();var h="";var c=k[e];var d=-1;var n=c.toLowerCase();while(g.length>0){d=b.indexOf(n,d+1);if(d<0){h+=g;g=""}else{if(g.lastIndexOf(">",d)>=g.lastIndexOf("<",d)){if(b.lastIndexOf("/script>",d)>=b.lastIndexOf("<script",d)){h+=g.substring(0,d)+m+g.substr(d,c.length)+a;g=g.substr(d+c.length);b=g.toLowerCase();d=-1}}}}f.innerHTML=h}highlighted=true}function toggleHighlight(a){var d;if(highlighted==false){d="background: yellow";highlighted=true}else{d="";highlighted=false}var c;var b;if(document.all){c=document.getElementsByTagName("span");for(b=0;b<c.length;b++){if(c[b].name=="highlighted"){c[b].style.cssText=d}}}else{c=document.getElementsByName("highlighted");for(b=0;b<c.length;b++){c[b].style.cssText=d}}}function selTryToBalance(c,b){if(!b){b="true"}b=b.toLowerCase();for(var a=0;a<c.length;a++){if(c[a].value.toString().toLowerCase()==b){c[a].checked=true}}}function createCookie(c,d,e){if(e){var b=new Date();b.setTime(b.getTime()+(e*24*60*60*1000));var a="; expires="+b.toGMTString()}else{var a=""}document.cookie=c+"="+d+a+"; path=/"}function readCookie(b){var e=b+"=";var a=document.cookie.split(";");for(var d=0;d<a.length;d++){var f=a[d];while(f.charAt(0)==" "){f=f.substring(1,f.length)}if(f.indexOf(e)==0){return f.substring(e.length,f.length)}}return null}function setSel(b,a){if(!a){if(window.editor){a="htmlarea"}else{a="plain"}}a=a.toLowerCase();opts=b.options,i=opts.length;while(i-->0){if(opts[i].value.toLowerCase()==a){b.selectedIndex=i;return true}}return false}function checkBodyFromSel(a){createCookie("xims_wysiwygeditor",a,90);if(hasBodyChanged()){document.getElementById("xims_wysiwygeditor").disabled=true;alert(bodyContentChanged);return false}window.location.reload(true);return true}function hasBodyChanged(){var b;if(window.tinyMCE){b=tinyMCE.get("body").getContent()}else{var a=document.getElementById("body");if(a&&a.value){b=a.value}}if(b&&b!=origbody){return true}else{return false}}function timeoutWYSIWYGChange(a){document.getElementById("xims_wysiwygeditor").disabled=true;window.setTimeout("document.getElementById('xims_wysiwygeditor').disabled = false;",a*1000)};function openCloseInlinePopup(e,d,b,f){var a;var c;if(!f){c="xims_ilp_btn_select"}else{c=f}if(e=="open"){if(navigator.userAgent.indexOf("MSIE")!=-1){document.getElementById(d).style.height=1000}a="block"}else{a="none"}document.getElementById(d).style.display=a;document.getElementById(b).style.display=a;if(e=="open"){document.getElementById(c).focus()}};if(typeof HTMLElement!="undefined"&&!HTMLElement.prototype.insertAdjacentElement){HTMLElement.prototype.insertAdjacentElement=function(b,c){switch(b){case"beforeBegin":this.parentNode.insertBefore(c,this);break;case"afterBegin":this.insertBefore(c,this.firstChild);break;case"beforeEnd":this.appendChild(c);break;case"afterEnd":if(this.nextSibling){this.parentNode.insertBefore(c,this.nextSibling)}else{this.parentNode.appendChild(c)}break}};HTMLElement.prototype.insertAdjacentHTML=function(c,f){var e=this.ownerDocument.createRange();e.setStartBefore(this);var b=e.createContextualFragment(f);this.insertAdjacentElement(c,b)};HTMLElement.prototype.insertAdjacentText=function(c,e){var b=document.createTextNode(e);this.insertAdjacentElement(c,b)}}var firstLoad=0;var GlobalECState=0;var mdme=document.getElementById("MDME");if(mdme){window.onload=InitializePage}function InitializePage(){defineLayout();createTopMenu();prepareListStyles();setLEVELs();Icons();attachEventhandlers()}function defineLayout(){mdme.style.position="absolute";mdme.style.top=PagePositionTOP+"px";mdme.style.zIndex=50;mdme.style.display="block"}function setLEVELs(){ULCollection=mdme.getElementsByTagName("UL");ULCollection.item(0).setAttribute("level",1);LICollection=mdme.getElementsByTagName("LI");for(a=0;a<LICollection.length;a++){LICollection.item(a).setAttribute("level",1)}if(ULCollection!=null){for(u=0;u<ULCollection.length;u++){var b=ULCollection.item(u).getElementsByTagName("UL");for(l=0;l<b.length;l++){var c=parseInt(ULCollection.item(u).getAttribute("level"));b.item(l).setAttribute("level",c+1);var e=b.item(l).getElementsByTagName("LI");for(m=0;m<e.length;m++){e.item(m).setAttribute("level",c+1)}}}}}function createTopMenu(){if(showECOption=="yes"&&oneBranch!="yes"){var b="";b+='<TABLE border="0" cellpadding="2" cellspacing="0" class="topMenu">';b+="<TR>";b+='<TD id="expandAllMenuItem" onClick="ECALL(1)">';if(imageEXPANDALL==""){b+="Expand ALL</TD>"}else{b+='<IMG border="0" src="'+imageEXPANDALL+'" alt="Expand ALL"></TD>'}b+='<TD id="collapseAllMenuItem" onClick="ECALL(0)">';if(imageCOLLAPSEALL==""){b+="Collapse ALL</TD>"}else{b+='<IMG border="0" src="'+imageCOLLAPSEALL+'" alt="Collapse ALL"></TD>'}b+="</TR>";b+="</TABLE>";mdme.insertAdjacentHTML("afterBegin",b);if(GlobalECState==0){document.getElementById("expandAllMenuItem").style.display="inline";document.getElementById("collapseAllMenuItem").style.display="none"}else{document.getElementById("expandAllMenuItem").style.display="none";document.getElementById("collapseAllMenuItem").style.display="inline"}}}function prepareListStyles(){ULCollection=mdme.getElementsByTagName("UL");if(ULCollection!=null){for(u=0;u<ULCollection.length;u++){ULCollection.item(u).style.listStyleType="none";ULCollection.item(u).setAttribute("id","ULID"+u)}}}function attachEventhandlers(){LICollection=mdme.getElementsByTagName("LI");if(LICollection!=null){for(l=0;l<LICollection.length;l++){LICollection.item(l).onmouseup=onMouseUpHandler}}if(navigator.appName=="Microsoft Internet Explorer"){mdme.style.filter="progid:DXImageTransform.Microsoft.Alpha(opacity="+TValue+")"}else{mdme.style.MozOpacity=1;TValue=parseFloat(TValue/100-0.001);mdme.style.MozOpacity=TValue}}function ECALL(b){LICollection=mdme.getElementsByTagName("LI");if(LICollection!=null){for(d=0;d<LICollection;d++){LICollection.item(i).style.listStyleImage="none"}}firstLoad=0;GlobalECState=0;Icons();if(showECOption=="yes"&&oneBranch!="yes"){if(GlobalECState==0){document.getElementById("expandAllMenuItem").style.display="inline";document.getElementById("collapseAllMenuItem").style.display="none"}else{document.getElementById("expandAllMenuItem").style.display="none";document.getElementById("collapseAllMenuItem").style.display="inline"}}}function Icons(b){LICollection=mdme.getElementsByTagName("LI");if(LICollection!=null){for(i=0;i<LICollection.length;i++){ULChildrenCol=LICollection.item(i).getElementsByTagName("UL");if(ULChildrenCol.length>0){FirstULWithinLI_ELEMENT=LICollection.item(i).getElementsByTagName("UL");if(firstLoad==0){if(GlobalECState==0){LICollection.item(i).setAttribute("ECState",0);if(imagePLUS!=""){LICollection.item(i).style.listStyleImage="url("+imagePLUS+")";LICollection.item(i).style.listStylePosition="inside"}LICollection.item(i).style.cursor="pointer";FirstULWithinLI_ELEMENT.item(0).style.display="none"}else{LICollection.item(i).setAttribute("ECState",1);if(imageMINUS!=""){LICollection.item(i).style.listStyleImage="url("+imageMINUS+")";LICollection.item(i).style.listStylePosition="inside"}LICollection.item(i).style.cursor="pointer";FirstULWithinLI_ELEMENT.item(0).style.display="block"}}else{State=LICollection.item(i).getAttribute("ECState");if(State==0){if(imagePLUS!=""){LICollection.item(i).style.listStyleImage="url("+imagePLUS+")";LICollection.item(i).style.listStylePosition="inside"}FirstULWithinLI_ELEMENT.item(0).style.display="none"}else{if(oneBranch=="yes"&&b!=null){targetLevel=b.getAttribute("level");tarObjParentLICol=b.parentNode.getElementsByTagName("LI");for(tar=0;tar<tarObjParentLICol.length;tar++){ItemLevel=tarObjParentLICol.item(tar).getAttribute("level");if(targetLevel==ItemLevel){tarObjParentLIULCol=tarObjParentLICol.item(tar).getElementsByTagName("UL");if(tarObjParentLIULCol.length!=0&&b!=tarObjParentLICol.item(tar)){tarObjParentLIULCol.item(0).style.display="none";if(imagePLUS!=""){tarObjParentLICol.item(tar).style.listStyleImage="url("+imagePLUS+")";tarObjParentLICol.item(tar).style.listStylePosition="inside";tarObjParentLICol.item(tar).setAttribute("ECState",0)}}}}}if(imageMINUS!=""){LICollection.item(i).style.listStyleImage="url("+imageMINUS+")";LICollection.item(i).style.listStylePosition="inside"}FirstULWithinLI_ELEMENT.item(0).style.display="block"}}}else{LICollection.item(i).style.listStyleImage="none"}}}if(firstLoad==0){firstLoad=1}if(showECOption=="yes"&&oneBranch!="yes"){document.getElementById("expandAllMenuItem").style.cursor="pointer";document.getElementById("collapseAllMenuItem").style.cursor="pointer"}}function onMouseUpHandler(b){var c;if(!b){var b=window.event}if(b.target){c=b.target}else{if(b.srcElement){c=b.srcElement}}if(c.nodeType==3){c=c.parentNode}c=findTH(c);State=c.getAttribute("ECState");if(State==0){c.setAttribute("ECState",1)}else{c.setAttribute("ECState",0)}Icons(c);b.cancelBubble=true}function findTH(b){if(b.tagName=="LI"){return b}else{if(b.tagName=="UL"){return b.firstChild}else{return findTH(b.parentNode)}}};var PagePositionLEFT=470;var PagePositionTOP=75;var oneBranch="no";var showECOption="no";var TValue=100;var imagePLUS="/ximsroot/skins/default/images/create_menu_folderplus.gif";var imageMINUS="/ximsroot/skins/default/images/create_menu_folderminus.gif";var imageEXPANDALL="/ximsroot/skins/default/images/create_menu_folderexpandall.gif";var imageCOLLAPSEALL="/ximsroot/skins/default/images/create_menu_foldercollapseall.gif";