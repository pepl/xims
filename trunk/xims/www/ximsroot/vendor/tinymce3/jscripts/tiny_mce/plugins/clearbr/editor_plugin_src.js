/**
 * $Id: editor_plugin_src.js 
 *
 * @author Susanne Tober
 * @copyright Copyright � 2008, University of Innsbruck
 */

(function() {
    // Load plugin specific language pack
    tinymce.PluginManager.requireLangPack('clearbr');

    tinymce.create('tinymce.plugins.ClearbrPlugin', {
        /**
         * Initializes the plugin, this will be executed after the plugin has been created.
         * This call is done before the editor instance has finished it's initialization so use the onInit event
         * of the editor instance to intercept that event.
         *
         * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
         * @param {string} url Absolute URL to where the plugin is located.
         */
        init : function(ed, url) {
	    ed.addCommand('mcePasteClearbr',
		function() {
		    var html = '<br class="clear" />';
		    tinyMCE.get('body').execCommand('mceInsertContent', false, html);
		}
	    );
                // Register buttons
                ed.addButton( 'clearbr',
                    {
                        title : 'clearbr.desc',
                        cmd : 'mcePasteClearbr'
                    }
                );
                // Add node change handler
                ed.onNodeChange.add(
                    function(ed, cm, n) {
                        cm.setActive('clearbr', n.nodeName == 'IMG');
                    }
                );

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
                longname : 'Clearbr TinyMCE plugin',
                author : 'Susanne.Tober@uibk.ac.at',
                authorurl : 'http://www.uibk.ac.at/',
                infourl : 'http://www.uibk.ac.at/zid/systeme/xims/tinymce_clearbr.html',
                version : "0.03"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('clearbr', tinymce.plugins.ClearbrPlugin);
})();
