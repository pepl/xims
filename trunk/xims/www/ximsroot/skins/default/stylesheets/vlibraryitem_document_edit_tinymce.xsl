<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id:$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="document_edit_tinymce.xsl"/>
  <xsl:import href="vlibraryitem_document_edit.xsl"/>
  
  <xsl:template name="tr_set-body-edit">
    <xsl:call-template name="tr-body-edit_tinymce"/> 
    <script type="text/javascript">timeoutWYSIWYGChange(3);</script>
  </xsl:template>

  <xsl:template name="head">
    <xsl:call-template name="common-head">
      <xsl:with-param name="mode">edit</xsl:with-param>
      <xsl:with-param name="tinymce" select="true()" />
      <xsl:with-param name="calendar" select="true()" />
      <xsl:with-param name="jquery" select="true()" />
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>
