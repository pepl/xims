<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: questionnaire_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="view_common.xsl"/>

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:param name="show_questions" select="'none'" />
<xsl:param name="questionnaire" select="true()"/>

<xsl:template name="view-content">
		<div id="docbody">
							<xsl:apply-templates select="body"/>
		</div>
</xsl:template>

<xsl:template match="questionnaire">
    <xsl:call-template name="questionnaire_title" />
    <div id="properties">
			<xsl:call-template name="questionnaire_info" />
			<xsl:call-template name="questionnaire_statistics" />
			<xsl:call-template name="questionnaire_download" />
    </div>
    <xsl:choose>
    <xsl:when test="$show_questions =  'none'">
		<a href="?show_questions=top" class="button" type="submit"><xsl:value-of select="$i18n_qn/l/show_questions" /></a>
    </xsl:when>
    <xsl:when test="$show_questions =  'top'">
		<a href="?show_questions=none" class="button" type="submit"><xsl:value-of select="$i18n_qn/l/hide_questions" /></a><br/>
		<br/>
		<h2><xsl:value-of select="$i18n_qn/l/Questions" /></h2>
		<xsl:call-template name="question_title" />
		<xsl:call-template name="comment" />
		<xsl:apply-templates select="child::question"/>
    </xsl:when>
</xsl:choose>
    
</xsl:template>

<xsl:template name="questionnaire_info">
    <p>
        <xsl:value-of select="$i18n_qn/l/Question_number" />: <xsl:value-of select="count(question)" /><br />
        <xsl:if test="count(tanlist) &gt; 0">
            <strong><xsl:value-of select="$i18n_qn/l/TAN_lists_assigned" />:</strong><br />
            <xsl:for-each select="tanlist">
                <xsl:call-template name="cttobject.options.spacer"/><xsl:value-of select="." /><br />
            </xsl:for-each>
        </xsl:if>
    </p>
</xsl:template>

<xsl:template name="questionnaire_statistics">
    <p>
        <xsl:value-of select="$i18n_qn/l/Questionnaires_answered_number" />: <xsl:value-of select="@total_answered" /><br/>
        <xsl:value-of select="$i18n_qn/l/Questionnaires_valid_number" />: <xsl:value-of select="@valid_answered" />
    </p>
</xsl:template>

<xsl:template name="questionnaire_download">
    <xsl:if test="@total_answered > 0">
        <h2><xsl:value-of select="$i18n_qn/l/Results" /></h2>
            <p>
                    <xsl:value-of select="$i18n_qn/l/Overview" /> : 
                    <a class="text" type="submit" target="_blank" href="?download_results=html">HTML</a>,
                    <a class="text" type="submit" target="_self" href="?download_results=excel">Excel</a>,
                    <a class="text" type="submit" href="?download_results_pdf=1">PDF</a>
            </p>
            <p>
                    <xsl:value-of select="$i18n_qn/l/Overview" />&#160;(<xsl:value-of select="$i18n_qn/l/with_text_answers" />) : 
                    <a class="text" type="submit" target="_blank" href="?download_results=html;full_text_answers=1">HTML</a>,
                    <a class="text" type="submit" target="_self" href="?download_results=excel;full_text_answers=1">Excel</a>,
                    <a class="text" type="submit" href="?download_results_pdf=1;full_text_answers=1">PDF</a>
            </p>
            <p>
                    <xsl:value-of select="$i18n_qn/l/All_results" /> : 
                    <a class="text" type="submit" href="?download_all_results=HTML">HTML</a>,
                    Excel (<a class="text" type="submit" target="_self" href="?download_all_results=XLS;encoding=Latin1">Latin1</a>,
                    <a class="text" type="submit" href="?download_all_results=XLS;encoding=UTF8">UTF-8</a>)
            </p>
            <p>
                    <xsl:value-of select="$i18n_qn/l/Raw_results" /> : 
                    <a class="text" type="submit" href="?download_raw_results=1">ZIP</a>
            </p>
    </xsl:if>
