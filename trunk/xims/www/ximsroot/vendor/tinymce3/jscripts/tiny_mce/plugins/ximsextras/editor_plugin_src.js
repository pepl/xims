/**
 * $Id: editor_plugin_src.js 201 2007-02-12 15:56:56Z spocke $
 *
 * @author Severin Gehwolf
 * @copyright Copyright � 2008, University of Innsbruck
 */

(function() {
    // Load plugin specific language pack
    tinymce.PluginManager.requireLangPack('uibkextras');

    tinymce.create('tinymce.plugins.UibkextrasPlugin', {
        /**
         * Initializes the plugin, this will be executed after the plugin has been created.
         * This call is done before the editor instance has finished it's initialization so use the onInit event
         * of the editor instance to intercept that event.
         *
         * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
         * @param {string} url Absolute URL to where the plugin is located.
         */
        init : function(ed, url) {
            var uibkextrasRessourceUrl = tinyMCE.get('body').getParam('uibkextras_ressourceUrl');
	    /*
		ed.addCommand('mcePasteMsWordIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_word.gif" alt="MsWord Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePasteMsExcelIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_excel.gif" alt="MsExcel Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePasteMsPPTIcon',
		function() {
			var html = '<span class="mceIcon mce_pastemsppticon"/>';
		    //var html = '<img src="'+uibkextrasRessourceUrl+'list_ppt.gif" alt="MsPPT Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePasteDocumentIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_document_generic.gif" alt="Document Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePasteEMailIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_email.gif" alt="EMail Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePastePDFIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_pdf.gif" alt="PDF Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePasteFolderIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_folder.gif" alt="Folder Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
	    ed.addCommand('mcePasteImageIcon',
		function() {
		    var html = '<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		*/
		ed.addCommand('mcePasteNewIcon',
		function() {
		    var html = '<span title="new" class="sprite icon_new" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
		);
		ed.addCommand('mcePasteArrowBlackIcon',
		function() {
		    var html = '<span title="black arrow" class="sprite icon_arrowblack" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
		);
		ed.addCommand('mcePasteArrowOrangeIcon',
		function() {
		    var html = '<span title="orange arrow" class="sprite icon_arroworange" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteImageIcon',
		function() {
		    var html = '<span title="Image" class="sprite icon_image" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteDocumentIcon',
		function() {
		    var html = '<span title="Document" class="sprite icon_document" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteMsWordIcon',
		function() {
		    var html = '<span title="Word" class="sprite icon_word" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
			//tinyMCE.activeEditor.selection.select(tinyMCE.activeEditor.dom.select(this.next()));

		}
	    );
		ed.addCommand('mcePasteMsExcelIcon',
		function() {
		    var html = '<span title="Excel" class="sprite icon_excel" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteMsPPTIcon',
		function() {
		    var html = '<span title="Powerpoint" class="sprite icon_ppt" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePastePDFIcon',
		function() {
		    var html = '<span title="PDF" class="sprite icon_pdf" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteEmailIcon',
		function() {
		    var html = '<span title="Email" class="sprite icon_email" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteIntranetIcon',
		function() {
		    var html = '<span title="Intranet" class="sprite icon_intranet" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteExternalLinkIcon',
		function() {
		    var html = '<span title="External Link" class="sprite icon_externallink" ></span>';//'<img src="'+uibkextrasRessourceUrl+'list_png.gif" alt="Image Icon" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
            var uibkextrasIconNames = tinyMCE.get('body').getParam('uibkextras_iconNames').split(',');
            // add buttons loop for all comma separated icons given in config
            for (var i=0 ; i < uibkextrasIconNames.length; i++) {
                var skey_value = uibkextrasIconNames[i].split('=');
                // Register buttons
                ed.addButton( 'uibkextras_'+skey_value[0]+'',
                    {
                        title : 'uibkextras'+skey_value[0]+'.desc',
                        cmd : 'mcePaste'+skey_value[0]+'Icon'//,
                        //image : uibkextrasRessourceUrl + skey_value[1]
                    }
                );
                // Add node change handler
                ed.onNodeChange.add(
                    function(ed, cm, n) {
                        //cm.setActive('uibkextras_'+skey_value[0], n.nodeName == 'SPAN');
						cm.setActive('uibkextras_'+skey_value[0], n.nodeName == 'IMG');

                    }
                );
            }
			
        },

        /**
         * Creates control instances based in the incomming name. This method is normally not
         * needed since the addButton method of the tinymce.Editor class is a more easy way of adding buttons
         * but you sometimes need to create more complex controls like listboxes, split buttons etc then this
         * method can be used to create those.
         *
         * @param {String} n Name of the control to create.
         * @param {tinymce.ControlManager} cm Control manager to use inorder to create new control.
         * @return {tinymce.ui.Control} New control instance or null if no control was created.
         */
        createControl : function(n, cm) {
            return null;
        },

        /**
         * Returns information about the plugin as a name/value array.
         * The current keys are longname, author, authorurl, infourl and version.
         *
         * @return {Object} Name/value array containing information about the plugin.
         */
        getInfo : function() {
            return {
                longname : 'UIBK image-buttons-extras TinyMCE plugin',
                author : 'Severin.Gehwolf@uibk.ac.at',
                authorurl : 'http://www.uibk.ac.at/',
                infourl : 'http://www.uibk.ac.at/zid/systeme/xims/tinymce_uibkextras.html',
                version : "0.02"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('uibkextras', tinymce.plugins.UibkextrasPlugin);
})();
