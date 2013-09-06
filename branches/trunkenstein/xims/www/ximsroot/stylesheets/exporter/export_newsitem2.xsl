<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
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
   
    <!-- <xsl:variable name="valid_from_timestamp">
      <xsl:apply-templates select="valid_from_timestamp" mode="ISO8601"/>
    </xsl:variable> -->

    <page>
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
        <div id="newsitem" class="hentry item">
       
          <!-- Title -->
          <h1 id="newsitem-title">
            <span class="entry-title">
              <xsl:value-of select="title"/>
            </span>
          </h1>
          
          
          <!-- when img existent, process it -->
          <xsl:if test="image_id/location_path != ''">
            <xsl:apply-templates select="image_id"/>
          </xsl:if>

          <!-- date -->
          <div id="newsitem-date" class="date published">
            <span class="value-title">
              <xsl:attribute name="title">
	        <xsl:apply-templates select="valid_from_timestamp" mode="ISO8601"/>
	      </xsl:attribute>
            </span>
            <xsl:value-of select="valid_from_timestamp/day"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="valid_from_timestamp/month"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="valid_from_timestamp/year"/>
          </div>

          <!-- lead -->
          <div id="newsitem-lead" class="lead entry-summary">
            <xsl:apply-templates select="abstract"/>
          </div>

          <!-- story -->
          <div id="newsitem-story" class="story entry-content">
            <xsl:apply-templates select="body"/>
          </div>
        </div> <!-- close div with class newsitem -->
      </body>

      <links>
        <xsl:apply-templates select="children/object">
          <xsl:sort select="position" data-type="number"/>
        </xsl:apply-templates>
      </links>
    </page>
  </xsl:template>

  <xsl:template match="object/body//*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
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
        <link type="locator" title="{title}" href="{location}"/>
      </xsl:when>
      <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
        <link type="locator" title="{title}" href="{symname_to_doc_id}" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="image_id">
    <div id="newsitem-image" class="hmedia">
      <a rel="enclosure" 
         type="{concat('image/', translate(@data_format_name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))}" 
         title="{abstract}"
         href="{location_path}">
        <img class="photo" alt="{title}" src="{location_path}"/>
      </a>
      <xsl:if test="normalize-space(image/@longdesc) != ''">
        <span class="fn"><xsl:value-of select="@longdesc"/></span>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- <image_id> -->
  <!--   <abstract>&#xA0;</abstract> -->
  <!--   <id>223602</id> -->
  <!--   <document_id>263592</document_id> -->
  <!--   <parent_id>79973</parent_id> -->
  <!--   <object_type_id>3</object_type_id> -->
  <!--   <data_format_id>9</data_format_id> -->
  <!--   <symname_to_doc_id/> -->
  <!--   <location>copy_of_info.gif</location> -->
  <!--   <location_path>/test/copy_of_info.gif</location_path> -->
  <!--   <title>Copy of InfoBild</title> -->
  <!-- </image_id> -->

</xsl:stylesheet>
