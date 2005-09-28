<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml"
                >

<!-- /www is the apache document root in this case -->
<!--<xsl:import href="/www/ximspubroot/stylesheets/default.xsl"/>-->

<xsl:import href="http://xims.info/stylesheets/default.xsl"/>

<!--
     To disable the links outside of the source document specified by the
     stylesheet, the corresponding templates would have to be overriden.
-->
<xsl:template match="a">
    <span class="pseudolink"><xsl:value-of select="text()"/></span>
</xsl:template>

</xsl:stylesheet>

