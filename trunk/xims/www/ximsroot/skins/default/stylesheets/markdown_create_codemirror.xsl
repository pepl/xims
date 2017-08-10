<?xml version="1.0" encoding="utf-8"?>
<!--
  # Copyright (c) 2002-2017 The XIMS Project. # See the file "LICENSE"
  for information and conditions for use, reproduction, # and
  distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
  $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="javascript_create.xsl"/>
  <xsl:import href="codemirror_scripts.xsl"/>

  <xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
    <xsl:call-template name="form-nav-options"/>
	<xsl:call-template name="form-body-create"/>	
	<xsl:call-template name="jsorigbody"/>
	<xsl:call-template name="social-bookmarks"/>
    <xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-grant"/>
  </xsl:template>

  <xsl:param name="codemirror" select="true()"/>
  <xsl:param name="cm_mode">markdown</xsl:param>

  <xsl:template name="form-minify"/>
</xsl:stylesheet>
