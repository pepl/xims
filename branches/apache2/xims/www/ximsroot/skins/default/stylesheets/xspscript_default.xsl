<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xspscript_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="view_common.xsl"/>
	<xsl:import href="xspscript_common.xsl"/>
	
	<xsl:template name="view-content">
		<div id="docbody">
							<pre>
								<xsl:apply-templates select="body"/>
							</pre>
						</div>
						<div>
							<xsl:call-template name="processxsp_switcher"/>
						</div>
	</xsl:template>
	
	<xsl:param name="process_xsp" select="'0'"/>
	
	<xsl:template name="processxsp_switcher">
		<xsl:choose>
			<xsl:when test="$process_xsp = '0'">
				<a href="{$xims_box}{$goxims_content}{$absolute_path}?process_xsp=1"><xsl:value-of select="$i18n/l/Show_XSP_processed"/></a>
			</xsl:when>
			<xsl:otherwise>
				<a href="{$xims_box}{$goxims_content}{$absolute_path}?do_not_process_xsp=1"><xsl:value-of select="$i18n/l/Not_Show_XSP_processed"/></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
