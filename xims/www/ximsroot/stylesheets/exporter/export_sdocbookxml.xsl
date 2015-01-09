<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../common.xsl"/>
<xsl:import href="common_export.xsl"/>

<xsl:output method="xml"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <article>
        <xsl:if test="body/article/@lang != ''">
            <xsl:attribute name="lang"><xsl:value-of select="body/article/@lang"/></xsl:attribute>
        </xsl:if>
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{department_id}/ou.xml"/>
        <rdf:RDF xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:dc  = "http://purl.org/dc/elements/1.1/"
                 xmlns:dcq = "http://purl.org/dc/qualifiers/1.0/">
            <rdf:Description about="">
                <dc:title><xsl:value-of select="title"/></dc:title>
                <dc:creator><xsl:call-template name="ownerfullname"/></dc:creator>
                <dc:subject><xsl:value-of select="keywords"/></dc:subject>
                <dc:description><xsl:value-of select="abstract"/></dc:description>
                <dc:publisher><xsl:call-template name="ownerfullname"/></dc:publisher>
                <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
                <dc:date>
                    <dcq:created>
                        <rdf:Description>
                            <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                            <rdf:value><xsl:apply-templates select="creation_time" mode="ISO8601"/></rdf:value>
                        </rdf:Description>
                    </dcq:created>
                    <dcq:modified>
                        <rdf:Description>
                            <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                            <rdf:value><xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/></rdf:value>
                        </rdf:Description>
                    </dcq:modified>
                </dc:date>
                <!-- should be mime-type here -->
                <dc:format><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/name"/></dc:format>
                <!-- still to come -->
                <dc:language></dc:language>
            </rdf:Description>
        </rdf:RDF>
        <path>
           <xsl:apply-templates select="." mode="path-element"/>
        </path>
      <xsl:apply-templates select="body/article"/>
    </article>
</xsl:template>

<xsl:template match="object/body/article//*">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
