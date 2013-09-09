<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Using encoding="UTF-8" here generates literal utf-8 characters, not using it, generates numeric code-point entities -->
<xsl:output method="xml" doctype-public="-//OASIS//DTD DocBook XML V4.2//EN" doctype-system="http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd" />

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <book>
        <bookinfo>
            <xsl:copy-of select="title"/>
            <subtitle><xsl:value-of select="meta/subtitle"/></subtitle>
            <titleabbrev><xsl:value-of select="substring-before(location,'.')"/></titleabbrev>

            <xsl:if test="count(abstract/*) > 0">
                <simpara><xsl:copy-of select="abstract"/></simpara>
            </xsl:if>

            <legalnotice><simpara><xsl:value-of select="meta/legalnotice"/></simpara></legalnotice>
            <authorgroup>
                <xsl:apply-templates select="authorgroup/author"/>
            </authorgroup>
            <keywordset>
                <xsl:apply-templates select="keywordset/keyword"/>
            </keywordset>
            <subjectset>
                <xsl:apply-templates select="subjectset/subject"/>
            </subjectset>
            <biblioset relation="{meta/mediatype}">
                <bibliosource><xsl:value-of select="meta/bibliosource"/></bibliosource>
                <title><xsl:value-of select="publicationset/publication/name"/></title>
                <issn><xsl:value-of select="publicationset/publication/issn"/></issn>
                <isbn><xsl:value-of select="publicationset/publication/issn"/></isbn>
                <issuenum><xsl:value-of select="publicationset/publication/volume"/></issuenum>
            </biblioset>
        </bookinfo>
      <xsl:apply-templates select="body/book"/>
    </book>
</xsl:template>

<xsl:template match="/document/context/object/body/book//*">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template match="author[object_type!='1']">
    <author>
        <firstname><xsl:value-of select="firstname"/></firstname>
        <othername><xsl:value-of select="middlename"/></othername>
        <surname><xsl:value-of select="lastname"/></surname>
    </author>
</xsl:template>

<xsl:template match="author[object_type='1']">
    <corpauthor><xsl:value-of select="lastname"/></corpauthor>
</xsl:template>

<xsl:template match="keyword">
    <keyword><xsl:value-of select="name"/></keyword>
</xsl:template>

<xsl:template match="subject">
    <subject><subjectterm><xsl:value-of select="name"/></subjectterm></subject>
</xsl:template>

</xsl:stylesheet>
