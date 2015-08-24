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
    <xsl:import href="common_export.xsl"/>

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
            <newsitem id="{@id}">
              <xsl:if test="document_role/text()">
                <xsl:attribute name="role">
                  <xsl:value-of select="document_role"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:attribute name="date">
                <xsl:apply-templates select="valid_from_timestamp"
                                     mode="ISO8601"/>
              </xsl:attribute>        
                <!-- add user-metadata here? -->
                <title>
                    <xsl:value-of select="title"/>
                </title>
                <lead>
                    <xsl:apply-templates select="abstract"/>
                </lead>
                <story>
                    <xsl:apply-templates select="body"/>
                </story>
                <path>
                  <xsl:apply-templates select="." mode="path-element"/>
                </path>
                <keywords><xsl:value-of select="keywords"/></keywords>
                <image url="{image_id/location_path}" alt="{image_id/title}" longdesc="{image_id/abstract}"/>
                <last_publication_timestamp><xsl:apply-templates select="last_publication_timestamp"/></last_publication_timestamp>
                <last_modification_timestamp><xsl:apply-templates select="last_modification_timestamp"/></last_modification_timestamp>
                <created_by_firstname><xsl:apply-templates select="created_by_firstname"/></created_by_firstname>
                <created_by_middlename><xsl:apply-templates select="created_by_middlename"/></created_by_middlename>
                <created_by_lastname><xsl:apply-templates select="created_by_lastname"/></created_by_lastname>
                <owned_by_firstname><xsl:apply-templates select="owned_by_firstname"/></owned_by_firstname>
                <owned_by_middlename><xsl:apply-templates select="owned_by_middlename"/></owned_by_middlename>
                <owned_by_lastname><xsl:apply-templates select="owned_by_lastname"/></owned_by_lastname>
                <links>
                    <xsl:apply-templates select="children/object"/>
                    <xsl:if test="attributes/gen-social-bookmarks='1'">
                      <gen-social-bookmarks/>
                    </xsl:if>
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
