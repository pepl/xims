<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/">

<!--$Id$-->
<xsl:param name="request.uri.query"/>
<xsl:param name="request.uri"/>

<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6|i|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|
        dl|dt|dd|li|ol|ul|
        a|
        img|map|area|
        caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|
        button|fieldset|form|label|legend|input|option|optgroup|select|textarea|
        applet|object|param|embed|script">
    <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:for-each select="@*">
            <xsl:attribute name="{name(.)}">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>


<xsl:template name="meta">
      <xsl:param name="context_node" select="."/>
      <link rel="schema.DC" href="http://purl.org/DC/elements/1.0/"/>
      <meta name="DC.Title" content="{$context_node/rdf:RDF/rdf:Description/dc:title}"/>
      <meta name="DC.Creator" content="{$context_node/rdf:RDF/rdf:Description/dc:creator}"/>
      <meta name="DC.Subject" content="{$context_node/rdf:RDF/rdf:Description/dc:subject}"/>
      <meta name="DC.Description" content="{$context_node/rdf:RDF/rdf:Description/dc:description}"/>
      <meta name="DC.Publisher" content="{$context_node/rdf:RDF/rdf:Description/dc:publisher}"/>
      <meta name="DC.Contributor" content="{$context_node/rdf:RDF/rdf:Description/dc:contributor}"/>
      <meta name="DC.Date.Created"  scheme="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:created/rdf:Description/dcq:dateScheme}" content="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:created/rdf:Description/rdf:value}"/>
      <meta name="DC.Date.Modified" scheme="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/dcq:dateScheme}" content="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/rdf:value}"/>
      <meta name="DC.Format" content="{$context_node/rdf:RDF/rdf:Description/dc:format}"/>
      <meta name="DC.Language" content="{$context_node/rdf:RDF/rdf:Description/dc:language}"/>
      <!-- for compatibility -->
      <meta name="keywords" content="{$context_node/rdf:RDF/rdf:Description/dc:subject}"/>
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
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''"><xsl:value-of select="concat(substring-before($request.uri, concat($string,'/')),$string,'/')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(substring-before($request.uri, concat($string,'/')),$string,'/','?',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="$string" /></a>
                </xsl:when>
                <xsl:otherwise>
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''"><xsl:value-of select="$request.uri"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($request.uri, '?',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="$string" /></a>
                </xsl:otherwise>
            </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template name="departmentlinks">
    <xsl:param name="context" select="."/>
    <xsl:if test="$context/ou/portlet[title = 'departmentlinks_portlet']/portlet-item">
        <div id="departmentlinks">
            <h3>DepartmentLinks</h3>
            <ul>
                 <xsl:apply-templates select="$context/ou/portlet[title = 'departmentlinks_portlet']/portlet-item">
                    <xsl:sort select="position" data-type="number" order="ascending"/>
                 </xsl:apply-templates>
            </ul>
        </div>
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

<xsl:template match="portlet-item" mode="print">
    <li>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="location"/><xsl:if test="$request.uri.query != ''">?<xsl:value-of select="$request.uri.query"/></xsl:if></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
    </li>
</xsl:template>

<xsl:template name="documentlinks">
  <xsl:param name="mode" select="default"/>
    <xsl:if test="links/link">
        <div id="linkbox">
            <h3>DocumentLinks</h3>
            <ul>
                <xsl:apply-templates select="links"/>
            </ul>
        </div>
  </xsl:if>
  <xsl:if test="newsitem/links/link">
        <div id="linkbox">
            <h3>DocumentLinks</h3>
            <ul>
                <xsl:apply-templates select="newsitem/links"/>
            </ul>
        </div>
  </xsl:if>

</xsl:template>

<xsl:template match="link">
    <li>
        <a href="{@href}"><xsl:value-of select="@title"/></a>
    </li>
</xsl:template>

</xsl:stylesheet>
