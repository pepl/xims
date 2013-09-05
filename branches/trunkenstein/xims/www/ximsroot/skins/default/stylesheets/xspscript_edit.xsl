<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xspscript_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common.xsl"/>
	
	<xsl:param name="selEditor">code</xsl:param>
	
	<xsl:template name="edit-content">
	  <xsl:call-template name="form-locationtitle-edit_xml"/>
	  <xsl:call-template name="form-marknew-pubonsave"/>
	  <xsl:call-template name="form-body-edit"/>
	  <xsl:call-template name="jsorigbody"/>
	  <xsl:call-template name="form-keywordabstract"/>
	  
	</xsl:template>
	
	<xsl:template name="trytobalance"/>
    <xsl:template name="form-minify"/>
    <xsl:template name="prettyprint"/>
    <xsl:template name="testbodysxml"/>
</xsl:stylesheet>
