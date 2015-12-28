<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="document_common.xsl"/>
  	<xsl:import href="view_common.xsl"/>
            
<!-- parameter to allow loading of css-styles needed to match  xims- with public-layout-->
	<xsl:param name="sitestyle" select="true()"/>
	
	<!-- firstlevel folders are considered to be 'sites' -->
	<xsl:variable name="site_location">
		<xsl:choose>
			<xsl:when test="$resolvereltositeroots = 1">/<xsl:value-of select="/document/context/object/parents/object[@parent_id = '1' and @id != '1']/location"/>
			</xsl:when>
			<xsl:otherwise>/</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template name="view-content">
	  <div id="docbody">
        <xsl:comment/>
	    <div id="content">
		  <xsl:call-template name="pre-body-hook"/>
		  <xsl:apply-templates select="body"/>
	    </div>	
	    <xsl:call-template name="documentlinks"/>
	    <xsl:call-template name="summary_keywords"/>
	  </div>
	</xsl:template>
	
	<xsl:template match="a">
		<a>
			<xsl:choose>
				<xsl:when test="$printview != '0'">
					<xsl:value-of select="."/>
					<xsl:text>&#160;</xsl:text>[<xsl:value-of select="@href"/>]
            </xsl:when>
				<xsl:otherwise>
					<xsl:if test="@href != ''">
						<xsl:attribute name="href"><xsl:choose><xsl:when test="starts-with(@href,'/') and not(starts-with(@href,$goxims_content))"><xsl:value-of select="concat($goxims_content,$site_location,@href)"/></xsl:when><xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise></xsl:choose></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="title"><xsl:choose><xsl:when test="@title != ''"><xsl:value-of select="@title"/></xsl:when><xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise></xsl:choose></xsl:attribute>
					<xsl:if test="@target != ''">
						<xsl:attribute name="target"><xsl:value-of select="@target"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="@name != ''">
						<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="@id != ''">
						<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="@class != ''">
						<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
					</xsl:if>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>
	
	<xsl:template match="img">
		<img>
			<xsl:attribute name="src"><xsl:choose><xsl:when test="starts-with(@src,'/') and not(starts-with(@src,$goxims_content))"><xsl:value-of select="concat($goxims_content,$site_location,@src)"/></xsl:when><xsl:otherwise><xsl:value-of select="@src"/></xsl:otherwise></xsl:choose></xsl:attribute>
			<xsl:if test="@title != ''">
				<xsl:attribute name="title"><xsl:value-of select="@title"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@alt != ''">
				<xsl:attribute name="alt"><xsl:value-of select="@alt"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@width != ''">
				<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@height != ''">
				<xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@border != ''">
				<xsl:attribute name="border"><xsl:value-of select="@border"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@align != ''">
				<xsl:attribute name="align"><xsl:value-of select="@align"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@class != ''">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@style != ''">
				<xsl:attribute name="style"><xsl:value-of select="@style"/></xsl:attribute>
			</xsl:if>
		</img>
	</xsl:template>
	
	<xsl:template match="script">
		<script xmlns="http://browser.wont.parse.cdata.sections.so.we.workaround.here/">
			<xsl:if test="@src != ''">
				<xsl:attribute name="src"><xsl:value-of select="@src"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@type != ''">
				<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
			</xsl:if>
			<xsl:value-of select="text()"/>
            <xsl:comment/>
		</script>
	</xsl:template>
	
	<xsl:template name="pre-body-hook">
		<!-- Do nothing; derived stylesheets may overwrite this template. -->
	</xsl:template>

</xsl:stylesheet>
