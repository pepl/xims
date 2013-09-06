<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_default.xsl 2203 2009-04-29 10:46:36Z haensel $
-->

<!DOCTYPE stylesheet [
<!ENTITY  fromchars "'aÄäbcdefghijklmnoÖöpqrsßtuÜüvwxyz@„&quot;'">
<!ENTITY    tochars "'AAABCDEFGHIJKLMNOOOPQRSSTUUUVWXYZ___'">
]>


<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml" 
                extension-element-prefixes="exslt">

  <xsl:import href="vlibrary_common.xsl"/>
  <xsl:import href="view_common.xsl"/>

<xsl:param name="vlib">true</xsl:param>
<xsl:param name="parent_id"><xsl:value-of select="/document/object_types/object_type[name='VLibraryItem']/@id" /></xsl:param>
<xsl:param name="createwidget">default</xsl:param>
  <xsl:variable name="subjectcolumns" select="'3'"/>
  
<xsl:param name="mo" select="'subject'"/>

  <xsl:key name="subject_id" match="subject/id" use="."/>
  
  <xsl:variable name="properties">
    <xsl:for-each select="/document/context/vlsubjectinfo/subject">
      <xsl:copy>
        <xsl:copy-of select="*"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>  

  <xsl:variable name="vlib_ots">
    <xsl:for-each select="/document/object_types/object_type[parent_id !='']">
      <xsl:copy>
        <xsl:copy-of select="name|@id"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template name="view-content">
		<div><xsl:comment/>
			<xsl:apply-templates select="abstract"/>
		</div>
		<div id="search-filter">
			<xsl:call-template name="search_switch">
				<xsl:with-param name="mo" select="$mo"/>
			</xsl:call-template>
			<xsl:call-template name="chronicle_switch" />
			<br class="clear"/>
    </div>
    
    <xsl:call-template name="vlproperty-list">
			<xsl:with-param name="mo" select="$mo"/>
    </xsl:call-template>
    <!--<div id="vlib-subjects">
      <xsl:apply-templates select="/document/context/vlsubjectinfo"/>
    </div>-->
    <br class="clear"/>
  </xsl:template>
  
  <xsl:template name="vlproperty-list">
		<xsl:param name="mo"/>
		<div id="vlib-subjects">
		<xsl:choose>
			<xsl:when test="$mo = 'subject'">
				<xsl:apply-templates select="/document/context/vlsubjectinfo"/>
			</xsl:when>
			<xsl:when test="$mo = 'author'">
				<xsl:apply-templates select="/document/context/vlauthorinfo"/>
			</xsl:when>
			<xsl:when test="$mo = 'keyword'">
				<xsl:apply-templates select="/document/context/vlkeywordinfo"/>
			</xsl:when>
<xsl:when test="$mo = 'publication'">
				<xsl:apply-templates select="/document/context/vlpublicationinfo"/>
			</xsl:when>
		</xsl:choose>
  </div>
  </xsl:template>

  <xsl:template match="vlsubjectinfo">
    <xsl:variable name="sorteddistinctsubjects">
     <xsl:for-each select="/document/context/vlsubjectinfo/subject[object_count &gt; 0 and generate-id(id)=generate-id(key('subject_id',id)[1])]">
        <xsl:sort select="translate(name,&fromchars;,&tochars;)" order="ascending"/>
        <xsl:copy>
          <xsl:copy-of select="*"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>    

    <xsl:variable name="unmappeddistinctsubjects">
      <xsl:for-each select="/document/context/vlsubjectinfo/subject[object_count = 0 and generate-id(id)=generate-id(key('subject_id',id)[1])]">
        <xsl:sort select="translate(name,&fromchars;,&tochars;)" order="ascending"/>
        <xsl:copy>
          <xsl:copy-of select="*"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>  
    
    <xsl:call-template name="vlpropertyinfo">
			<xsl:with-param name="sortedproperties" select="$sorteddistinctsubjects"/>
			<xsl:with-param name="unmappedproperties" select="$unmappeddistinctsubjects"/>
			<xsl:with-param name="mo" select="'subject'"/>
    </xsl:call-template>
 </xsl:template>
 
  <xsl:template name="vlpropertyinfo">
  <xsl:param name="sortedproperties"/>
  <xsl:param name="unmappedproperties"/>
  <xsl:param name="mo"/>
	
