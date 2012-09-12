<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xml_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="view_common.xsl"/>

<xsl:variable name="sfe"><xsl:if test="/document/context/object/schema_id != '' and contains(/document/context/object/attributes, 'sfe=1')">1</xsl:if></xsl:variable>

<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:template name="view-content">
	<div id="docbody">
		<pre>
				<xsl:apply-templates select="body"/>
		</pre>
	</div>
</xsl:template>

</xsl:stylesheet>
