<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0"
                exclude-result-prefixes="rdf dc dcq">

<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/">
  <xsl:apply-templates select="/document/context/*[local-name() != 'session']"/>
</xsl:template>

</xsl:stylesheet>
