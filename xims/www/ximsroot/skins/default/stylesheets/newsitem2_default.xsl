<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_default.xsl 2387 2009-12-17 14:07:58Z susannetober $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="view_common.xsl"/>
	<xsl:import href="document_default.xsl"/>

  
<xsl:param name="date_lang">
			<xsl:choose>
				<xsl:when test="$currentuilanguage = 'de-at'">de</xsl:when>
				<xsl:otherwise>en</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
	
	<xsl:template name="view-content">
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
				var date_lang = '<xsl:value-of select="$date_lang"/>';
			</xsl:with-param>
		</xsl:call-template>
	<div id="docbody"><xsl:comment/>
		<div id="content">
		<xsl:choose>
			<xsl:when test="string-length(image_id)">
				<div>
					<img src="{$goxims_content}{image_id}" width="170" height="130" alt="{image_id}" title="{image_id}" class="news-image"/>
					<div class="newsdate" id="newsdate">
						<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>
						<script type="text/javascript">
							$(document).ready(function(){
							current_date = Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
							$("#newsdate").html(current_date);
							});
						</script>
					</div>
					<div class="newslead">
						<xsl:apply-templates select="abstract"/>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="newsdate" id="newsdate">
					<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>
					<script type="text/javascript">
						$(document).ready(function(){
						current_date = Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
						$("#newsdate").html(current_date);
						});
					</script>
				</div>
				<div class="newslead">
					<xsl:apply-templates select="abstract"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<div id="body-content" style="clear:both;">
          <xsl:call-template name="pre-body-hook"/>
		  <xsl:call-template name="body"/>
		</div>
		
		<div id="validity">
			<p>
				<xsl:value-of select="$i18n/l/Valid_from"/>&#160;&#09;<span id="valid_from_datetime"><xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/></span>
				<br/>
				<xsl:value-of select="$i18n/l/Valid_to"/>&#160;&#09;<span id="valid_to_datetime"><xsl:apply-templates select="valid_to_timestamp" mode="ISO8601-MinNoT"/></span>
			</p>		
					<script type="text/javascript">
						$(document).ready(function(){
						$("#valid_from_datetime").html(Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>"));			
						$("#valid_to_datetime").html(Date.parseDate("<xsl:apply-templates select="valid_to_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>"));
						});
					</script>
		</div>
		
		<xsl:call-template name="documentlinks"/>
		</div>
	</div>
	</xsl:template>

    <!-- indirection iot ease overriding -->
    <xsl:template name="body">
      <xsl:apply-templates select="body"/>
    </xsl:template>
        
</xsl:stylesheet>

