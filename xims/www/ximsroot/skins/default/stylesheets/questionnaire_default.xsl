<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:param name="show_questions" select="'none'" />

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td colspan="2">
                      <xsl:apply-templates select="body"/>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
        </body>
    </html>
</xsl:template>

<xsl:template match="questionnaire">
    <form action="">
        <xsl:call-template name="questionnaire_title" />
        <xsl:call-template name="questionnaire_info" />
        <xsl:call-template name="questionnaire_statistics" />
        <xsl:call-template name="questionnaire_download" />
        <xsl:choose>
            <xsl:when test="$show_questions =  'none'">
                <a href="?show_questions=top" class="text" type="submit"><xsl:value-of select="$i18n_qn/l/show_questions" /></a>
            </xsl:when>
            <xsl:when test="$show_questions =  'top'">
                <a href="?show_questions=none" class="text" type="submit"><xsl:value-of select="$i18n_qn/l/hide_questions" /></a><br/>
                <xsl:call-template name="top_question" />
            </xsl:when>
        </xsl:choose>
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
        <xsl:value-of select="$i18n_qn/l/Questionnaires_valid_number" />: <xsl:value-of select="@valid_answered" />
    </div>
</xsl:template>

<xsl:template name="questionnaire_download">
    <xsl:if test="@total_answered > 0">
        <p>
            <br/>
            <xsl:value-of select="$i18n_qn/l/download_results" />&#160;
            <a class="text" type="submit" target="_blank" href="?download_results=html">HTML</a>,
            <a class="text" type="submit" target="_self" href="?download_results=excel">Excel</a>
        </p><p>
            <xsl:value-of select="$i18n_qn/l/download_all_results" />&#160;
            <a class="text" type="submit" href="?download_all_results=HTML">HTML</a>,
            Excel (<a class="text" type="submit" href="?download_all_results=XLS;encoding=Latin1">Latin1</a>,
            <a class="text" type="submit" href="?download_all_results=XLS;encoding=UTF8">UTF-8</a>)
        </p>
    </xsl:if>
</xsl:template>

<xsl:template name="questionnaire_title">
    <h1><xsl:value-of select="title" /></h1>
</xsl:template>

<xsl:template name="questionnaire_comment">
    <xsl:if test="comment!=''"><pre><xsl:value-of select="comment" /></pre></xsl:if>
</xsl:template>

<xsl:template match="question" name="top_question">
    <table >
        <tr>
            <xsl:call-template name="question_type" />
            <td>
                <table >
                    <xsl:choose>
                        <xsl:when test="@alignment='Left'">
                            <xsl:call-template name="question_left" />
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- default alignment of question is 'Top' -->
                            <xsl:call-template name="question_top" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="question_comment" />
                </table>
            </td>
        </tr>
    </table>
</xsl:template>

<!-- Answer template -->
<xsl:template match="answer">
    <table >
        <tr>
            <xsl:call-template name="question_type" />
            <td>
                <table >
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
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:call-template name="answer_comment" />
            </td>
        </tr>
    </table>
</xsl:template>

<!-- Template for the question type, default value is 'none' -->
<xsl:template name="question_type">
    <xsl:if test="name(..) != 'questionnaire'">
        <xsl:if test="(../@type = 'Checkbox' or ../@type = 'Radio') and (name(..) = 'question')">
            <td>
                <input type="{../@type}" name="{../@id}" />
            </td>
        </xsl:if>
    </xsl:if>
</xsl:template>

<xsl:template name="question_title">
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
        <b><xsl:value-of select="$position_long_point" />.) <xsl:value-of select="title" /></b>
</xsl:template>

<xsl:template name="question_left">
    <tr>
        <td>
            <xsl:call-template name="question_title" />
        </td>
        <td>
            <xsl:apply-templates select="child::question | child::answer"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="question_top">
    <tr>
        <td>
            <xsl:call-template name="question_title" />
        </td>
    </tr>
    <tr>
        <td>
            <xsl:apply-templates select="child::question | child::answer"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="question_comment">
    <xsl:if test="comment!=''">
        <tr>
            <td colspan="{count(question)+count(answer)}">
                <pre><xsl:value-of select="comment" /></pre>
            </td>
        </tr>
    </xsl:if>
</xsl:template>


<!-- Answer template rules -->
<xsl:template name="answer_select">
    <tr>
        <td>
            <select name="{concat('answer_',@id)}">
                <xsl:for-each select="title">
                    <option><xsl:value-of select="." /></option>
                </xsl:for-each>
            </select>
        </td>
    </tr>
</xsl:template>

<xsl:template name="answer_horizontal">
    <tr>
        <xsl:choose>
            <xsl:when test="@type = 'Text'">
                <xsl:for-each select="title">
                    <td>
                        <xsl:value-of select="." />
                    </td>
                    <td>
                        <input type="{../@type}" name="{concat('answer_',../@id)}" />
                    </td>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="@type = 'Textarea'">
                <td>
                    <xsl:for-each select="title">
                        <textarea name="{concat('answer_',../@id)}" cols="50" rows="6">
                            <xsl:value-of select="." />
                        </textarea>
                    </xsl:for-each>
                </td>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="title">
                    <td>
                        <input type="{../@type}" name="{concat('answer_',../@id)}" value="{.}" />
                    </td>
                    <td>
                        <xsl:value-of select="." />
                    </td>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </tr>
</xsl:template>

<xsl:template name="answer_vertical">
    <xsl:for-each select="title">
        <xsl:choose>
            <xsl:when test="../@type = 'Text'">
                <tr>
                    <td>
                        <xsl:value-of select="." />
                    </td>
                    <td>
                        <input type="{../@type}" name="{concat('answer_',../@id)}" />
                    </td>
                </tr>
            </xsl:when>
            <xsl:when test="../@type = 'Textarea'">
                <tr>
                    <td>
                        <textarea name="{concat('answer_',../@id)}" cols="50" rows="6">
                            <xsl:value-of select="." />
                        </textarea>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td>
                        <input type="{../@type}" name="{concat('answer_',../@id)}" value="{.}" />
                    </td>
                    <td>
                        <xsl:value-of select="." />
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template name="answer_comment">
    <xsl:if test="comment != ''">
        <tr>
            <td>
                <pre><xsl:value-of select="comment" /></pre>
            </td>
        </tr>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>

