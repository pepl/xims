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

<xsl:template name="questionnaire-head-edit">
  <xsl:param name="with_wfcheck" select="'no'"/>
  <head>
    <title><xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <xsl:if test="$with_wfcheck = 'yes'">
      <xsl:call-template name="jsopenwfwindow"/>
    </xsl:if>
  </head>
</xsl:template>

<xsl:template name="tr-questionnaire-create">
  <tr>
    <td colspan="3">
      <table>
        <xsl:call-template name="questionnaire_title_edit" />
        <xsl:call-template name="questionnaire_comment_edit" />
      </table>
    </td>
  </tr>
</xsl:template>


<!-- Questionnaire template rules -->
<xsl:template name="questionnaire_title_edit">
  <tr>
    <td valign="top">
      <span class="qu-edit-title"><xsl:value-of select="$i18n/l/Title"/></span>
    </td>
    <td>
      <input type="text" tabindex="10" name="questionnaire_title" size="40" class="text" value="{body/questionnaire/title}"/>
    </td>
  </tr>
</xsl:template>

<xsl:template name="questionnaire_comment_edit">
  <xsl:variable name="position_long">
    <xsl:number level="multiple" count="question | answer" />
  </xsl:variable>
  <tr>
    <td valign="top">
      <span class="qu-edit-comment"><xsl:value-of select="$i18n_qn/l/Comment"/></span>
    </td>
    <td>
      <input type="text" tabindex="10" name="questionnaire_comment" size="40" class="text" value="{ body/questionnaire/comment}"/>
    </td>
  </tr>
</xsl:template>

</xsl:stylesheet>