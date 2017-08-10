<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: file_default.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <xsl:import href="file_default.xsl"/>

    <xsl:template name="view-content">
      <xsl:call-template name="object-metadata"/>
      <div style="max-height:640px;overflow:scroll;">
        <img src="{$goxims_content}{$absolute_path}" title="{title}"/>	   
      </div>
      <xsl:call-template name="documentlinks"/>
      <xsl:call-template name="summary_keywords"/>
      <xsl:call-template name="summary_rights"/>
    </xsl:template>
</xsl:stylesheet>