</xsl:template>

<xsl:template name="questionnaire_title">
    <h1><xsl:value-of select="$i18n/l/Questionnaire"/> '<xsl:value-of select="title" />'</h1>
</xsl:template>

<xsl:template match="question" name="top_question">
	<div class="ui-widget-content ui-corner-all question">
		<xsl:call-template name="question_title" />
		<xsl:call-template name="comment" />
		<xsl:apply-templates select="child::answer"/>
		<xsl:apply-templates select="child::question"/>
		<br/>
	</div>
</xsl:template>

<!-- Answer template -->
<xsl:template match="answer">
			<xsl:call-template name="comment" />
                    <xsl:choose>
                        <xsl:when test="@type = 'Select'">
                            <xsl:call-template name="answer_select" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="@alignment='Horizontal'">
                                    <xsl:call-template name="answer_horizontal" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- default alignment of answers is vertical -->
                                    <xsl:call-template name="answer_vertical" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
</xsl:template>

<xsl:template name="question_title">
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
	<p>
        <strong>
            <xsl:if test="name()='question'">
                <xsl:value-of select="$position_long_point" />.)
            </xsl:if>
            <xsl:value-of select="title" />
        </strong>
	</p>
</xsl:template>

<xsl:template name="question_left">
            <xsl:call-template name="question_title" />
            <xsl:apply-templates select="child::question | child::answer"/>
</xsl:template>

<xsl:template name="answer_select">
    <p>
            <select name="{concat('answer_',@id)}">
                <xsl:for-each select="title">
                    <option><xsl:value-of select="." /></option>
                </xsl:for-each>
            </select>
    </p>
</xsl:template>

<xsl:template name="answer_horizontal">
    <p>
        <xsl:choose>
            <xsl:when test="@type = 'Text'">
                <xsl:choose>
                    <xsl:when test="count(title) > 0">
                        <xsl:for-each select="title">
                                <xsl:value-of select="." />
                            &#160;
                                <input type="{../@type}" name="{concat('answer_',../@id)}" />&#160;&#160;
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                            <input type="{@type}" name="{concat('answer_',@id)}" />&#160;&#160;
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type = 'Textarea'">
                    <xsl:choose>
                        <xsl:when test="count(title) > 0">
                            <xsl:for-each select="title">&#160;
                                <textarea name="{concat('answer_',../@id)}" cols="50" rows="6">
                                    <xsl:value-of select="." />
                                </textarea>&#160;&#160;
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <textarea name="{concat('answer_',@id)}" cols="50" rows="6"><xsl:value-of select="." />
                            </textarea>&#160;&#160;
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="title">
					<input type="{../@type}" name="{concat('answer_',../@id)}" value="{.}" />&#160;<xsl:value-of select="." />&#160;&#160;
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </p>
</xsl:template>

<xsl:template name="answer_vertical">
    <xsl:choose>
        <xsl:when test="../@type = 'Text'">
            <xsl:choose>
                <xsl:when test="count(title) > 0">
                    <xsl:for-each select="title">
                        <p>
                                <xsl:value-of select="." />&#160;<input type="{../@type}" name="{concat('answer_',../@id)}" />
                        </p>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                            <input type="{@type}" name="{concat('answer_',@id)}" />
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="../@type = 'Textarea'">
            <xsl:choose>
                <xsl:when test="count(title) > 0">
                    <xsl:for-each select="title">
                        <p>
                                <textarea name="{concat('answer_',../@id)}" cols="50" rows="6">
                                    <xsl:value-of select="." />
                                </textarea>
                        </p>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                            <textarea name="{concat('answer_',@id)}" cols="50" rows="6">
                            </textarea>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="title">
                <p>
                        <input type="{../@type}" name="{concat('answer_',../@id)}" value="{.}" />&#160;<xsl:value-of select="." />
                </p>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="comment">
	<xsl:if test="comment != ''">
		<pre><xsl:value-of select="comment" /></pre><br/>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>

