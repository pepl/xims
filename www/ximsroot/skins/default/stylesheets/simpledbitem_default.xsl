<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: simpledbitem_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="view_common.xsl"/>
<xsl:import href="simpledb_common.xsl"/>

<xsl:param name="simpledb">true</xsl:param>

<xsl:template name="view-content">
<div id="docbody"><xsl:comment/>
					<p><xsl:comment/><xsl:apply-templates select="abstract"/></p>
							<xsl:apply-templates select="member_values/member_value">
									<xsl:sort select="/document/member_properties/member_property[@id = current()/property_id]/position" order="ascending" data-type="number"/>
							</xsl:apply-templates>
				</div>
</xsl:template>

<xsl:template match="member_value">
    <xsl:variable name="property_id" select="property_id"/>
    <p>
            <xsl:value-of select="/document/member_properties/member_property[@id=$property_id]/name"/>:
            <xsl:value-of select="value"/>
    </p>
</xsl:template>

</xsl:stylesheet>
