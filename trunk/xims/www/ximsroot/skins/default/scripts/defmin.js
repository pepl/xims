function confirmDelete(){if(confirm("Are you sure?")){return true}else{return false}}function genericWindow(b,c,a){var a=(a==null)?"400":a;var c=(c==null)?"400":c;newWindow=window.open(b,"displayWindow","resizable=yes,scrollbars=yes,width="+c+",height="+a+",screenX=100,screenY=300")}function previewWindow(a){newWindow=window.open(a,"displayWindow","resizable=yes,scrollbars=yes,width=800,height=600,screenX=10,screenY=10")}function diffWindow(a){newWindow=window.open(a,"displayWindow","resizable=yes,scrollbars=yes,width=750,height=450,screenX=30,screenY=30")}function openDocWindow(a){docWindow=window.open("http://xims.info/documentation/users/xims-user_s-reference.sdbk#"+escape(a),"displayWindow","resizable=yes,scrollbars=yes,width=800,height=480,screenX=100,screenY=300")}function createFilterWindow(a){newWindow=window.open(a,"displayWindow","resizable=no,scrollbars=no,width=660,height=575,screenX=10,screenY=10")}function getParamValue(d){var e=new Object();var k=new Object();var j;var h=location.search.substring(1);var b=h.split(";");var c=h.split("&");var f=[];var l=[];var g;for(g=0;g<b.length;g++){f=b[g].split("=");if(f.length==2){e[unescape(f[0])]=unescape(f[1])}}for(g=0;g<c.length;g++){l=c[g].split("=");if(l.length==2){k[unescape(l[0])]=unescape(l[1])}}var a=e[d]?e[d]:k[d];return a}var highlighted=false;function stringHighlight(l){if(highlighted||!l){return}re=/\s+/;var k=l.split(re);var m='<span name="highlighted" style="background: yellow">';var a="</span>";for(var e in k){var f=document.getElementById("body");var g=f.innerHTML;var b=g.toLowerCase();var h="";var c=k[e];var d=-1;var n=c.toLowerCase();while(g.length>0){d=b.indexOf(n,d+1);if(d<0){h+=g;g=""}else{if(g.lastIndexOf(">",d)>=g.lastIndexOf("<",d)){if(b.lastIndexOf("/script>",d)>=b.lastIndexOf("<script",d)){h+=g.substring(0,d)+m+g.substr(d,c.length)+a;g=g.substr(d+c.length);b=g.toLowerCase();d=-1}}}}f.innerHTML=h}highlighted=true}function toggleHighlight(a){var d;if(highlighted==false){d="background: yellow";highlighted=true}else{d="";highlighted=false}var c;var b;if(document.all){c=document.getElementsByTagName("span");for(b=0;b<c.length;b++){if(c[b].name=="highlighted"){c[b].style.cssText=d}}}else{c=document.getElementsByName("highlighted");for(b=0;b<c.length;b++){c[b].style.cssText=d}}};function openCloseInlinePopup(e,d,b,f){var a;var c;if(!f){c="xims_ilp_btn_select"}else{c=f}if(e=="open"){if(navigator.userAgent.indexOf("MSIE")!=-1){document.getElementById(d).style.height=1000}a="block"}else{a="none"}document.getElementById(d).style.display=a;document.getElementById(b).style.display=a;if(e=="open"){document.getElementById(c).focus()}};