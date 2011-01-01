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

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onload="document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-location-create"/>
                    <xsl:call-template name="tr-questionnaire-create"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="questionnaire-head-edit">
  <head>
    <title><xsl:value-of select="$l_create"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
    <xsl:call-template name="css"/>
    <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" type="text/css" />
  </head>
</xsl:template>

<xsl:template name="tr-questionnaire-create">
        <xsl:call-template name="questionnaire_title_edit" />
        <xsl:call-template name="questionnaire_comment_edit" />
</xsl:template>

<!-- Questionnaire template rules -->
<xsl:template name="questionnaire_title_edit">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory"><xsl:value-of select="$i18n/l/Title"/></span>
        </td>
        <td>
            <input type="text" tabindex="10" name="title" size="40" class="text" value="{body/questionnaire/title}"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
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
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Comment')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>