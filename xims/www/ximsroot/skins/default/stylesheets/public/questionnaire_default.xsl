<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: questionnaire_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../questionnaire_default.xsl"/>
<xsl:import href="common.xsl"/>

<xsl:output method="xml" 
            encoding="utf-8"
            media-type="text/html" 
            doctype-system="about:legacy-compat" 
            indent="no"
            omit-xml-declaration="yes"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <xsl:call-template name="header"/>
        <div id="leftcontent">
            <xsl:call-template name="stdlinks"/>
            <xsl:call-template name="departmentlinks"/>
            <xsl:call-template name="documentlinks"/>
        </div>
        <div id="centercontent">
            <xsl:comment>/UdmComment</xsl:comment>
            <!-- Display Error message if it exists -->
            <xsl:if test="body/questionnaire/error_message != ''">
                <p class="error_msg"><strong>Error:</strong><br /><xsl:value-of select="body/questionnaire/error_message" /></p>
            </xsl:if>
            <xsl:apply-templates select="body"/>
            <div id="footer">
                <span class="left">
                    <xsl:call-template name="copyfooter"/>
                </span>
                <span class="right">
                    <xsl:call-template name="powerdbyfooter"/>
                </span>
            </div>
        </div>
        <xsl:call-template name="script_bottom"/>
      </body>
</html>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <xsl:call-template name="meta"/>
        <title><xsl:call-template name="title"/></title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" style="text/css"/>
    </head>
</xsl:template>


<!-- Questionnaire specific templates -->

<xsl:template match="questionnaire">
<xsl:variable name="question_count" select="count(question)" />
<xsl:variable name="tan" select="tan" />
<xsl:variable name="current_question" select="current_question" />
    <xsl:choose>
        <xsl:when test="$current_question > $question_count">
            <div align="center">
                <xsl:call-template name="questionnaire_title" />
                <xsl:call-template name="questionnaire_exit" /><br />
                <!--<input type="button" value="{$i18n_qn/l/close_window}" onclick="window.close();" />-->
            </div>
        </xsl:when>
        <xsl:when test="$current_question >= 1">
            <form action="?q={$current_question + 1}" method="post">
                <xsl:call-template name="questionnaire_title" />
                <input type="hidden" name="tan" value="{$tan}" />
                <input type="hidden" name="q" value="{$current_question + 1}" />
                <input type="hidden" name="docid" value="{/document/context/object/@document_id}" />
                <xsl:apply-templates select="question[$current_question + 0]" />
                <input type="submit" name="answer" value="{$i18n_qn/l/next} >" />
            </form>
            <xsl:if test="/document/context/object/body/questionnaire/options/mandatoryanswers = '1'">
                <p><xsl:value-of select="$i18n_qn/l/Mandatory_Answers"/>!</p>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <div align="center">
                <xsl:call-template name="questionnaire_title" />
                <xsl:call-template name="questionnaire_intro" />
                <p>
                    <form action="?q=1" method="post">
                        <input type="hidden" name="q" value="1" />
                        <input type="hidden" name="docid" value="{/document/context/object/@document_id}" />
                        <xsl:if test="count(tanlist) > 0">
                            TAN:<input type="text" name="tan" /><br />
                        </xsl:if>
                        <input type="submit" value="{$i18n_qn/l/start}"/>
                    </form>
                </p>
            </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Questionnaire template rules -->
<xsl:template name="questionnaire_title">
    <h2><xsl:value-of select="title" /></h2>
</xsl:template>

<xsl:template name="questionnaire_intro">
    <xsl:if test="intro!=''"><span class="questionnaire-intro-public"><xsl:value-of select="intro" /></span></xsl:if>
</xsl:template>

<xsl:template name="questionnaire_exit">
    <xsl:choose>
        <xsl:when test="exit!=''"><span class="questionnaire-intro-public"><xsl:value-of select="exit" /></span></xsl:when>
        <xsl:otherwise><span class="questionnaire-intro-public"><xsl:value-of select="$i18n_qn/l/Default_Thank_You"/></span></xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
