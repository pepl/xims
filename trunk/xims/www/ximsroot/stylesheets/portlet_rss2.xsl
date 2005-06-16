<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exslt="http://exslt.org/common" 
                extension-element-prefixes="exslt date"
                >

<xsl:output method="xml"/>

<xsl:variable name="sorteditems">
    <xsl:for-each select="/portlet/portlet-item">
        <xsl:sort select="concat(valid_from_timestamp/year,valid_from_timestamp/month,valid_from_timestamp/day,valid_from_timestamp/hour,valid_from_timestamp/minute,valid_from_timestamp/second)" order="descending"/>
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
            <xsl:sort select="position" order="ascending"/>
            <xsl:sort select="concat(creation_timestamp/year,creation_timestamp/month,creation_timestamp/day,creation_timestamp/hour,creation_timestamp/minute,creation_timestamp/second)" order="descending"/>
        <xsl:copy>
            <xsl:copy-of select="@*|*"/>
        </xsl:copy>
    </xsl:for-each>
</xsl:variable>

<xsl:param name="request.headers.host"/>

<xsl:template match="/portlet">
    <rss version="2.0">
        <channel>
            <title><xsl:value-of select="title"/></title>
            <link>http://xims.info/</link>
            <description><xsl:value-of select="abstract"/></description>
            <language>en</language>
            <pubDate><xsl:apply-templates select="valid_from_timestamp" mode="RFC822" /></pubDate>
            <lastBuildDate><xsl:apply-templates select="last_publication_timestamp" mode="RFC822" /></lastBuildDate>
            <copyright>Copyright © <xsl:value-of select="date:year()"/> The XIMS Project</copyright>
            <managingEditor>webmaster@xims.info</managingEditor>
            <webMaster>webmaster@xims.info</webMaster>
            <image>
                <title>XIMS Web Content Management System</title>
                <url>http://xims.info/images/powered_by_xims.gif</url>
                <link>http://xims.info/</link>
            </image>
            <generator>XIMS</generator>
            <xsl:apply-templates select="exslt:node-set($sorteditems)/portlet-item"/>
        </channel>
    </rss>
</xsl:template>

<xsl:template match="portlet-item">
    <item>
        <title><xsl:value-of select="title"/></title>
        <link>http://www2.uibk.ac.at<xsl:value-of select="location_path"/></link>
        <description><xsl:value-of select="abstract"/></description>
        <pubDate><xsl:apply-templates select="valid_from_timestamp" mode="RFC822" /></pubDate>
    </item>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp" mode="RFC822">
    <xsl:variable name="datetime">
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
        <!--<xsl:value-of select="./tzd"/>-->
    </xsl:variable>
    <xsl:value-of select="substring(date:day-name($datetime),1,3)"/>,
    <xsl:text> </xsl:text>
    <xsl:value-of select="./day"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="date:month-name($datetime)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./year"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./hour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./second"/>
    <xsl:text> </xsl:text>
    +0200</xsl:template>

</xsl:stylesheet>