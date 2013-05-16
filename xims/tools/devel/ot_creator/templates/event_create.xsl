<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date">

<xsl:output method="xml"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document"><xsl:text disable-output-escaping="yes">
&lt;?xml version="1.0"?&gt;
&lt;!--
 # Copyright (c) 2002-</xsl:text><xsl:value-of select="date:year()"/><xsl:text
 disable-output-escaping="yes"> The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id$
 --&gt;
&lt;xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"&gt;

  &lt;xsl:import href="create_common.xsl"/&gt;

  &lt;xsl:param name="selEditor"&gt;code&lt;/xsl:param&gt;
  
  &lt;xsl:template name="create-content"&gt;
		&lt;xsl:call-template name="form-locationtitle-create"/&gt;
		&lt;xsl:call-template name="form-marknew-pubonsave"/&gt;
		&lt;xsl:call-template name="form-body-create"/&gt;	
		&lt;xsl:call-template name="form-keywordabstract"/&gt;
		&lt;xsl:call-template name="form-grant"/&gt;
  &lt;/xsl:template&gt;

  &lt;xsl:template name="testbodysxml"/&gt;
  &lt;xsl:template name="prettyprint"/&gt;
&lt;/xsl:stylesheet&gt;
</xsl:text>
</xsl:template>
</xsl:stylesheet>
