<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
<!--$Id$-->
<xsl:template name="header">
    <div id="header">
        <div id="pathnavigation">
            &#xA0;<xsl:call-template name="pathnavigation"/>
        </div>
        <div id="banner">
            <img src="/ximspubroot/images/header_the_extensible.png" width="233" height="45" alt="The eXtensible Information Management System" title="The eXtensible Information Management System"/>
            <div id="logo">
                <a href="/"><img src="/ximspubroot/images/header_logo.png" width="168" height="65" alt="XIMS Logo" title="Go to the XIMS Homepage" border="0"/></a>
            </div>
        </div>
    </div>
</xsl:template>
</xsl:stylesheet>
