<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc  = "http://purl.org/dc/elements/1.1/"
                xmlns:dcq = "http://purl.org/dc/qualifiers/1.0/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:sch = "http://schema.org/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
        <rdf:RDF>
          <rdf:Description about="{location}">
            <dc:title><xsl:value-of select="title"/></dc:title>
            <dc:creator><xsl:call-template name="ownerfullname"/></dc:creator>
            <dc:subject><xsl:value-of select="keywords"/></dc:subject>
            <dc:description><xsl:copy-of select="abstract/node()"/></dc:description>
            <dc:publisher><xsl:call-template name="ownerfullname"/></dc:publisher>
            <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
            <sch:contentSize>
              <xsl:value-of select="content_length div 1024"/>
              <xsl:text> KB</xsl:text>
            </sch:contentSize>
            <dc:rights><xsl:copy-of select="rights/node()"/></dc:rights>
            <dc:date>
              <dcq:created>
                <rdf:Description>
                  <dcq:dateScheme
                  rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
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
            <xsl:apply-templates select="children/object"/>
          </rdf:Description>
        </rdf:RDF>
      </xsl:template>
      <xsl:template match="children/object[data_format_name='URL' and document_role='license']">
        <dcterms:license><xsl:value-of select="location"/></dcterms:license>
      </xsl:template>
      <xsl:template match="children/object[data_format_name='URL' and not(document_role/text())]">
        <dcterms:references><xsl:value-of select="location"/></dcterms:references>
      </xsl:template>
      
</xsl:stylesheet>
