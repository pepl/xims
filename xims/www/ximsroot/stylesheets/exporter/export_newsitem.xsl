<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
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
        <newsitems>
            <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{department_id}/ou.xml"/>
            <newsitem id="">
                <xsl:attribute name="date"><xsl:apply-templates select="last_publication_timestamp" mode="ISO8601"/></xsl:attribute>
                <title>
                    <xsl:value-of select="title"/>
                </title>
                <lead>
                    <xsl:apply-templates select="abstract"/>
                </lead>
                <story>
                    <xsl:apply-templates select="body"/>
                </story>

                <!--
                the image is stored as a id and will be resolved as a path not a object.
                to get the title information for the image is therefore quite difficult
                -->
                <image url="{image_id}" alt="..." />
                <links>
                    <xsl:apply-templates select="children/object"/>
                </links>
            </newsitem>
        </newsitems>
    </xsl:template>

    <xsl:template match="object/body//*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="children/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <xsl:variable name="objecttype">
            <xsl:value-of select="object_type_id"/>
        </xsl:variable>
        <!-- this should be switched to xlink spec -->
        <xsl:choose>
            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                <link type="locator" title="{title}" href="{location}"/>
            </xsl:when>
            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
                <link type="locator" title="{title}" href="{symname_to_doc_id}" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
