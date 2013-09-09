<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: siteroot_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="departmentroot_edit.xsl"/>

<xsl:template name="form-title">
	<xsl:param name="testlocation" select="false()"/>
	<div id="tr-title">
		<div class="label-std">
			<label for="input-title">
				SiteRoot URL&#160;*
			</label>
		</div>
		<input type="text" name="title" size="60" class="text" id="input-title" value="{title}">
		</input>
		<!--<xsl:text>&#160;</xsl:text>
		<a href="jjavascript:openDocWindow('SiteRootURL/Path')" class="doclink">
			<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;SiteRootURL</xsl:attribute>(?)</a>-->
	</div>
</xsl:template>
</xsl:stylesheet>
