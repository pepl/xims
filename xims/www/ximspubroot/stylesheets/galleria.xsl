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

<xsl:output method="xml" media-type="text/html" omit-xml-declaration="yes" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

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
            jQuery(function($) { $('ul.gallery').galleria(); });
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
    <li><img src="{a/@href}" title="{a}" alt="{a}"/></li>
</xsl:template>

</xsl:stylesheet>
