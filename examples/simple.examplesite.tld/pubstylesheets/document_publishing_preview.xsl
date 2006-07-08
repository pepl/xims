<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
    <!-- libxslt does not like .tld addresses, so for this example we will use a filesystem URI -->
    <!-- <xsl:import href="http://simple.examplesite.tld/stylesheets/default.xsl"/>-->
    <xsl:import href="/usr/local/xims/www/ximspubroot/simple.examplesite.tld/stylesheets/default.xsl"/>

    <!--
         To disable the links outside of the source document - specified by the stylesheet -,
         the corresponding templates would have to be overriden.
    -->
    <xsl:template match="a">
        <span class="pseudolink"><xsl:value-of select="text()"/></span>
    </xsl:template>
</xsl:stylesheet>

