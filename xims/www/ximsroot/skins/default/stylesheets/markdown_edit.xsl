<?xml version="1.0"?>
<!--
 # Copyright (c) 2002-2017 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id$
 -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="javascript_edit.xsl"/>

  <xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitle-edit"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
    <xsl:call-template name="form-nav-options"/>
	<xsl:call-template name="form-body-edit"/>
	<xsl:call-template name="jsorigbody"/>
    <xsl:call-template name="social-bookmarks"/>
	<xsl:call-template name="form-keywordabstract"/>
  </xsl:template>
  
  <xsl:template name="form-minify"/>
</xsl:stylesheet>
