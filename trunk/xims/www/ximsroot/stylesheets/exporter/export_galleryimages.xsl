<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: export_galleryimage.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml"/>
    
  <xsl:variable name="defaultsortby">
    <xsl:choose>
      <xsl:when test="/document/context/object/attributes/defaultsortby = 'titlelocation'">
        <xsl:text>title</xsl:text>
      </xsl:when>
      <xsl:when test="/document/context/object/attributes/defaultsortby = 'date'">
        <xsl:text>last_modification_timestamp</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!--  <xsl:value-of select="/document/context/object/attributes/defaultsortby"/> -->
        <xsl:text>position</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="defaultsort">
    <xsl:choose>
      <xsl:when test="/document/context/object/attributes/defaultsort = 'desc'">descending</xsl:when>
      <xsl:otherwise>ascending</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
  </xsl:template>

  <xsl:template match="/document/context/object">
    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>

    <xsl:apply-templates select="children"/>

    </xsl:template>


  <xsl:template match="/document/context/object/children">
    <div class="images">
      <xsl:choose>
      <xsl:when test="$defaultsortby='last_modification_timestamp'">
        <xsl:apply-templates select="./object[published=1]">
          <xsl:sort select="last_modification_timestamp/year" order="{$defaultsort}" data-type="number"/>
          <xsl:sort select="last_modification_timestamp/month" order="{$defaultsort}" data-type="number"/>
          <xsl:sort select="last_modification_timestamp/day" order="{$defaultsort}" data-type="number"/>
          <xsl:sort select="last_modification_timestamp/hour" order="{$defaultsort}" data-type="number"/>
          <xsl:sort select="last_modification_timestamp/minute" order="{$defaultsort}" data-type="number"/>
          <xsl:sort select="last_modification_timestamp/second" order="{$defaultsort}" data-type="number"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$defaultsortby='position'">
        <xsl:apply-templates select="./object[published=1]">
          <xsl:sort select="*[name() = $defaultsortby]" order="{$defaultsort}" data-type="number"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="./object[published=1]">
          <xsl:sort select="*[name() = $defaultsortby]" order="{$defaultsort}"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
	</div>
</xsl:template>

<xsl:template match="/document/context/object/children/object">
  <xsl:if test="object_type_id=3 and published=1">
    <img>
	  <xsl:attribute name="src"><xsl:value-of select="$absolute_path_nosite"/>/<xsl:value-of select="location"/></xsl:attribute>
	  <xsl:attribute name="alt"><xsl:value-of select="title"/></xsl:attribute>
       <xsl:if test="normalize-space(abstract) != ''">
	     <xsl:attribute name="title">
           <xsl:value-of select="abstract"/>
         </xsl:attribute>
       </xsl:if>
      <xsl:if test="normalize-space(rights) != ''">
        <xsl:attribute name="data-rights">
          <xsl:value-of select="normalize-space(rights)"/>
        </xsl:attribute>
      </xsl:if>
    </img>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
