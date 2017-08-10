/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

(function() {
	tinymce.PluginManager.requireLangPack('xmlinclude');
	tinymce.create('tinymce.plugins.xmlinclude', {
		init : function(ed, url) {
			//add xi:xmlns namespace so IE properly recognizes xi:include tags
			//$('meta').attr('content', 'application/xhtml+html');
			document.documentElement.setAttribute("xmlns:xi", "http://www.w3.org/2001/XInclude");
			
			// Register commands
			ed.addCommand('mcexmlinclude', function() {
				//Popup window
				ed.windowManager.open({
					file : url + '/xmlinclude.html',
					width : 380 + parseInt(ed.getLang('xmlinclude.delta_width', 0)),
					height : 380 + parseInt(ed.getLang('xmlinclude.delta_height', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});

			// Register buttons
			ed.addButton('xlink', {
				title : 'xmlinclude.desc',
				cmd : 'mcexmlinclude'
			});
			
			//toggle Button State
			ed.onNodeChange.add(function(ed, cm, n, co, o) {
				n = ed.dom.getParent(n, 'span.xml_include');
				cm.setActive('xlink', 0);
				// Activate all
				if(n){
					do{
						//cm.setDisabled('xlink', 0);
						cm.setActive('xlink', 1);
					}
					while(n = n.parentNode);
				}
				//take care of empty or faulty span tags
				tinymce.each(ed.dom.select('span.xml_include', o.node), function(n) {
					if(!n.hasChildNodes() || (n.hasChildNodes() && n.firstChild.nodeName.toLowerCase() == "br" ))
					{
						if(tinymce.isWebKit)
						{
							var toBeDeleted = false;
							ed.selection.select(n);
							var nParent = n.parentNode;
							if(n.innerHTML)
							{
								toBeDeleted = true;
							}
							ed.dom.remove(n);
							var rng = ed.dom.createRng();
							rng.setStart(nParent, nParent.length);
							rng.setEnd(nParent, nParent.length);
							ed.selection.setRng(rng);
							
							if(toBeDeleted)
							{
								ed.execCommand('mceInsertContent', false, "<br/>");
							}
							ed.selection.collapse(false);
						}
						else
						{
							ed.dom.remove(n);
						}
					}
				});
			});
			
			//parse span tags to xi:include tags to display in source view
			ed.onPreProcess.add(function(ed, o) {
				var elm;
				var domelm;
				var wrapper;
				var xinc_path;
				tinymce.each(ed.dom.select('span.xml_include', o.node), function(n) {
					//$(n).children().unwrap();
					//elm = '<xi:include href="'+$(n).attr('title')+'" xmlns:xi", "http://www.w3.org/2001/XInclude ></xi:include>';
					//var erg = $(n).children().unwrap().wrap(elm);
					var xi_title='';
					var xi_name='';
					var i=($(n).attr('title')).lastIndexOf('#');
          				if(i>=0){
						xi_title = ($(n).attr('title')).substring(0,i);
						xi_name = ($(n).attr('title')).substring(i+1);
					}
					else{
					 xi_title = $(n).attr('title');
					}
					if(xi_name != ''){
                                        	elm = '<xi:include href="'+xi_title+'" xpointer="'+xi_name+'" xmlns:xi="http://www.w3.org/2001/XInclude" ><xi:fallback>'+$(n).html()+'</xi:fallback></xi:include>';
					}
					else{
        					elm = '<xi:include href="'+xi_title+'" xmlns:xi="http://www.w3.org/2001/XInclude" ><xi:fallback>'+$(n).html()+'</xi:fallback></xi:include>';
					}					
					$(n).replaceWith(elm);
					//alert("preprocess2: "+$('#content').html());
					/*
					//IE ignores innerHTML when created with tinymce.dom, therefore use native JS createElement method to tell IE that custom tag is valid HTML
					//to make domelm.innerHTML work, declare xmlns:xi in head and wrap in span tag to be able to set innerHTML of domelm
					wrapper = document.createElement('span');
					domelm = document.createElement('xi:include');
					wrapper.appendChild(domelm);
					domelm.setAttribute("xmlns:xi", "http://www.w3.org/2001/XInclude");
					xinc_path = (n.title).split('#',2);
					domelm.setAttribute("href", xinc_path[0]);
					if(xinc_path[1]){
						domelm.setAttribute("xpointer", xinc_path[1]);
					}
					if(tinymce.isIE)
					{
						wrapper.appendChild(document.createTextNode(n.innerHTML));
					}
					else
					{
						domelm.appendChild(document.createTextNode(n.innerHTML));
					}
					//domelm.show = n.className.split(/\s+/)[0];
					document.body.appendChild(wrapper);
					alert($(n).parent().html());
					ed.dom.replace(wrapper, n);
					*/
    			});				
			});
			
			//parse span tags to xi:include for saving
			ed.onSaveContent.add(function(ed, o) {
				var elm, domelm, wrapper;
				var xinc_path;
				tinymce.each(ed.dom.select('span.xml_include', o.node), function(n) {
					//elm = '<xi:include href="'+$(n).attr('title')+'" xmlns:xi", "http://www.w3.org/2001/XInclude ></xi:include>';
					//var erg = $(n).children().unwrap().wrap(elm);
					var xi_title='';
					var xi_name='';
					var i=($(n).attr('title')).lastIndexOf('#');
          				if(i>=0){
						xi_title = ($(n).attr('title')).substring(0,i);
					}
					else{
					 xi_title = $(n).attr('title');
					}
					if(xi_name != ''){
						elm = '<xi:include href="'+xi_title+'" xpointer="'+xi_name+'" xmlns:xi="http://www.w3.org/2001/XInclude" ><xi:fallback>'+$(n).html()+'</xi:fallback></xi:include>';					
					}	
					else{
						elm = '<xi:include href="'+xi_title+'" xmlns:xi="http://www.w3.org/2001/XInclude" ><xi:fallback>'+$(n).html()+'</xi:fallback></xi:include>';
					}
					$(n).replaceWith(elm);
					
					/*
					//IE ignores innerHTML when created with tinymce.dom, therefore use native JS createElement method to tell IE that custom tag is valid HTML
					//to make domelm.innerHTML work, declare xmlns:xi in head and wrap in span tag to be able to set innerHTML of domelm
					wrapper = document.createElement('span');
					domelm = document.createElement('xi:include');
					wrapper.appendChild(domelm);
					//alert(domelm);
					domelm.setAttribute("xmlns:xi", "http://www.w3.org/2001/XInclude");
					xinc_path = (n.title).split('#',2);
					domelm.setAttribute("href", xinc_path[0]);
					if(xinc_path[1]){
						domelm.setAttribute("xpointer", xinc_path[1]);
					}
					if(tinymce.isIE)
					{
						wrapper.appendChild(document.createTextNode(n.innerHTML));
					}
					else
					{
						domelm.appendChild(document.createTextNode(n.innerHTML));
					}
					//domelm.show = n.className.split(/\s+/)[0];
					document.body.appendChild(wrapper);
					ed.dom.replace(wrapper, n);
					*/
    			});

    		});
			
			//parse xi:include back to span tags so editor can handle them
			ed.onSetContent.add(function(ed, o) {
				//we don't support IE7 :)
				//local & IE7: 'include' statt 'xi\\:include'
				/*if ($.browser.msie && $.browser.version.substr(0,1) == 7)
				{
					$(ed.getDoc()).find('include').each(function(index, element) {
						var n = element;
						var xp = '';
						if(ed.dom.getAttrib(n, 'xpointer')){ xp = '#' + ed.dom.getAttrib(n, 'xpointer')}
						//var elm = ed.dom.create('span', {id: $(this).text(), title: ed.dom.getAttrib(n, 'href') + xp, 'class': "xml_include"}, $(this).text());
						//var elm = '<span title="'+ $(n).attr('href') + xp + '" class="xml_include"></span>';
						//$(n).unwrap();
						//$(n).wrap(elm);
						var elm = '<span title="'+ $(n).attr('href') + xp + '" class="xml_include">'+$(n).text()+'</span>';
						$(n).replaceWith(elm);
					//	ed.dom.replace(elm, n);
					});
				}
				else
				{*/
					$(ed.getDoc()).find('xi\\:include').each(function(index, element) {
						var n = element;
						var xp = '';
						if(ed.dom.getAttrib(n, 'xpointer')){ xp = '#' + ed.dom.getAttrib(n, 'xpointer')}
						//var elm = ed.dom.create('span', {id: $(this).text(), title: ed.dom.getAttrib(n, 'href') + xp, 'class': /*ed.dom.getAttrib(n, 'show') + */"xml_include"}, $(this).text());
						//var elm = '<span title="'+ $(n).attr('href') + xp + '" class="xml_include"></span>';
						//$(n).unwrap();
						//$(n).wrap(elm);
						//elm = '<xi:include href="'+$(n).attr('title')+'" xmlns:xi="http://www.w3.org/2001/XInclude" >'+$(n).html()+'</xi:include>';
						var elm = '<span title="'+ $(n).attr('href') + xp + '" class="xml_include">'+$(n).text()+'</span>';
						$(n).replaceWith(elm);
					//	ed.dom.replace(elm, n);
					});
				//}
			});
		},

		getInfo : function() {
			return {
				longname : 'XInclude & XPointer Plugin, adapted from advlink-Plugin',
				author : 'Heinrich Reimer, adapted from moxiecodes advlink',
				authorurl : 'http://www.uibk.ac.at',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/advlink',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('xmlinclude', tinymce.plugins.xmlinclude);
})();
