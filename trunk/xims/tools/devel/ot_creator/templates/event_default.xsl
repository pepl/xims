<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
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
# Copyright (c) 2002-</xsl:text><xsl:value-of select="date:year()"/><xsl:text disable-output-escaping="yes"> The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
--&gt;
&lt;xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"&gt;

  &lt;xsl:import href="view_common.xsl"/&gt;
  &lt;xsl:import href="text_common.xsl"/&gt;

  &lt;xsl:template name="view-content"&gt;
	&lt;div id="docbody"&gt;
      &lt;xsl:comment/&gt;
	  &lt;xsl:apply-templates select="body"/&gt;
	&lt;/div&gt;
  &lt;/xsl:template&gt;

&lt;/xsl:stylesheet&gt;
</xsl:text>
</xsl:template>
</xsl:stylesheet>
