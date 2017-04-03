<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0"
                exclude-result-prefixes="rdf dc dcq">


<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:output method="xml"
            encoding="UTF-8"
            media-type="text/html"
            indent="yes"
            omit-xml-declaration="yes"/>


<xsl:param name="property"/>

<xsl:template match="/">
  <span id="message_{$property}"><xsl:comment/></span>
  <xsl:apply-templates select="/document/context/object"/>
  <xsl:text>&#160;</xsl:text>
</xsl:template>

<xsl:template match="object">
 <xsl:choose>
    <xsl:when test="$property='author'">
      <xsl:apply-templates select="authorgroup/author">
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[name()=concat($property, 'set')]/*[name()=$property]">
        <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
