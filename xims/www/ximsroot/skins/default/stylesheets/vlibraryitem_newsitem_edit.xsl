<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="vlibraryitem_common.xsl"/>
    <xsl:import href="newsitem_edit.xsl"/>

	<xsl:param name="selEditor">wysiwyg</xsl:param>
	<xsl:param name="vlib" select="true()"/>
	
	<xsl:template name="edit-content">
	  <xsl:call-template name="form-locationtitlesubtitle-edit"/>
	  <xsl:call-template name="form-marknew-pubonsave"/>

	  <xsl:call-template name="set-body-edit"/>
		
	  <xsl:call-template name="expandrefs"/>
		
	  <xsl:call-template name="form-metadata">
		<xsl:with-param name="mode">date</xsl:with-param>
	  </xsl:call-template>
		
	  <div class="form-div block">
		<xsl:call-template name="form-vlproperties">
		  <xsl:with-param name="mo" select="'keyword'"/>
		</xsl:call-template>
		<xsl:call-template name="form-vlproperties">
		  <xsl:with-param name="mo" select="'subject'"/>
		</xsl:call-template>
		<xsl:call-template name="form-vlproperties">
		  <xsl:with-param name="mo" select="'author'"/>
		</xsl:call-template>
		<xsl:call-template name="form-vlproperties">
		  <xsl:with-param name="mo" select="'publication'"/>
		</xsl:call-template>
	  </div>
		
	  <xsl:call-template name="form-obj-specific"/>
      
	  <xsl:call-template name="xmlhttpjs"/>

	</xsl:template>
    
    <xsl:template name="form-keywords"/>	
	
    <xsl:template name="set-body-edit">
      <xsl:choose>
        <xsl:when test="document_role='newslink'">
          <xsl:call-template name="form-link"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="form-body-edit"/>
          <xsl:call-template name="jsorigbody"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template name="form-minify"/>
    <xsl:template name="form-bodyfromfile"/>
</xsl:stylesheet>
