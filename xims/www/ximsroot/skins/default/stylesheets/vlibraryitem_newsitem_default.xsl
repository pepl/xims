<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
  <xsl:import href="document_common.xsl"/>
  <xsl:import href="document_default.xsl"/>
  <xsl:import href="vlibraryitem_docbookxml_default.xsl"/>
  <xsl:import href="newsitem2_default.xsl"/>

  
 		
  <xsl:template name="pre-body-hook">
    <xsl:call-template name="div-vlitemmeta"/>
  </xsl:template>

  <xsl:template name="body">
    <xsl:choose>
      <xsl:when test="/document/context/object/document_role='newslink'">
        <p>
          <b>→
          <a href="{body}">
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="starts-with(body/text(), '/')">
                  <xsl:value-of select="concat($goxims_content,
                                               '/',
                                               /document/context/object/parents/object[@parent_id=1]/location,
                                               body)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="body"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="body"/>
          </a>
          </b>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
</xsl:stylesheet>

