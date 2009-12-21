<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: questionnaire_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default">
			<xsl:with-param name="mode">create</xsl:with-param>
    </xsl:call-template>
    <body onload="document.eform['abstract'].value='';">
      	<xsl:call-template name="header">
					<xsl:with-param name="create">true</xsl:with-param>
      	</xsl:call-template>
        <div class="edit">
          <div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-create"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" id="create-edit-form">
                <input type="hidden" name="objtype" value="{$objtype}"/>

									<xsl:call-template name="tr-locationtitle-create"/>
                    <!--<xsl:call-template name="tr-location-create"/>
                    --><!--<xsl:call-template name="tr-questionnaire-create"/>--><!--
                     <xsl:call-template name="questionnaire_title_edit" />-->
										<xsl:call-template name="questionnaire_comment_edit" />
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="grantowneronly"/>

                <xsl:call-template name="saveaction"/>
            </form>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
        </div>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<!--<xsl:template name="questionnaire-head-edit">
  <head>
    <title><xsl:value-of select="$l_create"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
    <xsl:call-template name="css"/>
    <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" type="text/css" />
  </head>
</xsl:template>-->

<!--<xsl:template name="tr-questionnaire-create">
    <tr>
        <xsl:call-template name="questionnaire_title_edit" />
        <xsl:call-template name="questionnaire_comment_edit" />
    </tr>
</xsl:template>-->

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
    <div id="tr-qu-comment">
        <div id="label-qu-comment">
        <label for="input-qu-comment">
          <span class="qu-edit-comment"><xsl:value-of select="$i18n_qn/l/Comment"/></span>
          </label>
        </div>
            <input name="questionnaire_comment" size="60" class="text" value="{ body/questionnaire/comment}" id="input-qu-comment"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Comment')" class="doclink">(?)</a>
        </div>
</xsl:template>

</xsl:stylesheet>