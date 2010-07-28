<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: export_galleryimage.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml"/>
	<xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>

                <xsl:apply-templates select="children"/>

    </xsl:template>


<xsl:template match="/document/context/object/children">
	<div class="images">
				<xsl:apply-templates select="object"/>
	</div>

</xsl:template>

<xsl:template match="/document/context/object/children/object">
<xsl:if test="object_type_id=3 and published=1">
	<img src="{location}">
	<xsl:attribute name="alt"><xsl:value-of select="substring(abstract,0,200)"/></xsl:attribute>
	<xsl:attribute name="title"><xsl:value-of select="title"/></xsl:attribute>
	</img>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
