<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date">

  <xsl:import href="../common.xsl"/>
  <xsl:import href="common_export.xsl"/>
  
  <xsl:output method="xml"/>

  <xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
  </xsl:template>

  <xsl:template match="/document/context/object">
    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    
    <page>
      <xsl:if test="document_role/text()">
        <xsl:attribute name="role">
          <xsl:value-of select="document_role"/>
        </xsl:attribute>
      </xsl:if>
      <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{department_id}/ou.xml"/>
      <rdf:RDF xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:dc  = "http://purl.org/dc/elements/1.1/"
               xmlns:dcq = "http://purl.org/dc/qualifiers/1.0/">
        <rdf:Description about="">
          <dc:title><xsl:value-of select="title"/></dc:title>
          <dc:creator><xsl:call-template name="ownerfullname"/></dc:creator>
          <dc:subject><xsl:value-of select="keywords"/></dc:subject>
          <dc:description><xsl:value-of select="abstract"/></dc:description>
          <dc:publisher><xsl:call-template name="ownerfullname"/></dc:publisher>
          <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
          <dc:date>
            <dcq:created>
              <rdf:Description>
                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                <rdf:value><xsl:apply-templates select="creation_timestamp" mode="ISO8601"/></rdf:value>
              </rdf:Description>
            </dcq:created>
            <dcq:modified>
              <rdf:Description>
                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                <rdf:value><xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/></rdf:value>
              </rdf:Description>
            </dcq:modified>
          </dc:date>
          <dc:format><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/></dc:format>
          <!-- still to come -->
          <dc:language><xsl:value-of select="substring-after(location, 'html.')"/></dc:language>
        </rdf:Description>
      </rdf:RDF>
      
      <path>
        <xsl:apply-templates select="." mode="path-element"/>
      </path>
      
      <body>
        <article id="newsitem" class="item" typeof="Article" resource="#newsitem">
       
          <!-- Title -->
          <h1  id="newsitem-title" property="name">
            <xsl:value-of select="title"/>
          </h1>
     
          <!-- Text: Lead und Story -->
          <div property="articleBody">

          <!-- date -->
          <time id="newsitem-date" property="datePublished">
            <xsl:attribute name="datetime">
              <xsl:apply-templates select="valid_from_timestamp" mode="ISO8601"/>
            </xsl:attribute>
            <xsl:value-of select="valid_from_timestamp/day"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="valid_from_timestamp/month"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="valid_from_timestamp/year"/>
          </time>

          <!-- lead -->
          <div id="newsitem-lead" class="lead">
            <xsl:apply-templates select="abstract"/>
          </div>

          <!-- story -->
          <div id="newsitem-story" class="story">
            <!-- when img existent, process it -->
            <xsl:if test="image_id/location_path != ''">
              <xsl:apply-templates select="image_id"/>
            </xsl:if>
          
            <xsl:apply-templates select="body"/>
          </div>
          </div>
        </article>
      </body>

      <links>
        <xsl:apply-templates select="children/object">
          <xsl:sort select="position" data-type="number"/>
        </xsl:apply-templates>
        <xsl:if test="attributes/gen-social-bookmarks='1'">
          <gen-social-bookmarks/>
        </xsl:if>
      </links>
    </page>
  </xsl:template>

  <xsl:template match="object/body//*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="image_id">
    <figure id="newsitem-image" typeof="ImageObject">
      <a  property="contentUrl" 
          type="{concat('image/', translate(@data_format_name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))}" 
          title="{abstract}"
          href="{location_path}">
        <img class="photo" alt="{title}" src="{location_path}"/>
      </a>
      <xsl:if test="normalize-space(abstract) != ''">
        <figcaption property="description"><xsl:value-of select="abstract"/></figcaption>
      </xsl:if>
    </figure>
  </xsl:template>

</xsl:stylesheet>
