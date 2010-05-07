<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: gallery_default.xsl 1652 2007-03-24 16:14:37Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="folder_default.xsl"/>
<xsl:import href="gallery_common.xsl"/>

<xsl:param name="view">preview</xsl:param>

<xsl:variable name="thumbnail-pos" select="/document/context/object/attributes/thumbpos"/>
<xsl:variable name="img-count" select="count(/document/context/object/children/object[published=1])"/>

<xsl:variable name="scroll-content-width" select="$img-count * 50 + 50"/>
<xsl:variable name="img-width" select="/document/context/object/attributes/imgwidth"/>
<xsl:variable name="img-height" select="floor($img-width * 0.75)"/>

<xsl:variable name="shownav" select="/document/context/object/attributes/shownavigation"/>
<xsl:variable name="showcaption" select="/document/context/object/attributes/showcaption"/>
		
	<xsl:template name="view-content">
		<h1><xsl:value-of select="/document/context/object/title"/></h1>
		<p><em>(<xsl:value-of select="$img-count"/>&#160;<xsl:value-of select="$i18n/l/Images"/>, Größe: <xsl:value-of select="$img-width"/>x<xsl:value-of select="$img-height"/>)</em></p>            
		<p><xsl:value-of select="abstract"/></p>
		<xsl:apply-templates select="/document/context/object/children"/>
	
		<script type="text/javascript" src="{$ximsroot}scripts/jquery/jquery.galleria.js"></script>				
		<script type="text/javascript" src="{$ximsroot}scripts/galleria.js"></script> 				
		<script type="text/javascript">
					function scaleimg(){
						var height = $('.replaced').height();
						var width = $('.replaced').width();					
						$('.replaced').css('width', <xsl:value-of select="$img-width"/>);
						$('.replaced').css('height', <xsl:value-of select="$img-width"/> * height / width);
						//alert($('.replaced').width() + ' x ' + $('.replaced').height());
					}
        </script>
	</xsl:template>
	
	<xsl:template match="/document/context/object/children">
	
	<xsl:if test="$thumbnail-pos='top'">
			
			<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all">
			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="/document/context/object/children/object"/>
				</ul>
		</div>
		<div class="scroll-bar-wrap ui-widget-content ui-corner-bottom">
			<div class="scroll-bar"></div>
		</div>	
	</div>
	<br clear="all"/>
	<xsl:call-template name="main-img"/>
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
	</xsl:if>
	<br clear="all"/>
	
	<xsl:if test="$thumbnail-pos='bottom'">
	<xsl:call-template name="main-img"/>
	<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all">
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="/document/context/object/children/object"/>
				</ul>
		</div>
		<div class="scroll-bar-wrap ui-widget-content ui-corner-bottom">
			<div class="scroll-bar"></div>
		</div>	
	</div>
	<br clear="all"/>
	</xsl:if>

	<xsl:if test="$thumbnail-pos='no'">
		<xsl:call-template name="main-img"/>
	</xsl:if>
</xsl:template>

<xsl:template match="/document/context/object/children/object">
<xsl:if test="object_type_id=3 and published=1">
	<li>
		<xsl:if test="position() = 1"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
		<img src="{$goxims_content}{$absolute_path}/{location}">
		<xsl:attribute name="alt"><xsl:value-of select="title"/></xsl:attribute>
		<xsl:attribute name="title"><xsl:value-of select="title"/><xsl:if test="$showcaption = '1' and abstract != ''"> : <xsl:value-of select="substring(abstract,0,200)"/></xsl:if></xsl:attribute>
		</img>
	</li>
	</xsl:if>
</xsl:template>

<xsl:template name="main-img">
	<div id="main_image">
	<!--<xsl:if test="$thumbnail-pos = 'left'"><xsl:attribute name="class">div-right half-width</xsl:attribute></xsl:if>-->
		<xsl:if test="$shownav = '1'">
			<p class="nav">
				<a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <xsl:value-of select="$i18n/l/Back"/></a> | <a href="#" onclick="$.galleria.next(); return false;"><xsl:value-of select="$i18n/l/Forward"/> &gt;&gt;</a>
			</p>
		</xsl:if>
	</div>
	<br clear="all"/>
</xsl:template>

<xsl:template name="head_default">
<head>
<title><xsl:call-template name="title"/></title>
	<xsl:call-template name="css"/>	
	<link href="{$ximsroot}stylesheets/gallery.css" rel="stylesheet" type="text/css" media="screen"/>
				
	<style type="text/css">
			#main_image{
				float:left;
			width: <xsl:value-of select="$img-width+20"/>px;
			height: <xsl:value-of select="$img-height +100"/>px;
			}
			#main_image img{
				width: <xsl:value-of select="$img-width"/>px;
			}	
			.scroll-pane { 
				width: <xsl:value-of select="$img-width+20"/>px; 
			}
<xsl:if test="$thumbnail-pos='left'">
	.galleria li{
		float: none !important;
	}
	.scroll-pane{
		overflow: scroll !important;
		width: 80px !important;
		height: <xsl:value-of select="$img-height + 20"/>px !important;		
	}
	.scroll-content {
		width: 60px !important;
		margin-left: 0 !important;
	}
</xsl:if>
			.scroll-content {
				width: <xsl:value-of select="$scroll-content-width"/>px;				
				}
	</style>
	<xsl:call-template name="script_head"/>      
</head>    
</xsl:template>
</xsl:stylesheet>
