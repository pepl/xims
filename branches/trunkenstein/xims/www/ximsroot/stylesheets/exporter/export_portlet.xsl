<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="exslt date"
                >

    <xsl:import href="../common.xsl"/>
    <xsl:import href="common_export.xsl"/>

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="/document/context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <xsl:variable name="sortedobjects">
            <xsl:for-each select="children/object">
                <xsl:sort select="concat(valid_from_timestamp/year,valid_from_timestamp/month,valid_from_timestamp/day,valid_from_timestamp/hour,valid_from_timestamp/minute,valid_from_timestamp/second)" order="descending"/>
                <xsl:sort select="concat(creation_timestamp/year,creation_timestamp/month,creation_timestamp/day,creation_timestamp/hour,creation_timestamp/minute,creation_timestamp/second)" order="descending"/>
                <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
                <xsl:sort select="position" order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="@*|*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>

        <portlet id="{@id}" parent_id="{@parent_id}" document_id="{@document_id}">
	    <path>
              <xsl:apply-templates select="." mode="path-element"/>
            </path>
            <departmentinfo><xsl:value-of select="department_id"/>/ou.xml</departmentinfo>
            <location_path><xsl:value-of select="$absolute_path_nosite"/></location_path>
            <title><xsl:value-of select="title"/></title>
            <abstract><xsl:apply-templates select="abstract"/></abstract>
            <valid_from_timestamp><xsl:apply-templates select="valid_from_timestamp"/></valid_from_timestamp>
            <last_publication_timestamp><xsl:apply-templates select="last_publication_timestamp"/></last_publication_timestamp>
            <created_by_firstname><xsl:apply-templates select="created_by_firstname"/></created_by_firstname>
            <created_by_middlename><xsl:apply-templates select="created_by_middlename"/></created_by_middlename>
            <created_by_lastname><xsl:apply-templates select="created_by_lastname"/></created_by_lastname>
            <owned_by_firstname><xsl:apply-templates select="owned_by_firstname"/></owned_by_firstname>
            <owned_by_middlename><xsl:apply-templates select="owned_by_middlename"/></owned_by_middlename>
            <owned_by_lastname><xsl:apply-templates select="owned_by_lastname"/></owned_by_lastname>
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

    <xsl:template match="valid_from_timestamp/*|last_publication_timestamp/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
