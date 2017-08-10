<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="chartable" select="document('simpledb_access_xmlimport_chartable.xml')/chartable" />
<xsl:variable name="tablename" select="'SimpleDB'"/>

<xsl:template match="/document/context/object">
    <xsl:variable name="now"><xsl:apply-templates select="/document/context/session/date" mode="ISO8601"/></xsl:variable>
    <dataroot xmlns:od="urn:schemas-microsoft-com:officedata" generated="{$now}">
        <xsl:apply-templates select="children/object">
            <xsl:sort select="title" order="ascending"/>
        </xsl:apply-templates>
    </dataroot>
</xsl:template>

<xsl:template match="object">
    <xsl:variable name="escaped_tablename">
        <xsl:call-template name="string-escape">
            <xsl:with-param name="string">
                <xsl:value-of select="$tablename"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <xsl:element name="{$escaped_tablename}">
        <ID><xsl:value-of select="@id"/></ID>
        <xsl:apply-templates select="member_values/member_value">
            <xsl:sort select="/document/member_properties/member_property[@id = current()/property_id]/position" order="ascending" data-type="number"/>
        </xsl:apply-templates>
    </xsl:element>
</xsl:template>

<xsl:template match="member_value">
    <xsl:variable name="property_id" select="property_id"/>
    <xsl:variable name="escaped_propertyname">
        <xsl:call-template name="string-escape">
            <xsl:with-param name="string">
                <xsl:value-of select="/document/member_properties/member_property[@id=$property_id]/name"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>
    <xsl:element name="{$escaped_propertyname}">
        <xsl:value-of select="value"/>
    </xsl:element>
</xsl:template>

<xsl:template name="string-escape">
    <xsl:param name="string" />
    <xsl:variable name="len" select="string-length($string)" />

    <xsl:if test="$len &gt; 0">
        <xsl:variable name="chr" select="substring($string, 1, 1)" />
        <xsl:variable name="rep" select="string($chartable/char[@val = $chr]/@rep)" />
        <xsl:choose>
            <xsl:when test="string($rep) = ''">
                <xsl:value-of select="$chr" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$rep" />
            </xsl:otherwise>
        </xsl:choose>

        <!-- Divide and Conquer to avoid Stack Overflow -->
        <xsl:call-template name="string-escape">
            <xsl:with-param name="string" select="substring($string, 2, $len div 2)" />
        </xsl:call-template>

        <xsl:call-template name="string-escape">
            <xsl:with-param name="string" select="substring($string, 2 + $len div 2, $len div 2)" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>


</xsl:stylesheet>
