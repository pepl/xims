<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="exslt date"
                >
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/document">
        <xsl:variable name="sortedobjects">
            <xsl:for-each select="/document/context/object/children/object">
            <xsl:sort select="concat(valid_from_timestamp/year,valid_from_timestamp/month,valid_from_timestamp/day,valid_from_timestamp/hour,valid_from_timestamp/minute,valid_from_timestamp/second)" order="descending"/>
            <xsl:sort select="concat(creation_timestamp/year,creation_timestamp/month,creation_timestamp/day,creation_timestamp/hour,creation_timestamp/minute,creation_timestamp/second)" order="descending"/>
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
            <xsl:sort select="position" order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="@*|*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>

        <portlet id="{context/object/@id}">
            <title><xsl:value-of select="context/object/title"/></title>
            <baselocation><xsl:value-of select="context/object/location_path"/></baselocation>
            <!--<xsl:apply-templates select="context/object/children/object"/>-->
            <xsl:apply-templates select="exslt:node-set($sortedobjects)/object"/>
        </portlet>
    </xsl:template>

    <xsl:template match="/object">
        <portlet-item id="{@id}" parent_id="{@parent_id}" document_id="{@document_id}">
            <xsl:apply-templates/>
        </portlet-item>
    </xsl:template>

    <xsl:template match="/object//*">
        <xsl:if test="name()!='document_id' and name()!='id'">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
