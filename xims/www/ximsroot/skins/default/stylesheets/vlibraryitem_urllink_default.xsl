<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_urllink_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

 <!-- <xsl:import href="vlibrary_common.xsl"/>-->
  <xsl:import href="view_common.xsl"/>
  
  <xsl:template name="view-content">
 <!--<div id="docbody">
                <xsl:call-template name="div-vlitemmeta"/>
                <xsl:choose>
                  <xsl:when test="$section > 0 and $section-view='true'">
                    <xsl:apply-templates select="$docbookroot"
                                         mode="section-view"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="$docbookroot"/>
                  </xsl:otherwise>
                </xsl:choose>
              </div>  -->
  </xsl:template>
</xsl:stylesheet>