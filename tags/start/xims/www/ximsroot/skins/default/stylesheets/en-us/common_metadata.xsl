<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template name="object-metadata">
    <p>
        Metadata for <xsl:value-of select="$absolute_path"/>
    </p>
    <p>
        <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
            <tr>
                <td valign="top">Title</td>
                <td><xsl:apply-templates select="title"/></td>
            </tr>
            <tr>
                <td valign="top">Abstract</td>
                <td> <xsl:apply-templates select="abstract"/></td>
            </tr>
            <tr>
                <td valign="top">Keywords</td>
                <td><xsl:apply-templates select="keywords" /></td>
            </tr>
            <tr>
                <td valign="top">Stored as</td>
                <td>
                    <xsl:value-of select="data_format/name" />-<xsl:value-of select="object_type/name" />&#160;
                    <xsl:value-of select="data_format/mime_type" />
                </td>
            </tr>
            <tr>
                <td valign="top">Size</td>
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
                Created by <xsl:call-template name="creatorfullname"/>
                at <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                <br/>
                Owned by <xsl:call-template name="ownerfullname"/>
            </td>
            <td>&#160;</td>
            <td align="right" valign="top">
                Last modified by <xsl:call-template name="modifierfullname"/>
                at <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
                <br/>
                <xsl:if test="published=1">
                    Last published by <xsl:call-template name="lastpublisherfullname"/>
                    at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                </xsl:if>
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
                Abstract:<br/>
                <xsl:apply-templates select="abstract"/>
            </xsl:if>
    </p>
</xsl:template>

</xsl:stylesheet>
