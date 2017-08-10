(function() {
	tinymce.PluginManager.requireLangPack('codemirror');
	
	tinymce.create('tinymce.plugins.CodeMirror', {
		
		init : function(ed, url) {
			var t = this;
			t.editor = ed;
			this.CMURL = url;
                        
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
			
			var t= this;
			
			//load CSS
			tinymce.DOM.loadCSS(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/lib/codemirror.css');
			tinymce.DOM.loadCSS(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/xml/xml.css');
			tinymce.DOM.loadCSS(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/css/css.css');
			tinymce.DOM.loadCSS(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/javascript/javascript.css');
			tinymce.DOM.loadCSS(ximsconfig.ximsroot + 'vendor/codemirror-ui/css/codemirror-ui.css');

			//load scripts - wait until codemirror is available, then load other scripts
			$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/lib/codemirror.js', function() {
				
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/lib/util/search.js');
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/lib/util/searchcursor.js');
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/xml/xml.js');
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/css/css.js');
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/javascript/javascript.js');
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/lib/CodeMirror-2.3/mode/htmlmixed/htmlmixed.js');
				
				$.getScript(ximsconfig.ximsroot + 'vendor/codemirror-ui/js/codemirror-ui.js', function(){
					t._showEditArea();
				});
	
			});
			
		},
	
		_showEditArea : function()
		{		
			var t = this, ed = tinyMCE.activeEditor, contentTbl, contentToolBar, bottomToolBar, mw, mh, th, tw, currentSel, border;
				baseurl = ximsconfig.ximsroot + 'vendor/codemirror_ui/lib/CodeMirror/';
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
					path : ximsconfig.ximsroot + "vendor/codemirror-ui/js/",
					searchMode : 'popup'
				},
				{
				//	path: ximsroot + "editors/codemirror-ui/lib/CodeMirror/js/",					
					mode: "text/html",
					lineNumbers: true,
					lineWrapping: true,
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
					"\u00C4nderungen \u00FCbernehmen und schlie\u00DFen", 
					"close", 
					ximsconfig.ximsroot + "vendor/codemirror-ui/images/silk/cancel.png", 
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
		}		

	});

	// Register plugin
	tinymce.PluginManager.add('codemirror', tinymce.plugins.CodeMirror);
})();

