<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: text_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:param name="pre" select="'1'"/>

<xsl:template match="body">
    <xsl:choose>
        <xsl:when test="$pre = '1'">
            <pre>
                <xsl:apply-templates/>
            </pre>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="brspace-replace">
                <xsl:with-param name="word" select="."/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="brspace-replace">
    <xsl:param name="word"/>
    <xsl:param name="foundbr" select="0"/>
    <xsl:param name="foundspace" select="0"/>
    <xsl:variable name="cr"><xsl:text>
</xsl:text></xsl:variable>
    <xsl:variable name="space"><xsl:text> </xsl:text></xsl:variable>
    <xsl:choose>
        <xsl:when test="contains($word,$cr) and ($foundbr = 0 or $foundspace = 1)">
            <xsl:if test="$foundspace = 0">
                <xsl:value-of select="substring-before($word,$cr)"/>
            </xsl:if>
            <br/>
            <xsl:call-template name="brspace-replace">
                <xsl:with-param name="word" select="substring-after($word,$cr)"/>
                <xsl:with-param name="foundbr" select="1"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains($word,$space) and ($foundspace = 0 or $foundbr = 1)">
            <xsl:value-of select="translate(substring-before($word,$cr),$space,'&#160;')"/>
            <xsl:call-template name="brspace-replace">
                <xsl:with-param name="word" select="substring-after($word,$space)"/>
                <xsl:with-param name="foundspace" select="1"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$word"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
