<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="object-metadata">
    <p>
        <xsl:value-of select="$i18n/l/Metadata"/> <xsl:value-of select="$absolute_path"/>
    </p>
    <p>
        <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
            <tr>
                <td valign="top"><xsl:value-of select="$i18n/l/Title"/></td>
                <td><xsl:apply-templates select="title"/></td>
            </tr>
            <tr>
                <td valign="top"><xsl:value-of select="$i18n/l/abstract"/></td>
                <td> <xsl:apply-templates select="abstract"/></td>
            </tr>
            <tr>
                <td valign="top"><xsl:value-of select="$i18n/l/keywords"/></td>
                <td><xsl:apply-templates select="keywords" /></td>
            </tr>
            <tr>
                <td valign="top"><xsl:value-of select="$i18n/l/Dataformat"/></td>
                <td>
                    <xsl:value-of select="data_format/name" />-<xsl:value-of select="object_type/name" />&#160;
                    <xsl:value-of select="data_format/mime_type" />
                </td>
            </tr>
            <tr>
                <td valign="top"><xsl:value-of select="$i18n/l/Size"/></td>
                <td>
                    <xsl:value-of select="format-number(lob_length , ',###,##0')"/>&#160;Bytes
                </td>
            </tr>
        </table>
    </p>
</xsl:template>

<xsl:template name="user-metadata">
        <tr>
            <td valign="top">
                <div>
                    <xsl:value-of select="$i18n/l/Created_by"/>&#160;<xsl:call-template name="creatorfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </div>
                <div>
                    <xsl:value-of select="$i18n/l/Owned_by"/>&#160;<xsl:call-template name="ownerfullname"/>
                </div>
            </td>
            <td>&#160;</td>
            <td align="right" valign="top">
                <div>
                    <xsl:value-of select="$i18n/l/Last_modified_by"/>&#160;<xsl:call-template name="modifierfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
                </div>
                <div>
                    <xsl:if test="published=1">
                        <xsl:value-of select="$i18n/l/Last_published_by"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                    </xsl:if>
                </div>
            </td>
        </tr>
</xsl:template>

<xsl:template name="document-metadata">
    <p class="documentquote">
            Document:
            <!-- created_by should be replaced by owned_by! -->
            <xsl:call-template name="ownerfullname"/>,
            <xsl:value-of select="title"/>,
            [<xsl:value-of select="concat($goxims_content,$absolute_path)"/>],
            <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
           <br/>
           <xsl:if test="abstract != '&#160;'">
                <xsl:value-of select="$i18n/l/Abstract"/>:<br/>
                <xsl:apply-templates select="abstract"/>
            </xsl:if>
    </p>
</xsl:template>

</xsl:stylesheet>
