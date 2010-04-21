/**
 * @author c10209
 */
//jQuery(function($) { $('ul.gallery').galleria(); }); 
	
	/*
	jQuery(function($) {
		
		$('.gallery_demo_unstyled').addClass('gallery_demo'); // adds new class name to maintain degradability
		$('.nav').css('display','none'); // hides the nav initially
		
		$('ul.gallery_demo').galleria({
			history   : false, // deactivates the history object for bookmarking, back-button etc.
			clickNext : false, // helper for making the image clickable. Let's not have that in this example.
			insert    : '#main_image', // the containing selector for our main image. 
								   // If not found or undefined (like here), galleria will create a container 
								   // before the ul with the class .galleria_container (see CSS)
			onImage   : function() { $('.nav').css('display','block'); } // shows the nav when the image is showing
		});
	});*/
	
	function showNext(){
	}
	
	//jQuery(function($) {
	$(document).ready(function(){
	
		/*
$('.seek-prev').button({
			icons: {primary: 'ui-icon-seek-prev'},
      text: false
		});
		$('.seek-next').button({
			icons: {primary: 'ui-icon-seek-next'},
      text: false
		});
*/
		
		$('.gallery_demo_unstyled').addClass('gallery_demo'); // adds new class name to maintain degradability
		
		$('ul.gallery_demo').galleria({
			history   : true, // activates the history object for bookmarking, back-button etc.
			clickNext : true, // helper for making the image clickable
			insert    : '#main_image', // the containing selector for our main image
			/*onImage   : function(image,caption,thumb) { // let's add some image effects for demonstration purposes
				
				// fade in the image and caption
					image.css('display','none').fadeIn(1000);
				caption.css('display','none').fadeIn(1000);
				
				// fetch the thumbnail container
				var _li = thumb.parents('li');
				
				// fade out inactive thumbnail
				_li.siblings().children('img.selected').fadeTo(500,0.3);
				
				// fade in active thumbnail
				thumb.fadeTo('fast',1).addClass('selected');
				
				// add a title for the clickable image
				image.attr('title','Next image >>');
			},
			onThumb : function(thumb) { // thumbnail effects goes here
				
				// fetch the thumbnail container
				var _li = thumb.parents('li');
				
				// if thumbnail is active, fade all the way.
				var _fadeTo = _li.is('.active') ? '1' : '0.3';
				
				// fade in the thumbnail when finnished loading
				thumb.css({display:'none',opacity:_fadeTo}).fadeIn(1500);
				
				// hover effects
				thumb.hover(
					function() { thumb.fadeTo('fast',1); },
					function() { _li.not('.active').children('img').fadeTo('fast',0.3); } // don't fade out if the parent is active
				)
			}*/
		});
		
		//scrollpane parts
		var scrollPane = $('.scroll-pane');
		var scrollContent = $('.scroll-content');
		
		//build slider
		var scrollbar = $(".scroll-bar").slider({
			slide:function(e, ui){
				if( scrollContent.width() > scrollPane.width() ){ 
					scrollContent.css('margin-left', Math.round( ui.value / 100 * ( scrollPane.width() - scrollContent.width() )) + 'px'); 
				}
				else { scrollContent.css('margin-left', 0); }
			}
		});
		
		//append icon to handle
		var handleHelper = scrollbar.find('.ui-slider-handle')
		.mousedown(function(){
			scrollbar.width( handleHelper.width() );
		})
		.mouseup(function(){
			scrollbar.width( '100%' );
		})
		.append('<span class="ui-icon ui-icon-grip-dotted-vertical"></span>')
		.wrap('<div class="ui-handle-helper-parent"></div>').parent();
		
		//change overflow to hidden now that slider handles the scrolling
		scrollPane.css('overflow','hidden');
		
		//size scrollbar and handle proportionally to scroll distance
		function sizeScrollbar(){
			var remainder = scrollContent.width() - scrollPane.width();
			var proportion = remainder / scrollContent.width();
			var handleSize = scrollPane.width() - (proportion * scrollPane.width());
			scrollbar.find('.ui-slider-handle').css({
				width: handleSize,
				'margin-left': -handleSize/2
			});
			handleHelper.width('').width( scrollbar.width() - handleSize);
		}
		
		//reset slider value based on scroll content position
		function resetValue(){
			var remainder = scrollPane.width() - scrollContent.width();
			var leftVal = scrollContent.css('margin-left') == 'auto' ? 0 : parseInt(scrollContent.css('margin-left'));
			var percentage = Math.round(leftVal / remainder * 100);
			scrollbar.slider("value", percentage);
		}
		//if the slider is 100% and window gets larger, reveal content
		function reflowContent(){
				var showing = scrollContent.width() + parseInt( scrollContent.css('margin-left') );
				var gap = scrollPane.width() - showing;
				if(gap > 0){
					scrollContent.css('margin-left', parseInt( scrollContent.css('margin-left') ) + gap);
				}
		}
		
		//change handle position on window resize
		$(window)
		.resize(function(){
				resetValue();
				sizeScrollbar();
				reflowContent();
		});
		//init scrollbar size
		setTimeout(sizeScrollbar,10);//safari wants a timeout
	});