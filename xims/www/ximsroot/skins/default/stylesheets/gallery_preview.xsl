<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: gallery_default.xsl 1652 2007-03-24 16:14:37Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="folder_default.xsl"/>
<xsl:import href="gallery_common.xsl"/>

<xsl:param name="view">preview</xsl:param>

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
<xsl:variable name="img-height" select="floor($img-width * 0.75)"/>
<xsl:variable name="shownav" select="/document/context/object/attributes/shownavigation"/>
<xsl:variable name="showcaption" select="/document/context/object/attributes/showcaption"/>
<xsl:variable name="scroll-content-width">
	<xsl:choose>
		<xsl:when test="$thumbnail-pos='left'"><xsl:value-of select="60"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$img-count * 50 + 50"/></xsl:otherwise>
	</xsl:choose>
</xsl:variable>
		
	<xsl:template name="view-content">
		<h1><xsl:value-of select="/document/context/object/title"/></h1>
		<p><xsl:value-of select="abstract"/></p>
		<xsl:apply-templates select="/document/context/object/children"/>
	
		<script type="text/javascript">
					function scaleimg(){
						var height = $('.replaced').height();
						var width = $('.replaced').width();		
						$('.replaced').css('width', <xsl:value-of select="$img-width"/>);
						$('.replaced').css('height', <xsl:value-of select="$img-width"/> * height / width);
					}
        </script>
		<script type="text/javascript" src="{$ximsroot}vendor/jquery-galleria/jquery.galleria.js"><xsl:comment/></script>				
		<script type="text/javascript" src="{$ximsroot}scripts/galleria.js"><xsl:comment/></script>
	</xsl:template>
	
	<xsl:template match="/document/context/object/children">
	
	<xsl:if test="$thumbnail-pos='top'">
			
			<div class="scroll-pane ui-widget ui-widget-header ui-corner-all">
			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="/document/context/object/children/object"/>
				</ul>
		</div>	
		</div>
	<xsl:call-template name="main-img"/>
	<br class="clear"/>
	</xsl:if>
	
	<xsl:if test="$thumbnail-pos='left'">
	<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all">			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="/document/context/object/children/object"/>
				</ul>
		</div>
	</div>
	<xsl:call-template name="main-img"/>	
	<br class="clear"/>
	</xsl:if>
	
	
	<xsl:if test="$thumbnail-pos='bottom'">
	<xsl:call-template name="main-img"/>
	<div class="scroll-pane ui-widget ui-widget-header ui-corner-all">
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="/document/context/object/children/object"/>
				</ul>
		</div>
	</div>
	<br class="clear"/>
	</xsl:if>

	<xsl:if test="$thumbnail-pos='no'">
		<xsl:call-template name="main-img"/>
		<ul class="gallery_demo_unstyled" style="display:none;">
      <xsl:apply-templates select="/document/context/object/children/object"/>
    </ul>
	</xsl:if>
</xsl:template>

<xsl:template match="/document/context/object/children/object">
<xsl:if test="object_type_id=3 and published=1">
	<li>
		<xsl:if test="position() = 1"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
		<img src="{$goxims_content}{$absolute_path}/{location}">
		<xsl:attribute name="alt"><xsl:value-of select="title"/></xsl:attribute>
		<xsl:attribute name="title"><!--<xsl:value-of select="title"/>--><xsl:if test="$showcaption = '1' and abstract != ''"><xsl:value-of select="substring(abstract,0,200)"/></xsl:if></xsl:attribute>
		</img>
	</li>
	</xsl:if>
</xsl:template>

<xsl:template name="main-img">
	<div id="main_image">
		<xsl:if test="$shownav = '1'">
			<p class="nav">
				<a href="#" onclick="$.galleria.prev(); return false;">&#171;</a> | <a href="#" onclick="$.galleria.next(); return false;">&#187;</a>
			</p>
		</xsl:if>
	</div>
	<br class="clear"/>
</xsl:template>

<xsl:template name="head_default">
<head>
<meta charset="UTF-8"/>
<title><xsl:call-template name="title"/></title>
	<xsl:call-template name="css"/>	
	<link href="{$ximsroot}stylesheets/gallery.css" rel="stylesheet" type="text/css" media="screen"/>
				
	<style type="text/css">
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
							overflow-y: scroll;
						</xsl:when>
						<xsl:otherwise>
							overflow-x: scroll;
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
							float: left;
						}
					</xsl:if>
	</style>
	<xsl:call-template name="script_head"/>      
</head>    
</xsl:template>
</xsl:stylesheet>
