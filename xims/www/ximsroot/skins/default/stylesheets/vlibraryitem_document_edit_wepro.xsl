<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_document_edit_webpro.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
  
   
  <xsl:import href="document_edit_wepro.xsl"/>  
  <xsl:import href="vlibraryitem_document_edit.xsl"/>


  <xsl:template name="tr_set-body-edit">
    <xsl:call-template name="tr-body-edit_wepro"/> 
  </xsl:template>


  <xsl:template name="head">
    <xsl:call-template name="head-edit_wepro"/>
  </xsl:template>

</xsl:stylesheet>
