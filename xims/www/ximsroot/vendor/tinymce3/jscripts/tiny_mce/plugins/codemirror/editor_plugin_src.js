(function() {
	tinymce.PluginManager.requireLangPack('codemirror');
	
	tinymce.create('tinymce.plugins.CodeMirror', {
		
		init : function(ed, url) {
			var t = this;
			t.editor = ed;
			this.CMURL = url;

			//load CSS
			tinymce.DOM.loadCSS(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/lib/codemirror.css');
			tinymce.DOM.loadCSS(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/xml/xml.css');
			tinymce.DOM.loadCSS(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/css/css.css');
			tinymce.DOM.loadCSS(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/javascript/javascript.css');
		 	tinymce.DOM.loadCSS(ximsroot + 'editors/codemirror-ui/css/codemirror-ui.css');	
			
			//load scripts - wait until codemirror is available, then load other scripts
			$.getScript(ximsroot + 'editors/codemirror-ui-0.0.14/lib/CodeMirror-2.0/lib/codemirror.js', function() {
				$.getScript(ximsroot + 'editors/codemirror-ui/js/codemirror-ui.js');
				$.getScript(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/xml/xml.js');
				$.getScript(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/css/css.js');
				$.getScript(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/javascript/javascript.js');
				$.getScript(ximsroot + 'editors/codemirror-ui/lib/CodeMirror-2.0/mode/htmlmixed/htmlmixed.js');
			});
			// Register commands
			ed.addCommand('mceCodeMirror', t._editArea, t);
			
			// Register buttons
			ed.addButton('codemirror', {
				title : 'codemirror.desc', 
				cmd : 'mceCodeMirror'
			});

			ed.onNodeChange.add(t._nodeChange, t);
		},

		getInfo : function() {
			return {
				longname : 'CodeMirror integration for TinyMCE',
				author : 'Alaa-eddine KADDOURI',
				authorurl : 'http://www.eurekaa.org',
				infourl : 'http://code.google.com/p/eurekaa/',
				version : '0.2 Beta'
			};
		},
		
		_nodeChange : function(ed, cm, n) {
			var ed = tinyMCE.activeEditor;
			//not used for the moment
		},

		_editArea : function() {
			this._showEditArea();
		},
	
		_showEditArea : function()
		{					
			var t = this, ed = tinyMCE.activeEditor, contentTbl, contentToolBar, bottomToolBar, mw, mh, th, tw, currentSel, border;
				baseurl = ximsroot + 'editors/codemirror_ui/lib/CodeMirror/';
				contentTbl = $('#body_tbl'); //ed.getContainer().getElementsByTagName("table")[0];
				contentToolBar = $('#body_ifr');				
				areaId = ed.getElement().id;				
				mw = contentTbl.width() + "px";
				mh = contentTbl.height() + "px";
				currentSel = ed.selection.getBookmark();
				ed.hide();	
				//ie does not save from cm: disable save/cancel-buttons		
				$('.cancel-save button').button('disable');			
				var textarea = document.getElementById(areaId);
				t.CMEditor = new CodeMirrorUI(textarea,
				{
					path : ximsroot + "editors/codemirror-ui/js/",
					searchMode : 'popup'
				},
				{
					path: ximsroot + "editors/codemirror-ui/lib/CodeMirror/js/",					
					mode: "text/html",
					lineNumbers: true,
					matchBrackets: true
				});
				fc_close = function() {
					ed.show();
					ed.setContent(t.CMEditor.mirror.getValue());
					$('.codemirror-ui-button-frame').parent().remove();
					t.CMEditor.mirror.toTextArea();
					t.CMEditor = null;
					$('#body').hide();
					ed.focus();
					$('.cancel-save button').button('enable');	
				};
				
				t.CMEditor.addButton(
					"Schlie\u00DFen", 
					"close", 
					ximsroot + "editors/codemirror-ui/images/silk/cancel.png", 
					fc_close, 
					t.CMEditor.buttonFrame
				);
				
				fc_undo = function() {
					t.CMEditor.undo();
				};
				fc_redo = function() {
					t.CMEditor.redo();
				};
				
				function getStyle(oElm, strCssRule){
    				var strValue = "";
    				if(document.defaultView && document.defaultView.getComputedStyle){
        				strValue = document.defaultView.getComputedStyle(oElm, "").getPropertyValue(strCssRule);
    				}
    				else if(oElm.currentStyle){
        				strCssRule = strCssRule.replace(/\-(\w)/g, function (strMatch, p1){
            			return p1.toUpperCase();
        			});
        			strValue = oElm.currentStyle[strCssRule];
    				}
    				return parseInt(strValue);
				};
				/*
				t.CMEditor.frame.id = 'frame_'+areaId;
				t.CMEditor.frame.style.width = mw;
				t.CMEditor.frame.style.height = mh;
				t.CMEditor.frame.className = 'CodeMirrorFrame cmFrameLayout';
				
				t.CMEditor.toolBarDiv = document.createElement("div");
				t.CMEditor.toolBarDiv.id = 'div_'+areaId;
				t.CMEditor.toolBarDiv.style.width = tw;
				t.CMEditor.toolBarDiv.style.height =  th;
				t.CMEditor.toolBarDiv.className = 'CodeMirrorToolBar mceToolbar';				
				t.CMEditor.frame.parentNode.insertBefore(t.CMEditor.toolBarDiv, t.CMEditor.frame);
				
				//Style corrections due to applied CSS
				t.CMEditor.toolBarDiv.style.width = (parseInt(tw) - (getStyle(t.CMEditor.toolBarDiv, "padding-left"))) + "px";
				t.CMEditor.toolBarDiv.style.height = (parseInt(th) - (getStyle(t.CMEditor.toolBarDiv, "padding-top"))) + "px";
				
				border = (getStyle(t.CMEditor.toolBarDiv, "border-top-width")) + 
						 (getStyle(t.CMEditor.toolBarDiv, "border-bottom-width")) + 
						 (getStyle(t.CMEditor.frame, "border-bottom-width"));
						 
				t.CMEditor.frame.style.height = (parseInt(mh) - border) + "px";
				
				//for IE: 'class' instead of class
				cls = tinymce.DOM.add(t.CMEditor.toolBarDiv, 'input', {type:'button', 'class':'CMBtn close', id:'Btn_close'});
				cls.onclick = fc_close;
				
				un = tinymce.DOM.add(t.CMEditor.toolBarDiv, 'input', {type:'button', 'class':'CMBtn undo', id:'Btn_undo'});
				un.onclick =  fc_undo;
				
				re = tinymce.DOM.add(t.CMEditor.toolBarDiv, 'input', {type:'button', 'class':'CMBtn redo', id:'Btn_redo'});
				re.onclick =  fc_redo;
				*/
		}		

	});

	// Register plugin
	tinymce.PluginManager.add('codemirror', tinymce.plugins.CodeMirror);
})();

