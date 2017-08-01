<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: $
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <!-- 
       common export template(s) 
       (There is a common.xsl one level above, but its namespace defaults to 
        xhtml :-/)
  -->


  <xsl:template match="object" mode="path-element">
    <xsl:variable name="object-type-id"
                  select="object_type_id"/>

    <xsl:if test="parent::context">
      <xsl:apply-templates select="parents/object"
                           mode="path-element"/>
    </xsl:if>

    <element location="{location}"
             title="{title}"
             object-type-fullname="{/document/object_types/object_type
                                        [@id=$object-type-id]/fullname}"/>
  </xsl:template>
  
  <xsl:template match="children/object">
    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <!-- this should be switched to xlink spec -->
    <xsl:choose>
      <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
        <link type="locator" title="{title}" href="{location}">
          <xsl:if test="document_role/text()">
            <xsl:attribute name="role">
              <xsl:value-of select="document_role"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="image_id/text()">
            <xsl:attribute name="image">
              <xsl:value-of select="image_id"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="keywords/text()">
            <xsl:attribute name="keywords">
              <xsl:value-of select="keywords"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="abstract/text()">
            <abstract>
              <xsl:value-of select="abstract"/>
            </abstract>
          </xsl:if>
        </link>
      </xsl:when>
      <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
        <link type="locator" title="{title}" href="{symname_to_doc_id}" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
