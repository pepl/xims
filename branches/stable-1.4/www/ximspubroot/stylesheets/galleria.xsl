<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="rdf dc dcq #default"
                >
<!--$Id: default.xsl 1176 2005-07-01 16:07:45Z pepl $-->

<xsl:import href="include/common.xsl"/>
<xsl:import href="include/default_header.xsl"/>

<xsl:output method="html" media-type="text/html" omit-xml-declaration="yes" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:param name="scaletowidth" select="'400'"/>

<xsl:template match="/page">
    <html>
    <head>
        <xsl:call-template name="meta"/>
        <meta http-equiv="imagetoolbar" content="no"/>
        <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
        <link rel="stylesheet" href="/ximsroot/galleria/galleria.css" type="text/css" />
        <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css" />
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css" />
        <script type="text/javascript" src="/ximsroot/jquery/jquery.js"></script>
        <script type="text/javascript" src="/ximsroot/galleria/jquery.galleria.js"></script>
        <script type="text/javascript">
            jQuery(function($) {
                $('.gallery').addClass('gallery_demo'); // adds new class name to maintain degradability
    
                $('ul.gallery').galleria({
                    history   : true, // activates the history object for bookmarking, back-button etc.
                    clickNext : true, // helper for making the image clickable
                    insert    : '#main_image', // the containing selector for our main image
                    onImage   : function(image,caption,thumb) { // let's add some image effects for demonstration purposes
                        // fade in the image and caption
                        if(! ($.browser.mozilla &amp;&amp; navigator.appVersion.indexOf("Win")!=-1) ) { // FF/Win fades large images terribly slow
                            image.css('display','none').fadeIn(1000);
                        }
                        caption.css('display','none').fadeIn(1000);
            
                        // fetch the thumbnail container
                        var _li = thumb.parents('li');
            
                        // fade out inactive thumbnail
                        _li.siblings().children('img.selected').fadeTo(500,0.3);
            
                        // fade in active thumbnail
                        thumb.fadeTo('fast',1).addClass('selected');
            
                        // add a title for the clickable image
                        image.attr('title','Next image »');
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
                    }
                });
            });
        </script>

    </head>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <xsl:call-template name="header"/>
        <div id="leftcontent">
            <xsl:call-template name="stdlinks"/>
            <xsl:call-template name="departmentlinks"/>
            <xsl:call-template name="documentlinks"/>
        </div>
        <div id="centercontent">
            <xsl:comment>/UdmComment</xsl:comment>
            <xsl:apply-templates select="body"/>
            <div id="footer">
                <span class="left">
                    <xsl:call-template name="copyfooter"/>
                </span>
                <span class="right">
                    <xsl:call-template name="powerdbyfooter"/>
                </span>
            </div>
        </div>
      </body>
    </html>
</xsl:template>

<xsl:template match="ul">
    <div id="main_image"></div>
    <ul class="gallery"><xsl:apply-templates select="li[@class='list_PJPEG' or @class='list_GIF' or @class='list_JPEG' or @class='list_PNG' or @class='list_TIFF']"/></ul>
    <p class="nav"><a href="#" onclick="$.galleria.prev(); return false;">« previous</a> | <a href="#" onclick="$.galleria.next(); return false;">next »</a></p>
</xsl:template>

<xsl:template match="li">
    <li>
        <xsl:if test="position() = 1">
            <xsl:attribute name="class">active</xsl:attribute>
        </xsl:if>
        <img src="{a/@href}/Resize?geometry={$scaletowidth}" title="{a}" alt="{a}"/>
    </li>
</xsl:template>

</xsl:stylesheet>
