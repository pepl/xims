<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: text_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="view_common.xsl"/>
  <xsl:import href="text_common.xsl"/>

  <xsl:template name="view-content">
	<div id="docbody"><xsl:comment/>
	<xsl:apply-templates select="body"/>
	<!--<xsl:call-template name="body_display_format_switcher"/>-->
	</div>
  </xsl:template>
  
  <xsl:template name="body_display_format_switcher">
    <xsl:choose>
      <xsl:when test="$pre = '0'">
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=1">Zeige Body vorformatiert</a>
      </xsl:when>
      <xsl:otherwise>
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=0">Zeige Body in Standardformatierung</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>

