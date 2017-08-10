<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_docbookxml_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="vlibraryitem_common.xsl"/>
<xsl:import href="edit_common.xsl"/>
<xsl:import href="codemirror_scripts.xsl"/>

  <xsl:param name="codemirror" select="true()"/>  
  <xsl:param name="cm_mode">xml</xsl:param>
  <xsl:param name="selEditor">code</xsl:param>
<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>

	<xsl:param name="vlib" select="true()"/>

<xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitle-edit_xml"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
  <xsl:call-template name="form-body-edit"/>
  <xsl:call-template name="jsorigbody"/>
  <xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'keyword'"/>
	</xsl:call-template>

	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'subject'"/>
	</xsl:call-template>
	
</xsl:template>

<xsl:template name="form-keywords"/>
<xsl:template name="trytobalance"/>
<xsl:template name="form-minify"/>

</xsl:stylesheet>
