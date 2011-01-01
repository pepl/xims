<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template match="/document/context/object">
    <xsl:variable name="title">Questionnaire '<xsl:value-of select="./title" />' Result Data</xsl:variable>
    <html>
        <head>
            <title><xsl:value-of select="$title"/></title>
        </head>
        <body>
            <table border="1">
                <xsl:for-each select="body/questionnaire/question">
                    <xsl:call-template name="top_question"/>
                </xsl:for-each>
            </table>
        </body>
    </html>
</xsl:template>

<xsl:template match="question" name="top_question">
    <tr>
        <td>
            <strong><xsl:number level="multiple" count="question | answer" /></strong>&#160;Q
        </td>
        <td colspan="2">
            <strong><xsl:value-of select="./title" /></strong>
        </td>
    </tr>
    <xsl:apply-templates select="child::question | child::answer"/>
</xsl:template>

<xsl:template match="answer">
    <xsl:for-each select="./title">
        <tr>
            <td>
                <xsl:number level="multiple" count="question | answer" />&#160;A
            </td>
            <td>
                <xsl:value-of select="." />
            </td>
            <td>
                <xsl:value-of select="@count" />
            </td>
        </tr>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>