<div class="block">
	<h2>
		<xsl:choose>
		<xsl:when test="$mo = 'subject'"><xsl:value-of select="$i18n_vlib/l/subjects"/></xsl:when>
		<xsl:when test="$mo = 'keyword'"><xsl:value-of select="$i18n_vlib/l/keywords"/></xsl:when>
		<xsl:when test="$mo = 'author'"><xsl:value-of select="$i18n_vlib/l/authors"/></xsl:when>
		<xsl:when test="$mo = 'publication'"><xsl:value-of select="$i18n_vlib/l/publications"/></xsl:when>
	</xsl:choose>
	</h2>
</div>
<ul>
	<xsl:choose>
		<xsl:when test="$mo = 'subject'"><xsl:apply-templates select="exslt:node-set($sortedproperties)/subject"></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'keyword'"><xsl:apply-templates select="exslt:node-set($sortedproperties)/keyword"></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'author'"><xsl:apply-templates select="exslt:node-set($sortedproperties)/author"></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'publication'"><xsl:apply-templates select="exslt:node-set($sortedproperties)/publication"></xsl:apply-templates></xsl:when>
	</xsl:choose>
</ul>
<br class="clear"/><br/>
<div class="block">
<h2>
	<xsl:value-of select="$i18n_vlib/l/unmapped"/>&#160;
<xsl:choose>
		<xsl:when test="$mo = 'subject'"><xsl:value-of select="$i18n_vlib/l/subjects"/></xsl:when>
		<xsl:when test="$mo = 'keyword'"><xsl:value-of select="$i18n_vlib/l/keywords"/></xsl:when>
		<xsl:when test="$mo = 'author'"><xsl:value-of select="$i18n_vlib/l/authors"/></xsl:when>
		<xsl:when test="$mo = 'publication'"><xsl:value-of select="$i18n_vlib/l/publications"/></xsl:when>
	</xsl:choose>
	</h2>
	</div>
<ul><xsl:comment/>
<xsl:choose>
		<xsl:when test="$mo = 'subject'"><xsl:apply-templates select="exslt:node-set($unmappedproperties)/subject"></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'keyword'"><xsl:apply-templates select="exslt:node-set($unmappedproperties)/keyword"></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'author'"><xsl:apply-templates select="exslt:node-set($unmappedproperties)/author"></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'publication'"><xsl:apply-templates select="exslt:node-set($unmappedproperties)/publication"></xsl:apply-templates></xsl:when>
	</xsl:choose>
</ul>
  </xsl:template>
  
  <xsl:template match="subject|author|keyword|publication">
    <xsl:call-template name="item_list">
        <xsl:with-param name="mo" select="$mo"/>
        <xsl:with-param name="colms" select="$subjectcolumns"/>
    </xsl:call-template>
</xsl:template>
  
    <xsl:template name="item_list">
		<xsl:param name="mo"/>
    <li class="vliteminfo">
      <h3>
        <xsl:call-template name="property_link">
          <xsl:with-param name="mo" select="$mo"/>
        </xsl:call-template>
        </h3>
        
        <xsl:choose>
		<xsl:when test="$mo = 'subject'"><xsl:apply-templates select="exslt:node-set($properties)/subject[id=current()/id]" mode="item_count"><xsl:sort select="object_count" order="descending"/></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'keyword'"><xsl:apply-templates select="exslt:node-set($properties)/keyword[id=current()/id]" mode="item_count"><xsl:sort select="object_count" order="descending"/></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'author'"><xsl:apply-templates select="exslt:node-set($properties)/author[id=current()/id]" mode="item_count"><xsl:sort select="object_count" order="descending"/></xsl:apply-templates></xsl:when>
		<xsl:when test="$mo = 'publication'"><xsl:apply-templates select="exslt:node-set($properties)/publication[id=current()/id]" mode="item_count"><xsl:sort select="object_count" order="descending"/></xsl:apply-templates></xsl:when>
	</xsl:choose>

      <xsl:if test="last_modification_timestamp/day">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$i18n_vlib/l/last_modified_at"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="last_modification_timestamp"
          mode="datetime" />
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="subject|author|keyword|publication" mode="item_count">
    <xsl:value-of select="object_count"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="exslt:node-set($vlib_ots)/object_type[@id=current()/object_type_id]/name"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="decide_plural">
      <xsl:with-param name="objectitems_count" select="object_count"/>
    </xsl:call-template>
    <br/>
  </xsl:template>

</xsl:stylesheet>
