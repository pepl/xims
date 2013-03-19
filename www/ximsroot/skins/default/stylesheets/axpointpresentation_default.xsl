<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: axpointpresentation_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="view_common.xsl"/>

<xsl:param name="msie" select="0"/>
<xsl:param name="ap-pres">true</xsl:param>

<xsl:template name="view-content">
	<div id="docbody"><xsl:comment/>
	 <xsl:choose>
			<xsl:when test="$msie=0">
					<xsl:apply-templates select="body"/>
			</xsl:when>
			<xsl:otherwise>
				<pre>
					<xsl:apply-templates select="body"/>
				</pre>
			</xsl:otherwise>
	</xsl:choose>
							</div>
</xsl:template>

<xsl:template name="axpointpresentation-options">
    <tr>
        <td colspan="3">
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?download_pdf=1"><xsl:value-of select="$i18n/l/Download_PDF"/></a>
            (<a href="{$xims_box}{$goxims_content}{$absolute_path}?download_pdf=1;printmode=1"><xsl:value-of select="$i18n/l/print_version"/></a>)
        </td>
    </tr>
</xsl:template>

<xsl:template match="background|email|metadata|organisation|point|slide|slideset|slideshow|speaker|subtitle|text|logo|source-code|source_code|i|b|colour|color|table|row|col|line|rect|circle|ellipse">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<!-- display images -->
<xsl:template match="image">
    <img xmlns:xlink="http://www.w3.org/1999/xlink" src="{text()|@xlink:href}" alt="{text()|@xlink:href}"/>
</xsl:template>

<!-- rename the two elements conflicting with HTML to slide* -->
<xsl:template match="link">
    <slidelink>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </slidelink>
</xsl:template>

<xsl:template match="title">
    <slidetitle>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </slidetitle>
</xsl:template>

</xsl:stylesheet>
