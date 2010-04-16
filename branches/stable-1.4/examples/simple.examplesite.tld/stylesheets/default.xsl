<?xml version="1.0"?>
<xsl:stylesheet xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date" exclude-result-prefixes="rdf dc dcq #default" version="1.0">

<xsl:output method="xml" encoding="UTF-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:param name="request.uri.query"/>
<xsl:param name="request.uri"/>

<xsl:template match="/page">
    <html>
    <head>
        <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
        <!-- We have to use an absolute URI here so that the CSS stylesheet will also be found during publishing preview and other goxims-served events -->
        <link type="text/css" rel="stylesheet" href="http://simple.examplesite.tld/stylesheets/default.css"/>
    </head>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <div id="header">
            <xsl:call-template name="banner"/>
            <div id="departmentlinks">
                <xsl:call-template name="departmentlinks"/>
            </div>
        </div>
        <div id="content">
            <xsl:comment>/UdmComment</xsl:comment>
            <xsl:apply-templates select="body"/>
        </div>
        <div id="footer">
            <span class="left">
                &#xA9; 2003-<xsl:value-of select="date:year()"/> Grey Dahut Preservation Initiative<br/> simple.examplesite.tld
            </span>
            <span class="right">
                Powered by
                <a href="http://axkit.org/">Apache AxKit</a>
                &amp;
                <a href="http://xims.info/">XIMS</a>
            </span>
        </div>

      </body>
    </html>
</xsl:template>

<xsl:template name="banner">
    <div id="banner">
        <div id="pathnavigation">
            <xsl:call-template name="pathnavigation"/>
        </div>
        <div id="logo">
            Grey Dahut Preservation Initiative
        </div>
    </div>
</xsl:template>

<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6|i|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|         dl|dt|dd|li|ol|ul|         a|         img|map|area|         caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|         button|fieldset|form|label|legend|input|option|optgroup|select|textarea|         applet|object|param|embed|script">
    <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:for-each select="@*">
             <xsl:attribute name="{name(.)}">
                  <xsl:value-of select="."/>
             </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template name="pathnavigation">
    <xsl:param name="string" select="$request.uri" />
    <xsl:param name="pattern" select="'/'" />

    <xsl:choose>
        <xsl:when test="contains($string, $pattern)">
            <xsl:if test="not(starts-with($string, $pattern))">
                <xsl:call-template name="pathnavigation">
                   <xsl:with-param name="string" select="substring-before($string, $pattern)" />
                   <xsl:with-param name="pattern" select="$pattern" />
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="pathnavigation">
                <xsl:with-param name="string" select="substring-after($string, $pattern)" />
                <xsl:with-param name="pattern" select="$pattern" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$string = '_ottereendex.html'">
                     /
                </xsl:when>
                <xsl:when test="contains($request.uri, concat($string,'/'))">
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''"><xsl:value-of select="concat(substring-before($request.uri, concat($string,'/')),$string,'/')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(substring-before($request.uri, concat($string,'/')),$string,'/','?',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains($string,'.html')">
                                    <xsl:value-of select="substring-before($string,'.html')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$string"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                </xsl:when>
                <xsl:otherwise>
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''"><xsl:value-of select="$request.uri"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($request.uri, '?',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains($string,'.html')">
                                    <xsl:value-of select="substring-before($string,'.html')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$string"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                </xsl:otherwise>
            </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template name="departmentlinks">
    <xsl:if test="ou/portlet[title = 'departmentlinks_portlet']/portlet-item">
        <ul>
             <xsl:apply-templates select="ou/portlet[title = 'departmentlinks_portlet']/portlet-item">
                <xsl:sort select="position" data-type="number" order="ascending"/>
             </xsl:apply-templates>
        </ul>
  </xsl:if>
</xsl:template>

<xsl:template match="portlet-item">
    <li>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="location"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
    </li>
</xsl:template>

</xsl:stylesheet>
