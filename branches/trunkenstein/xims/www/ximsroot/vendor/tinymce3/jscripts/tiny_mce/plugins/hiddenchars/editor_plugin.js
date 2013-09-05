(function(){
    tinymce.PluginManager.requireLangPack('hiddenchars');
    function toggleContents(node, toggle_mode){
        for (var i = 0; i < node.childNodes.length; i++) {
            el = node.childNodes[i];
            if (el.nodeType == 3) {
                if (!toggle_mode) {
                    el.nodeValue = el.nodeValue.replace(/\ /g, '\u00b7\u200b')
                }

                else {
                    el.nodeValue = el.nodeValue.replace(/\u00b7\u200b/g, ' ')
                }
            }
            else 
                if (el.nodeName.toLowerCase() == 'br') {
                    var bogus = el.hasAttribute ? el.hasAttribute('_mce_bogus') : el.getAttribute('_mce_bogus');
                    var carriageReturn = null;
                    if (!toggle_mode && !bogus) {
                        carriageReturn = document.createTextNode('\u21B5');
                        el.parentNode.insertBefore(carriageReturn, el);
                        i++
                    }
                    else {
                        sibling = el.previousSibling;
                        if (sibling && sibling.nodeType == 3) {
                            sibling.nodeValue = sibling.nodeValue.replace(/\u21B5/g, '')
                        }
                    }
                }
                else 
                    if (el.nodeName.toLowerCase() == 'p') {
                        if (!toggle_mode) {
                            var chr = '\u00b6';
                            el.appendChild(document.createTextNode(chr))
                        }
                        else {
                            if (el.lastChild && el.lastChild.nodeType == 3) {
                                el.lastChild.nodeValue = el.lastChild.nodeValue.replace(/\u00b6/g, '')
                            }
                        }
                    }
            if (el.childNodes.length > 0) {
                toggleContents(el, toggle_mode)
            }
        }
        return 1
    }

function toggleback(ed){
                if (ed.hiddenchars_toggled) {
                    var root = ed.getBody();
                    toggleContents(root, true);
                    ed.hiddenchars_toggled = false;
                }
            }

    tinymce.create('tinymce.plugins.HiddenChars', {
        init: function(ed, url){
            ed.addCommand('mce_toggle_hidden_chars', function(){
                if (ed.hiddenchars_toggled) {
                    var root = ed.getBody();
                    toggleContents(root, ed.hiddenchars_toggled)
                }
                else {
                    var root = ed.getBody();
                    toggleContents(root, ed.hiddenchars_toggled)
                }
                ed.hiddenchars_toggled = !ed.hiddenchars_toggled
            });
            ed.addButton('hiddenchars', {
                title: 'hiddenchars.desc',
                cmd: 'mce_toggle_hidden_chars'
            });
            ed.onInit.add(function(ed){
                ed.hiddenchars_toggled = false;
            });
/*
	    function toggleback(ed){
                if (ed.hiddenchars_toggled) {
                    var root = ed.getBody();
                    toggleContents(root, true);
                    ed.hiddenchars_toggled = false;
                }
            };
*/
            ed.onNodeChange.add(function(ed, cm){
                if (ed.hiddenchars_toggled == true) {
                    cm.setActive('hiddenchars', 1);
                }
                else {
                    cm.setActive('hiddenchars', 0);
                }
            });

	    ed.onBeforeGetContent.add(function(ed, o) {
		toggleback(ed);
	    });
        },
        getInfo: function(){
            return {
                longname: 'HiddenChars plugin',
                author: 'Heinrich Reimer, adapted from stefanw (TinyMCE Forum)',
                authorurl: 'http://uibk.ac.at',
                infourl: 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/example',
                version: "1.0"
            }
        }
    });
    tinymce.PluginManager.add('hiddenchars', tinymce.plugins.HiddenChars)
})();
