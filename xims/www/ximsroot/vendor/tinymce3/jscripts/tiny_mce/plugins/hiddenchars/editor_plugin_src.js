(function(){
    tinymce.PluginManager.requireLangPack('setlang');
    tinymce.create('tinymce.plugins.SetLangPlugin', {
        init: function(ed, url){
            ed.addCommand('mceSetLang', function(){
                ed.windowManager.open({
                    file: url + '/set_lang.html',
                    width: 380 + parseInt(ed.getLang('setlang.setlang_delta_width', 0)),
                    height: 380 + parseInt(ed.getLang('setlang.setlang_delta_width', 0)),
                    inline: 1
                }, {
                    plugin_url: url
                })
            });
            ed.addButton('setlang', {
                title: 'setlang.desc',
                cmd: 'mceSetLang'
            });
            ed.onNodeChange.add(function(ed, cm, n, co){
                n = ed.dom.getParent(n, 'SPAN');
                cm.setActive('setlang', 0);
                if (n && n.className == 'lang') {
                    do {
                        cm.setActive('setlang', 1)
                    }
                    while (n = n.parentNode)
                }
            });
            ed.onInit.add(function(){
                ed.dom.create('span')
            })
        },
        getInfo: function(){
            return {
                longname: 'SetLanguage Plugin',
                author: 'Heinrich Reimer, adapted from Sylvia Egger "ChangeLang Plugin"',
                authorurl: '',
                infourl: 'http://uibk.ac.at',
                version: tinymce.majorVersion + "." + tinymce.minorVersion
            }
        }
    });
    tinymce.PluginManager.add('setlang', tinymce.plugins.SetLangPlugin)
})();
