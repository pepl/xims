<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: export_auto_index.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--$Id: export_auto_index.xsl 2188 2009-01-03 18:24:00Z pepl $-->

  <xsl:import href="../common.xsl"/>
  <xsl:import href="common_export.xsl"/>

  <xsl:output method="xml"/>

  <xsl:param name="thumbnail-pos" select="/document/context/object/attributes/thumbpos"/>
  <xsl:variable name="img-count" select="count(/document/context/object/children/object[published=1])"/>

  <xsl:variable name="img-width">
    <xsl:choose>
      <xsl:when test="/document/context/object/attributes/imgwidth = 'small'">
        <xsl:value-of select="200"/>
      </xsl:when>
      <xsl:when test="/document/context/object/attributes/imgwidth = 'medium'">
        <xsl:value-of select="400"/>
      </xsl:when>
      <xsl:when test="/document/context/object/attributes/imgwidth = 'large'">
        <xsl:value-of select="580"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="img-height" select="ceiling($img-width * 0.75) "/>
  <xsl:variable name="shownav" select="/document/context/object/attributes/shownavigation"/>
  <xsl:variable name="showcaption" select="/document/context/object/attributes/showcaption"/>
  <xsl:variable name="scroll-content-width">
    <xsl:choose>
      <xsl:when test="$thumbnail-pos='left'"><xsl:value-of select="60"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$img-count * 50 + 50"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

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
      <xi:include xmlns:xi="http://www.w3.org/2001/XInclude">
        <xsl:attribute name="href"><xsl:call-template name="departmentpath"/>/ou.xml</xsl:attribute>
      </xi:include>
      <gallery>
        <xsl:copy-of select="attributes"/>
        <styles>
          <!--<link>/stylesheets/gallery.css</link>-->
          <style>
            #main_image{
            width: <xsl:value-of select="$img-width+20"/>px;
            }
            <xsl:if test="$showcaption=0">
              .caption{
              display:none;
              }
            </xsl:if>
            .scroll-pane { 							
            width: <xsl:value-of select="$img-width+20"/>px; 
            <xsl:choose>
              <xsl:when test="$thumbnail-pos='left'">						
                overflow-y: scroll !important;
                overflow-x: auto !important;
              </xsl:when>
              <xsl:otherwise>
                overflow-x: scroll !important;
                overflow-y: auto !important;
              </xsl:otherwise>
            </xsl:choose>							
            }
            .scroll-content {
            width: <xsl:value-of select="$scroll-content-width"/>px; 
            }
            <xsl:if test="$thumbnail-pos='left'">
              .galleria li{
              float: none !important;
              }
              .galleria li img.thumb{
              margin-top: 0 !important;
              }
              .scroll-pane{
              width: 80px !important;
              height: <xsl:value-of select="$img-height+20"/>px !important;		
              margin-top: 2em;
              float:left;
              }
              .scroll-content {
              margin-left: 0 !important;
              }
              #main_image{
              float:left;
              }
            </xsl:if>

          </style>
        </styles>
      </gallery>
      <rdf:RDF xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:dc  = "http://purl.org/dc/elements/1.1/"
               xmlns:dcq = "http://purl.org/dc/qualifiers/1.0/">
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
        </rdf:Description>
      </rdf:RDF>
      <body>
        <h1><xsl:value-of select="title"/></h1>
        <p><xsl:value-of select="abstract"/></p>
        <xsl:apply-templates select="children"/>
      </body>
    </page>
  </xsl:template>


  <xsl:template match="/document/context/object/children">
    <xsl:if test="$thumbnail-pos='top'">
      
      <div class="scroll-pane ui-widget ui-widget-header ui-corner-all">
        <div class="scroll-content">
          <xsl:call-template name="ul-gallery_demo_unstyled"/>
        </div>
      </div>
      <div id="main_image">
        <xsl:if test="$shownav = 1">
          <p class="nav">
            <a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
            <a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
          </p>
        </xsl:if>
      </div>
      <br clear="all"/>
    </xsl:if>
    
    <xsl:if test="$thumbnail-pos='left'">
      <div class="scroll-pane ui-widget ui-widget-header ui-corner-all">
        
        <div class="scroll-content">
          <xsl:call-template name="ul-gallery_demo_unstyled"/>
        </div>	
      </div>
      <div id="main_image">
        <xsl:if test="$shownav = 1">
          <p class="nav">
            <a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
            <a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
          </p>
        </xsl:if>
      </div>
      <br clear="all"/>
    </xsl:if>
    
    <xsl:if test="$thumbnail-pos='bottom'">
      <div id="main_image">
        <xsl:if test="$shownav = 1">
          <p class="nav">
            <a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
            <a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
          </p>
        </xsl:if>
      </div>	
      <div class="scroll-pane ui-widget ui-widget-header ui-corner-all">
        <div class="scroll-content">
          <xsl:call-template name="ul-gallery_demo_unstyled"/>
        </div>
      </div>
      <br clear="all"/>
    </xsl:if>
    
    <xsl:if test="$thumbnail-pos='no'">
      <div id="main_image">
        <xsl:if test="$shownav=1">
          <p class="nav">
            <a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
            <a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
          </p>
        </xsl:if>
      </div>
      
      <div class="scroll-pane ui-widget ui-widget-header ui-corner-all hidden">
        
        <div class="scroll-content">
          <xsl:call-template name="ul-gallery_demo_unstyled"/>
        </div>
      </div>
      <br clear="all"/>
    </xsl:if>
    
    <br/>
    <!-- Scripts for Gallery -->
    <script type="text/javascript" src="/scripts/jquery/jquery.galleria.js"/>
    <script type="text/javascript" src="/scripts/galleria.js"/>
    <script type="text/javascript">
      function scaleimg(){
      var height = $('.replaced').height();
      var width = $('.replaced').width();			
      $('.replaced').css('width', <xsl:value-of select="$img-width"/>);
      $('.replaced').css('height', <xsl:value-of select="$img-width"/> * height / width);
      }
    </script>
  </xsl:template>


  <xsl:template match="/document/context/object/children/object">
    <xsl:if test="object_type_id=3 and published=1">
      <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
      </xsl:variable>
      <!-- 
           This also adds Image-Metadata as RDFa. Maybe the whole
           structure should be more consistent with the RSS-1.0 format
           used in autoindex documents, but I did’t want to break what
           is currently here and working.
      -->
      <li about="{concat($puburl,location)}">
	<xsl:if test="position() = 1"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
	<img src="{location}">
          <xsl:attribute name="alt"><xsl:value-of select="title"/></xsl:attribute>
          <xsl:if test="normalize-space(abstract) != '' and $showcaption = '1'">    
            <xsl:attribute name="title"><xsl:value-of select="substring(abstract,0,200)"/></xsl:attribute>
          </xsl:if>
        </img>
        <xsl:if test="normalize-space(abstract)  != '' and $showcaption = '1'">
          <span property="dc:description" content="{substring(abstract,0,200)}"/>
        </xsl:if>
        <span property="dc:title" content="{title}"/>
        <span property="dc:date">
          <xsl:attribute name="content">
            <xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/>
          </xsl:attribute>
        </span>
        <span property="dc:format" content="{/document/data_formats/data_format[@id=$dataformat]/mime_type}" />
        <xsl:if test="string-length(normalize-space(keywords)) &gt; 0">
          <span property="dc:subject" content="{translate(keywords, ';', ',')}" />
        </xsl:if>
      </li>
    </xsl:if>
  </xsl:template>


  <xsl:template name="ul-gallery_demo_unstyled">
    <ul class="gallery_demo_unstyled">
      <xsl:choose>        
        <xsl:when test="/document/context/object/attributes/defaultsort/text()='desc'">
          <!-- descending sort order -->
          <xsl:choose>
            <xsl:when test="/document/context/object/attributes/defaultsortby/text()='date'">
              <xsl:apply-templates select="object">
                <xsl:sort select="last_modification_timestamp/year" 
                          data-type="number"
                          order="descending"/>
                <xsl:sort select="last_modification_timestamp/month"
                          data-type="number"
                          order="descending"/>
                <xsl:sort select="last_modification_timestamp/day"
                          data-type="number"
                          order="descending"/>
                <xsl:sort select="last_modification_timestamp/hour"
                          data-type="number"
                          order="descending"/>
                <xsl:sort select="last_modification_timestamp/minute"
                          data-type="number"
                          order="descending"/>
                <xsl:sort select="last_modification_timestamp/second"
                          data-type="number"
                          order="descending"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="/document/context/object/attributes/defaultsortby='title'">
              <xsl:apply-templates select="object">
                <xsl:sort select="title" 
                          order="descending"
                          lang="de"
                          data-type="text"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="object">
                <xsl:sort select="position" 
                          order="descending"
                          data-type="number"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
          <!-- end descending sort order -->
        </xsl:when>
        <xsl:otherwise>
          <!-- ascending sort order -->
          <xsl:choose>
            <xsl:when test="$defaultsortby='date'">
              <xsl:apply-templates select="object">
                <xsl:sort select="last_modification_timestamp/year" 
                          data-type="number"
                          order="ascending"/>
                <xsl:sort select="last_modification_timestamp/month"
                          data-type="number"
                          order="ascending"/>
                <xsl:sort select="last_modification_timestamp/day"
                          data-type="number"
                          order="ascending"/>
                <xsl:sort select="last_modification_timestamp/hour"
                          data-type="number"
                          order="ascending"/>
                <xsl:sort select="last_modification_timestamp/minute"
                          data-type="number"
                          order="ascending"/>
                <xsl:sort select="last_modification_timestamp/second"
                          data-type="number"
                          order="ascending"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$defaultsortby='title'">
              <xsl:apply-templates select="object">
                <xsl:sort select="title" 
                          order="ascending"
                          lang="de"
                          data-type="text"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="object">
                <xsl:sort select="position" 
                          order="ascending"
                          data-type="number"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
          <!-- end ascending sort order -->
        </xsl:otherwise>
      </xsl:choose>
    </ul>
  </xsl:template>

</xsl:stylesheet>
