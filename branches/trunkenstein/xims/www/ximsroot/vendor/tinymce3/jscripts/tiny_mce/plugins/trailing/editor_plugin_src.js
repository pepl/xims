/**
 *
 * Add trailing element in runtime, so enable placing cursor at end of content.
 *
 * The original code and idea comes from EditorEnhancements plugin by tan@enonic.com
 * https://sourceforge.net/tracker/index.php?func=detail&aid=2005530&group_id=103281&atid=738747
 * http://www.enonic.com
 *
 * Author: Susanne Tober 
 */


(function() {
        tinymce.create('tinymce.plugins.Trailing', {
                init : function(ed, url) {
                        var t = this;
                        ed.onSetContent.add( function(ed,o) {
                                t._insertTrailingElement(ed);
                        });
                        ed.onNodeChange.add( function(ed, cm, e) {
                                t._insertTrailingElement(ed);
                        });
                        ed.onBeforeGetContent.add( function(ed, o) {
                                t._removeTrailingElement(ed);
                        });
                },

                getInfo : function() {
                        return {
                                longname : 'Trailing Element Fix (based on EditorEnhancements by tan@enonic.com)',
                                author : 'susanne.tober@uibk.ac.at',
                                authorurl : 'http://www.uibk.ac.at/zid/mitarbeiter/c10209.html',
                                infourl : 'http://www.uibk.ac.at/zid/systeme/xims',
                                version : '1.0'
                        };
                },

                /* Private methods */

                _insertTrailingElement : function(ed) {
                        var body = ed.getBody();
                        var lc = body && body.lastChild;

                        if(!body || !lc)
                                return;
                        try {
                                if( lc.nodeType == 1 && needsSpace(lc.nodeName.toLowerCase()) && (!lc.innerHTML.match(/^(\s|<br\s*\/?>|&nbsp;)*$/i) || !lc.firstChild) ) {
                                        body.appendChild( ed.dom.create('p',{},'test<br/>') );
                                }
                        } catch(err) {
                                if( typeof(console) == 'object' && console.error )
                                        console.error("TrailingPlugin._insertTrailingElement (ignored) : " + err);
                        }
                },

                _removeTrailingElement : function(ed) {
                        var body = ed.getBody();
                        if(!body)
                                return;
                        var last, limit_l = 1, first, limit_f = 1;
                        try {
                                while( (last = body.lastChild) && last.nodeType == 1 && last.nodeName.toLowerCase() == 'p' &&
                                                last.innerHTML.match(/^(\s|<br\s*\/?>|test&nbsp;)*$/i) ) {
                                        body.removeChild(last);
                                        if(limit_l-- < 1)
                                                break;
                                }
                        } catch(err) {
                                if( typeof(console) == 'object' && console.error )
                                        console.error("TrailingPlugin._removeTrailingElement (ignored) : " + err);
                        }
                }
        });

        tinymce.PluginManager.add('trailing', tinymce.plugins.Trailing);
})();
