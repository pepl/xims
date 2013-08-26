/**
 * $Id: editor_plugin_src.js 201 2007-02-12 15:56:56Z spocke $
 *
 * @author Severin Gehwolf
 * @copyright Copyright � 2008, University of Innsbruck
 */

(function() {
    // Load plugin specific language pack
    tinymce.PluginManager.requireLangPack('ximsextras');

    tinymce.create('tinymce.plugins.XimsextrasPlugin', {
        /**
         * Initializes the plugin, this will be executed after the plugin has been created.
         * This call is done before the editor instance has finished it's initialization so use the onInit event
         * of the editor instance to intercept that event.
         *
         * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
         * @param {string} url Absolute URL to where the plugin is located.
         */
        init : function(ed, url) {

		ed.addCommand('mcePasteNewIcon',
		function() {
		    var html = '<span title="new" class="sprite icon_new" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
		);
		ed.addCommand('mcePasteArrowBlackIcon',
		function() {
		    var html = '<span title="black arrow" class="sprite icon_arrowblack" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
		);
		ed.addCommand('mcePasteArrowOrangeIcon',
		function() {
		    var html = '<span title="orange arrow" class="sprite icon_arroworange" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteImageIcon',
		function() {
		    var html = '<span title="Image" class="sprite icon_image" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteDocumentIcon',
		function() {
		    var html = '<span title="Document" class="sprite icon_document" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteMsWordIcon',
		function() {
		    var html = '<span title="Word" class="sprite icon_word" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);

		}
	    );
		ed.addCommand('mcePasteMsExcelIcon',
		function() {
		    var html = '<span title="Excel" class="sprite icon_excel" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteMsPPTIcon',
		function() {
		    var html = '<span title="Powerpoint" class="sprite icon_ppt" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePastePDFIcon',
		function() {
		    var html = '<span title="PDF" class="sprite icon_pdf" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteEmailIcon',
		function() {
		    var html = '<span title="Email" class="sprite icon_email" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteIntranetIcon',
		function() {
		    var html = '<span title="Intranet" class="sprite icon_intranet" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
		ed.addCommand('mcePasteExternalLinkIcon',
		function() {
		    var html = '<span title="External Link" class="sprite icon_externallink" ></span>';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
            var ximsextrasIconNames = tinyMCE.get('body').getParam('ximsextras_iconNames').split(',');
            // add buttons loop for all comma separated icons given in config
            for (var i=0 ; i < ximsextrasIconNames.length; i++) {
                var skey_value = ximsextrasIconNames[i].split('=');
                // Register buttons
                ed.addButton( 'ximsextras_'+skey_value[0]+'',
                    {
                        title : 'ximsextras'+skey_value[0]+'.desc',
                        cmd : 'mcePaste'+skey_value[0]+'Icon'//,
                    }
                );
                // Add node change handler
                ed.onNodeChange.add(
                    function(ed, cm, n) {
						cm.setActive('ximsextras_'+skey_value[0], n.nodeName == 'IMG');

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
                infourl : 'http://www.uibk.ac.at/zid/systeme/xims/tinymce_ximsextras.html',
                version : "0.02"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('ximsextras', tinymce.plugins.XimsextrasPlugin);
})();
