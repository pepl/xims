<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--$Id$-->

    <xsl:import href="../common.xsl"/>
    <xsl:import href="common_export.xsl"/>

    <xsl:output method="xml"/>

    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:variable name="puburl">
      <xsl:apply-templates select="/document/context/object/parents" mode="puburl"/>
      <xsl:value-of select="/document/context/object/location"/>
      <xsl:text>/</xsl:text>
    </xsl:variable>

    <xsl:template match="/document/context/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
     
        <page>
            <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{department_id}/ou.xml"/>
            <rdf:RDF xmlns:rdf     = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                     xmlns:dc      = "http://purl.org/dc/elements/1.1/"
                     xmlns:dcq     = "http://purl.org/dc/qualifiers/1.0/"
                     xmlns         = "http://www.w3.org/1999/xhtml">
                <rdf:Description about="">
                    <dc:title><xsl:value-of select="title"/></dc:title>
                    <dc:creator><xsl:call-template name="creatorfullname"/></dc:creator>
                    <dc:subject><xsl:value-of select="keywords"/></dc:subject>
                    <dc:description><xsl:value-of select="abstract"/></dc:description>
                    <dc:publisher><xsl:call-template name="ownerfullname"/></dc:publisher>
                    <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
                    <dc:date>
                        <dcq:created>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="creation_time" mode="ISO8601"/></rdf:value>
                            </rdf:Description>
                        </dcq:created>
                        <dcq:modified>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/></rdf:value>
                            </rdf:Description>
                        </dcq:modified>
                    </dc:date>
                    <!-- should be mime-type here -->
                    <dc:format><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/></dc:format>
                    <!-- still to come -->
                    <!--           <dc:language></dc:language> -->
                </rdf:Description>
            </rdf:RDF>

            <path>
              <xsl:apply-templates select="." mode="path-element"/>
            </path>
 
            <body>
             <div about="{$puburl}" 
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:dc="http://purl.org/dc/elements/1.1/"
                  xmlns:rss="http://purl.org/rss/1.0/"
                  typeof="rss:channel">
                <h1 property="rss:title" ><xsl:value-of select="title"/></h1>
                <p property="rss:description"><xsl:value-of select="abstract"/></p>
                <xsl:if test="count(children/object[published=1])&gt;0">
                  <div rel="rss:items">
                    <div rel="rdf:Seq">
                      <xsl:apply-templates select="children/object[published=1]" mode="rdf-li">
                        <xsl:sort select="position"
                                  order="ascending"
                                  data-type="number"/>
                      </xsl:apply-templates>
                    </div>
                  </div> 
                 
                  <ul id="autoindex-item-list">
                    <xsl:apply-templates select="children/object[published=1]" mode="item">
                      <xsl:sort select="position"
                                order="ascending"
                                data-type="number"/>
                    </xsl:apply-templates>
                  </ul>
                </xsl:if>
             </div>
            </body>
        </page>
    </xsl:template>

   <xsl:template match="children/object" mode="rdf-li">
     <span rel="rdf:li">
       <xsl:attribute name="resource">
         <xsl:choose>
           <xsl:when test="starts-with(location, '/') or starts-with(location, 'http://')">
	     <xsl:value-of select="location"/>
           </xsl:when>
           <xsl:otherwise>
              <xsl:value-of select="concat($puburl, location)"/>
           </xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
     </span>
   </xsl:template>

    <xsl:template match="children/object" mode="item">
      <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
      </xsl:variable>
      <xsl:variable name="item-puburl">
        <xsl:choose>
           <xsl:when test="starts-with(location, '/') or starts-with(location, 'http://')">
             <xsl:value-of select="location"/>
           </xsl:when>
           <xsl:otherwise>
              <xsl:value-of select="concat($puburl, location)"/>
           </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <li class="list_{/document/data_formats/data_format[@id=$dataformat]/name}"
          about="{$item-puburl}">
        <a href="{$item-puburl}">
          <span property="rss:title"><xsl:value-of select="title"/></span>
        </a>
        <span property="rss:link" content="{$item-puburl}" />
        <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name != 'URL'">
          <span property="dc:date">
            <xsl:attribute name="content">
              <xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/>
            </xsl:attribute>
          </span>
          <span property="dc:format" content="{/document/data_formats/data_format[@id=$dataformat]/mime_type}" />
          <xsl:if test="string-length(normalize-space(keywords)) &gt; 0">
            <span property="dc:subject" content="{translate(keywords, ';', ',')}" />
          </xsl:if>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(abstract)) &gt; 0">
          <p property="rss:description">
            <xsl:value-of select="abstract"/>
          </p>
        </xsl:if>
      </li>
    </xsl:template>

</xsl:stylesheet>
