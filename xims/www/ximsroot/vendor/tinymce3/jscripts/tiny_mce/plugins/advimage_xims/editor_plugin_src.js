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
    tinymce.create('tinymce.plugins.AdvancedImagePlugin', {
    init : function(ed, url) {
      // Register commands
      ed.addCommand('mceAdvImage', function() {
        // Internal image object like a flash placeholder
        if (ed.dom.getAttrib(ed.selection.getNode(), 'class').indexOf('mceItem') != -1)
          return;

        ed.windowManager.open({
          file : url + '/image.htm',
          width : 600 + parseInt(ed.getLang('advimage.delta_width', 0)),
          height : 500 + parseInt(ed.getLang('advimage.delta_height', 0)),
          title : "XIMS File Browser",
          inline : 1
        }, {
          plugin_url : url
        });
        console.log("window manager opened");
      });

      // Register buttons
      ed.addButton('image', {
        title : 'advimage.image_desc',
        cmd : 'mceAdvImage'
      });
    },

    getInfo : function() {
      return {
        longname : 'Advanced image',
        author : 'Moxiecode Systems AB',
        authorurl : 'http://tinymce.moxiecode.com',
        infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/advimage',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
  tinymce.PluginManager.add('advimage_uibk', tinymce.plugins.AdvancedImagePlugin);
})();
