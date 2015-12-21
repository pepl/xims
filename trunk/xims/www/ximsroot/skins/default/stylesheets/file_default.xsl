<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: file_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="view_common.xsl"/>
    
    <xsl:template name="view-content">
      <xsl:call-template name="object-metadata"/>
      <div>
        <a href="{$goxims_content}{$absolute_path}"><xsl:value-of select="$i18n/l/View_download"/></a>&#160;<!--<xsl:value-of select="$objtype"/>-->
	    <xsl:call-template name="objtype_name">
		  <xsl:with-param name="ot_name">
			<xsl:value-of select="$objtype"/>
		  </xsl:with-param>
	    </xsl:call-template>
      </div>
      <xsl:call-template name="documentlinks"/>
	  <xsl:call-template name="summary_keywords"/>
      <xsl:call-template name="summary_rights"/>
    </xsl:template>
    
</xsl:stylesheet>
