<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

  <xsl:template match="questionnaire">
			<form action="">
				<xsl:call-template name="questionnaire_title" />
				<xsl:call-template name="questionnaire_info" />
				<xsl:call-template name="questionnaire_statistics" />
				<xsl:call-template name="questionnaire_download" />
			</form>
</xsl:template>

<xsl:template name="questionnaire_info">
<div style="border: solid 1 black">
<xsl:value-of select="$i18n_qn/l/Question_number" />: <xsl:value-of select="count(question)" /><br />
<b><xsl:value-of select="$i18n_qn/l/TAN_lists_assigned" />:</b><br />
<xsl:for-each select="tanlist">
	<xsl:value-of select="." /><br />
</xsl:for-each>
</div>
</xsl:template>

<xsl:template name="questionnaire_statistics">
<div style="border: solid 1 black">
  <xsl:value-of select="$i18n_qn/l/Questionnaires_answered_number" />: <xsl:value-of select="@total_answered" /><br />
  <xsl:value-of select="$i18n_qn/l/Questionnaires_valid_number" />: <xsl:value-of select="@valid_answered" /></div>
</xsl:template>

<xsl:template name="questionnaire_download">
<xsl:if test="@total_answered > 0">
	Download <xsl:value-of select="$i18n_qn/l/results" /><a class="text" type="submit" target="_blank" href="?download_results=excel">HTML</a>
</xsl:if>
</xsl:template>

<xsl:template name="questionnaire_title">
	<h1><xsl:value-of select="title" /></h1>
</xsl:template>

<xsl:template name="questionnaire_comment">
	<xsl:if test="comment!=''"><pre><xsl:value-of select="comment" /></pre></xsl:if>
</xsl:template>

</xsl:stylesheet>

