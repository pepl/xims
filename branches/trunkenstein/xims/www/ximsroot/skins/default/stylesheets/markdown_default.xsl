<?xml version="1.0"?>
<!--
  # Copyright (c) 2002-2013 The XIMS Project.
  # See the file "LICENSE" for information and conditions for use, reproduction,
  # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
  # $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="view_common.xsl"/>

  <xsl:template name="view-content">
    <div id="docbody">
      <xsl:comment/>
      <xsl:apply-templates select="body"/>
    </div>
  </xsl:template>

</xsl:stylesheet>