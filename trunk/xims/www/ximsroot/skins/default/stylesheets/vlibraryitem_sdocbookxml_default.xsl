<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="sdocbookxml_default.xsl"/>
<xsl:output method="xml" encoding="utf-8"
    media-type="text/html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    indent="no"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <base href="{$xims_box}{$goxims_content}{$absolute_path}/"/>
        <body>
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td bgcolor="#ffffff">
                        <ul style="padding: 5px; background:#cccccc; border: 1px solid">
                            <li><xsl:apply-templates select="authorgroup"/></li>
                            <li><xsl:apply-templates select="subjectset"/></li>
                            <li><xsl:apply-templates select="keywordset"/></li>
                            <li><xsl:apply-templates select="publicationset"/></li>
                            <li>Mediatype: <xsl:apply-templates select="meta/mediatype"/></li>
                            <li>Legalnotice: <xsl:apply-templates select="meta/legalnotice"/></li>
                            <xsl:if test="meta/bibliosource != ''">
                                <li>Releaseinfo: <xsl:apply-templates select="meta/bibliosource"/></li>
                            </xsl:if>
                        </ul>
                        <h1><xsl:value-of select="title"/></h1>
                        <xsl:choose>
                            <xsl:when test="$section > 0 and $section-view='true'">
                                <xsl:apply-templates select="$docbookroot" mode="section-view"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$docbookroot"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td><!-- end #ffffff -->
                </tr>
            </table>

            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>

        </body>
    </html>
</xsl:template>

<xsl:template match="keywordset">
    Keywords:
        <xsl:apply-templates select="keyword"/>
</xsl:template>

<xsl:template match="subjectset">
    Subjects:
        <xsl:apply-templates select="subject"/>
</xsl:template>

<xsl:template match="publicationset">
    Published in:
        <xsl:apply-templates select="publication[name != '']"/>
</xsl:template>


<xsl:template match="keyword|subject">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?subject=1;subject_id={id}"><xsl:value-of select="name"/></a><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="authorgroup">
    Authors:
        <xsl:apply-templates select="author"/>
</xsl:template>

<xsl:template match="author">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?author=1;author_id={id}"><xsl:value-of select="firstname"/><xsl:text> </xsl:text><xsl:value-of select="lastname"/></a><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="publication">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?publication=1;publication_id={id}"><xsl:value-of select="name"/><xsl:text> (</xsl:text><xsl:value-of select="volume"/>)</a>
    <xsl:if test="isbn != ''">
        ISBN: <xsl:value-of select="isbn"/>
    </xsl:if>
    <xsl:if test="issn != ''">
        ISSN: <xsl:value-of select="issn"/>
    </xsl:if>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="ulink">
    <a href="{@url}"><xsl:value-of select="text()"/></a>
</xsl:template>

</xsl:stylesheet>
