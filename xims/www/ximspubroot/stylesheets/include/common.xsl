<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--$Id$-->
<xsl:param name="request.uri.query"/>
<xsl:param name="request.uri"/>


<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6|i|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|
        dl|dt|dd|li|ol|ul|
        a|
        img|map|area|
        caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|
        button|fieldset|form|label|legend|input|option|optgroup|select|textarea|
        applet|object|param">
  <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>


<xsl:template name="meta">
      <link rel="schema.DC" href="http://purl.org/DC/elements/1.0/"/>
      <meta name="DC.Title" content="{rdf:RDF/rdf:Description/dc:title}"/>
      <meta name="DC.Creator" content="{rdf:RDF/rdf:Description/dc:creator}"/>
      <meta name="DC.Subject" content="{rdf:RDF/rdf:Description/dc:subject}"/>
      <meta name="DC.Description" content="{rdf:RDF/rdf:Description/dc:description}"/>
      <meta name="DC.Publisher" content="{rdf:RDF/rdf:Description/dc:publisher}"/>
      <meta name="DC.Contributor" content="{rdf:RDF/rdf:Description/dc:contributor}"/>
      <meta name="DC.Date.Created" scheme="{rdf:RDF/rdf:Description/dc:date/dcq:created/rdf:Description/dcq:dateScheme}" content="{rdf:RDF/rdf:Description/dc:date/dcq:created/rdf:Description/rdf:value}"/>
      <meta name="DC.Date.Modified" scheme="{rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/dcq:dateScheme}" content="{rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/rdf:value}"/>
      <meta name="DC.Format" content="{rdf:RDF/rdf:Description/dc:format}"/>
      <meta name="DC.Language" content="{rdf:RDF/rdf:Description/dc:language}"/>
      <!-- for compatibility -->
      <meta name="keywords" content="{rdf:RDF/rdf:Description/dc:subject}"/>
</xsl:template>

<xsl:template name="pathinfo">
    <xsl:param name="string" select="$request.uri" />
    <xsl:param name="pattern" select="'/'" />

    <xsl:choose>
        <xsl:when test="contains($string, $pattern)">
            <xsl:if test="not(starts-with($string, $pattern))">
                <xsl:call-template name="pathinfo">
                   <xsl:with-param name="string" select="substring-before($string, $pattern)" />
                   <xsl:with-param name="pattern" select="$pattern" />
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="pathinfo">
                <xsl:with-param name="string" select="substring-after($string, $pattern)" />
                <xsl:with-param name="pattern" select="$pattern" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$string = 'index.html' or $string = '_ottereendex.html'">
                     /
                </xsl:when>
                <xsl:when test="contains($request.uri, concat($string,'/'))">
                     / <a class="nodeco"><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''"><xsl:value-of select="concat(substring-before($request.uri, concat($string,'/')),$string,'/')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(substring-before($request.uri, concat($string,'/')),$string,'/','?',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="$string" /></a>
                </xsl:when>
                <xsl:otherwise>
                     / <a class="nodeco"><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''"><xsl:value-of select="$request.uri"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($request.uri, '?',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="$string" /></a>
                </xsl:otherwise>
            </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template name="stdlinks">
    <p class="stdlinks">
        <a href="/">Index</a><br />
        <a href="/xims-info/about.html">About the Project</a><br />
        <a href="/xims-doku/">Documentation</a><br />
        <a href="/xims-screenshots/">Screenshots</a><br />
        Download<br />
        <a href="https://sourceforge.net/projects/xims/">XIMS at Sourceforge</a><br />
        <a href="/goxims/defaultbookmark">Login</a><br />
    </p>
</xsl:template>

<xsl:template name="deptlinks">
  <xsl:param name="mode" select="default"/>
     <xsl:if test="ou/portlet[title = 'departmentlinks_portlet']/portlet-item">
    <xsl:choose>
        <xsl:when test="$mode='print'">
            <xsl:apply-templates select="ou/portlet[title = 'departmentlinks_portlet']/portlet-item" mode="print">
                 <xsl:sort select="position" data-type="number" order="ascending"/>
                 <xsl:with-param name="baselocation" select="ou/portlet[title = 'departmentlinks_portlet']/baselocation" />
                 </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
            <div class="deptlinks">
                 <xsl:apply-templates select="ou/portlet[title = 'departmentlinks_portlet']/portlet-item">
                 <xsl:sort select="position" data-type="number" order="ascending"/>
                  <xsl:with-param name="baselocation" select="ou/portlet[title = 'departmentlinks_portlet']/baselocation" />
                  </xsl:apply-templates>
                </div>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="portlet-item" mode="default">
    <xsl:param name="baselocation" />
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
      <p class="deptlink">
        <a>
            <xsl:attribute name="href"><xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name != 'URLLink'"><xsl:value-of select="$baselocation"/>/</xsl:if><xsl:value-of select="location"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
    </p>
</xsl:template>

<xsl:template match="portlet-item" mode="print">
    <xsl:param name="baselocation" />
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
        <a>
            <xsl:attribute name="href"><xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name != 'URLLink'"><xsl:value-of select="$baselocation"/>/</xsl:if><xsl:value-of select="location"/><xsl:if test="$request.uri.query != ''">?<xsl:value-of select="$request.uri.query"/></xsl:if></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
        <xsl:text>&#160;&#160;&#160;</xsl:text>
</xsl:template>

<xsl:template match="link">
    <p class="documentlink">
        <a class="documentlink" href="{@href}"><xsl:value-of select="@title"/></a>
    </p>
</xsl:template>

<xsl:template name="copyfooter">
    <p style="color: #a9a9a9; font-size: 8pt; margin-left:3px;">
        © 2002-2003 The XIMS Project,<br/> University of Innsbruck
    </p>
</xsl:template>

<xsl:template name="powerdbyfooter">
    <p style="color: #a9a9a9; font-size: 8pt; margin-right:3px;">
        Powered by <a href="http://axkit.org/"><!--<img src="http://www.hampton.ws/skins/corporate/images/pb_axkit.gif" width="87" height="30" alt="Powered by AxKit" title="Powered by AxKit" border="0"/>-->AxKit</a><xsl:text>&#160;&amp;&#160;</xsl:text><a href="http://sourceforge.net"><img src="http://sourceforge.net/sflogo.php?group_id=42250" width="88" height="31" border="0" alt="SourceForge Logo"/></a>
    </p>
</xsl:template>

</xsl:stylesheet>
