<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_document_default.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
  <xsl:import href="document_common.xsl"/>
  <xsl:import href="document_default.xsl"/>
  <xsl:import href="vlibraryitem_docbookxml_default.xsl"/>
 
 		
  <xsl:template name="pre-body-hook">
    <xsl:call-template name="div-vlitemmeta"/>
  </xsl:template>
       
  <xsl:template name="view-content">
    <div id="docbody">
      <xsl:comment/>
      <div id="content">
         <xsl:call-template name="pre-body-hook"/>
         <xsl:apply-templates select="body"/>
      </div>      
      <xsl:call-template name="documentlinks"/>
    </div>
  </xsl:template>

</xsl:stylesheet>

