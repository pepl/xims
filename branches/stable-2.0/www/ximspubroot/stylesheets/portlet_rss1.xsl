<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times" xmlns:exslt="http://exslt.org/common"
    extension-element-prefixes="exslt date">

    <xsl:output method="xml"/>

    <xsl:variable name="sorteditems">
        <xsl:for-each select="/portlet/portlet-item">
            <xsl:sort
                select="concat(valid_from_timestamp/year,valid_from_timestamp/month,valid_from_timestamp/day,valid_from_timestamp/hour,valid_from_timestamp/minute,valid_from_timestamp/second)"
                order="descending"/>
            <xsl:sort
                select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)"
                order="descending"/>
            <xsl:sort select="position" order="ascending"/>
            <xsl:sort
                select="concat(creation_timestamp/year,creation_timestamp/month,creation_timestamp/day,creation_timestamp/hour,creation_timestamp/minute,creation_timestamp/second)"
                order="descending"/>
            <xsl:copy>
                <xsl:copy-of select="@*|*"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <xsl:param name="request.headers.host"/>

    <xsl:template match="/portlet">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/">
            <channel rdf:about="http://xims.info/">
                <title>
                    <xsl:value-of select="title"/>
                </title>
                <link>http://xims.info/</link>
                <description>
                    <xsl:apply-templates select="abstract"/>
                </description>
                <image rdf:about="http://xims.info/images/powered_by_xims.gif">
                    <title>XIMS Web Content Management System</title>
                    <url>http://xims.info/images/powered_by_xims.gif</url>
                    <link>http://xims.info/</link>
                </image>
                <xsl:call-template name="dcmeta"/>
                <items>
                    <rdf:Seq>
                        <xsl:apply-templates select="exslt:node-set($sorteditems)/portlet-item"
                            mode="seq"/>
                    </rdf:Seq>
                </items>
            </channel>
            <xsl:apply-templates select="exslt:node-set($sorteditems)/portlet-item" mode="item"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="portlet-item" mode="seq">
        <rdf:li xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <xsl:attribute name="rdf:resource">
                <xsl:if test="not( contains(location,'://'))">http://xims.info</xsl:if><xsl:value-of select="location_path"/>
            </xsl:attribute>
        </rdf:li>
    </xsl:template>

    <xsl:template match="portlet-item" mode="item">
        <item xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <xsl:attribute name="rdf:about">
                <xsl:if test="not( contains(location,'://'))">http://xims.info</xsl:if><xsl:value-of select="location_path"/>
            </xsl:attribute>
            <title>
                <xsl:value-of select="title"/>
            </title>
            <link><xsl:if test="not( contains(location,'://'))">http://xims.info</xsl:if><xsl:value-of select="location_path"/>
            </link>
            <dc:description xmlns:dc="http://purl.org/dc/elements/1.1/">
                <xsl:value-of select="abstract"/>
            </dc:description>
            <xsl:call-template name="dcmeta"/>
        </item>
    </xsl:template>

    <xsl:template name="dcmeta">
        <dc:publisher xmlns:dc="http://purl.org/dc/elements/1.1/">The XIMS Project</dc:publisher>
        <xsl:if test="owned_by_lastname != ''">
            <dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/"><xsl:value-of select="concat(owned_by_firstname, ' ',owned_by_lastname)"/></dc:creator>                    
        </xsl:if>
        <dc:rights xmlns:dc="http://purl.org/dc/elements/1.1/">Copyright © <xsl:value-of select="date:year()"/> The XIMS Project</dc:rights>
        <dc:date xmlns:dc="http://purl.org/dc/elements/1.1/"><xsl:apply-templates select="last_publication_timestamp" mode="ISO8601"/></dc:date>
    </xsl:template>

    <xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp" mode="ISO8601">
        <xsl:value-of select="./year"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="./month"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="./day"/>
        <xsl:text>T</xsl:text>
        <xsl:value-of select="./hour"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./minute"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./second"/>
    </xsl:template>

</xsl:stylesheet>
