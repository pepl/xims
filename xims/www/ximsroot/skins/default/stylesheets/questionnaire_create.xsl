<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: questionnaire_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="create_common.xsl"/>

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:call-template name="questionnaire_comment_edit" />
	<xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-grant"/>
</xsl:template>

<!-- Questionnaire template rules -->
<xsl:template name="questionnaire_title_edit">
    <div id="tr-title">
        <div id="label-title">
            <label for="input-title">
            <span class="compulsory"><xsl:value-of select="$i18n/l/Title"/></span>
            </label>
            </div>
            <input type="text" name="questionnaire_title" size="60" class="text" value="{body/questionnaire/title}" id="input-title"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
        </div>
</xsl:template>

<xsl:template name="questionnaire_comment_edit">
  <xsl:variable name="position_long">
    <xsl:number level="multiple" count="question | answer" />
  </xsl:variable>
  <div class="form-div block">
    <div id="tr-qu-comment">
        <div class="label-std">
        <label for="input-qu-comment">
          <span class="qu-edit-comment"><xsl:value-of select="$i18n_qn/l/Comment"/></span>
          </label>
        </div>
            <input name="questionnaire_comment" size="60" class="text" value="{ body/questionnaire/comment}" id="input-qu-comment"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Comment')" class="doclink">(?)</a>
        </div>
  </div>
</xsl:template>

<!-- as Questionnaire can not be reedited when published, automatic publishing makes no sense-->
<xsl:template name="publish-on-save"/>

</xsl:stylesheet>
