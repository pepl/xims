
(function($){
    var $$;
    $$ = $.fn.galleria = function($options){
        if (!$$.hasCSS()) {
            return false;
        }
        $.historyInit($$.onPageLoad);
        var $defaults = {
            insert: '.galleria_container',
            history: true,
            clickNext: true,
            onImage: function(image, caption, thumb){
            },
            onThumb: function(thumb){
            }
        };
        var $opts = $.extend($defaults, $options);
        for (var i in $opts) {
            if (i) {
                $.galleria[i] = $opts[i];
            }
        }
        var _insert = ($($opts.insert).is($opts.insert)) ? $($opts.insert) : jQuery(document.createElement('div')).insertBefore(this);
        var _div = $(document.createElement('div')).addClass('galleria_wrapper');
		// insert (img -- first child)
        var _span = $(document.createElement('span')).addClass('caption');
        _insert.addClass('galleria_container').append(_div).append(_span);
        return this.each(function(){
            $(this).addClass('galleria');
            $(this).children('li').each(function(i){
                var _container = $(this);
                var _o = $.meta ? $.extend({}, $opts, _container.data()) : $opts;
                _o.clickNext = $(this).is(':only-child') ? false : _o.clickNext;
                var _a = $(this).find('a').is('a') ? $(this).find('a') : false;
                var _img = $(this).children('img').css('display', 'none');
                var _src = _a ? _a.attr('href') : _img.attr('src');
                var _title = _a ? _a.attr('title') : _img.attr('title');
                var _loader = new Image();
                if (_o.history && (window.location.hash && window.location.hash.replace(/\#/, '') == _src)) {
                    _container.siblings('.active').removeClass('active');
                    _container.addClass('active');
                }
                $(_loader).load(function(){
                    $(this).attr('alt', _img.attr('alt'));
                    var _thumb = _a ? _a.find('img').addClass('thumb noscale').css('display', 'none') : _img.clone(true).addClass('thumb').css('display', 'none');
                    if (_a) {
                        _a.replaceWith(_thumb);
                    }
                    if (!_thumb.hasClass('noscale')) {
                        var w = Math.ceil(_img.width() / _img.height() * _container.height());
                        var h = Math.ceil(_img.height() / _img.width() * _container.width());
                        if (w < h) {
                            _thumb.css({
                                height: 'auto',
                                width: _container.width(),
                                marginTop: -(h - _container.height()) / 2
                            });
                        }
                        else {
                            _thumb.css({
                                width: 'auto',
                                height: _container.height(),
                                marginLeft: -(w - _container.width()) / 2
                            });
                        }
                    }
                    else {
                        window.setTimeout(function(){
                            _thumb.css({
                                marginLeft: -(_thumb.width() - _container.width()) / 2,
                                marginTop: -(_thumb.height() - _container.height()) / 2
                            });
                        }, 1);
                    }
                    _thumb.attr('rel', _src);
                    _thumb.attr('title', _title);
                    _thumb.click(function(){
                        $.galleria.activate(_src);
                    });
                    _thumb.hover(function(){
                        $(this).addClass('hover');
                    }, function(){
                        $(this).removeClass('hover');
                    });
                    _container.hover(function(){
                        _container.addClass('hover');
                    }, function(){
                        _container.removeClass('hover');
                    });
                    _container.prepend(_thumb);
                    _thumb.css('display', 'block');
                    _o.onThumb(jQuery(_thumb));
                    if (_container.hasClass('active')) {
                        $.galleria.activate(_src);
                    }
                    _img.remove();
                }).error(function(){
                    _container.html('<span class="error" style="color:red">Error loading image: ' + _src + '</span>');
                }).attr('src', _src);
            });
        });
    };
    $$.nextSelector = function(selector){
        return $(selector).is(':last-child') ? $(selector).siblings(':first-child') : $(selector).next();
    };
    $$.previousSelector = function(selector){
        return $(selector).is(':first-child') ? $(selector).siblings(':last-child') : $(selector).prev();
    };
    $$.hasCSS = function(){
        $('body').append($(document.createElement('div')).attr('id', 'css_test').css({
            width: '1px',
            height: '1px',
            display: 'none'
        }));
        var _v = ($('#css_test').width() != 1) ? false : true;
        $('#css_test').remove();
        return _v;
    };
    $$.onPageLoad = function(_src){
        var _wrapper = $('.galleria_wrapper');
        var _thumb = $('.galleria img[rel="' + _src + '"]');
        if (_src) {
            if ($.galleria.history) {
                window.location = window.location.href.replace(/\#.*/, '') + '#' + _src;
            }
            _thumb.parents('li').siblings('.active').removeClass('active');
            _thumb.parents('li').addClass('active');
            var _img = $(new Image()).attr('src', _src).addClass('replaced');
            _wrapper.empty().append(_img);
            _wrapper.siblings('.caption').text(_thumb.attr('title'));
            $.galleria.onImage(_img, _wrapper.siblings('.caption'), _thumb);
            if ($.galleria.clickNext) {
                _img.css('cursor', 'pointer').click(function(){
                    $.galleria.next();
                });
            }
        }
        else {
            _wrapper.siblings().andSelf().empty();
            $('.galleria li.active').removeClass('active');
        }
        $.galleria.current = _src;
    };
    $.extend({
        galleria: {
            current: '',
            onImage: function(){
            },
            activate: function(_src){
                if ($.galleria.history) {
                    $.historyLoad(_src);
                }
                else {
                    $$.onPageLoad(_src);
                }
            },
            next: function(){
                var _next = $($$.nextSelector($('.galleria img[rel="' + $.galleria.current + '"]').parents('li'))).find('img').attr('rel');
                $.galleria.activate(_next);
            },
            prev: function(){
                var _prev = $($$.previousSelector($('.galleria img[rel="' + $.galleria.current + '"]').parents('li'))).find('img').attr('rel');
                $.galleria.activate(_prev);
            }
        }
    });
})(jQuery);
jQuery.extend({
    historyCurrentHash: undefined,
    historyCallback: undefined,
    historyInit: function(callback){
        jQuery.historyCallback = callback;
        var current_hash = location.hash;
        jQuery.historyCurrentHash = current_hash;
        jQuery.historyCallback(current_hash.replace(/^#/, ''));
        setInterval(jQuery.historyCheck, 100);
    },
    historyAddHistory: function(hash){
        jQuery.historyBackStack.push(hash);
        jQuery.historyForwardStack.length = 0;
        this.isFirst = true;
    },
    historyCheck: function(){
	    current_hash = location.hash;
	    if (current_hash != jQuery.historyCurrentHash) {
	        jQuery.historyCurrentHash = current_hash;
	        jQuery.historyCallback(current_hash.replace(/^#/, ''));
	    }
    },
    historyLoad: function(hash){
        var newhash;
        newhash = '#' + hash;
        location.hash = newhash;
        jQuery.historyCurrentHash = newhash;
        jQuery.historyCallback(hash);
    }
});
