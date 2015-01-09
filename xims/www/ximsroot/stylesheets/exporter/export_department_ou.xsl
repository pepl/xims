<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="department_path"><xsl:call-template name="pathinfodepartment" /></xsl:variable>
    <xsl:variable name="department_path_nosite"><xsl:call-template name="pathinfodepartment_nosite" /></xsl:variable>

    <xsl:template match="/document">
        <ou>
            <title><xsl:apply-templates select="context/object/title"/></title>
            <xsl:if test="context/object/image_id != ''">
                <image url="{context/object/image_id}"/>
            </xsl:if>
            <stylesheet><xsl:apply-templates select="context/object/style_id"/></stylesheet>
            <css><xsl:apply-templates select="context/object/css_id"/></css>
            <script><xsl:apply-templates select="context/object/script_id"/></script>
            <xsl:if test="context/object/feed_id != ''">
              <!-- we have AxKit configured to transform Portlets into
                   RSS when .rss is added. This might be less
                   intuitive than an extra feed object-type, but on
                   the upside it seems a lot more flexible. -->
              <feed url="{context/object/feed_id}.rss"/>
            </xsl:if>
            <path>
                <xsl:choose>
                    <xsl:when test="$resolvereltositeroots = 1">
                        <xsl:value-of select="$absolute_path_nosite"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$absolute_path"/>
                    </xsl:otherwise>
                </xsl:choose>
            </path>
            <department_path>
                <xsl:choose>
                    <xsl:when test="$resolvereltositeroots = 1">
                        <xsl:value-of select="$department_path_nosite"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$department_path"/>
                    </xsl:otherwise>
                </xsl:choose>
            </department_path>
            <xsl:copy-of select="context/object/attributes"/>
            <abstract><xsl:value-of select="context/object/abstract"/></abstract>
            <xsl:apply-templates select="/document/objectlist/object"/>
        </ou>
    </xsl:template>

    <xsl:template match="objectlist/object">
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{location_path}"/>
    </xsl:template>

    <xsl:template name="pathinfodepartment">
        <xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
            <xsl:if test="department_id !=/document/context/object/department_id">
                <xsl:text>/</xsl:text>
                <xsl:value-of select="location"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="pathinfodepartment_nosite">
        <xsl:for-each select="/document/context/object/parents/object[@parent_id != 1]">
            <xsl:if test="department_id !=/document/context/object/department_id">
                <xsl:text>/</xsl:text>
                <xsl:value-of select="location"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
