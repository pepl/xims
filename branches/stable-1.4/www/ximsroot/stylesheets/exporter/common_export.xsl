<?xml version="1.0" encoding="utf-8"?>
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



  <xsl:template match="/document/context/object/parents/object" mode="puburl">
    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='SiteRoot'">
        <xsl:value-of select="title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="location"/>
      </xsl:otherwise>
    </xsl:choose> 
    <xsl:text>/</xsl:text>
  </xsl:template>

</xsl:stylesheet>