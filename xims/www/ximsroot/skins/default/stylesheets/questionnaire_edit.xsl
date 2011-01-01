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
    <xsl:call-template name="questionnaire-head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="post" name="eform">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-location-edit"/>
                    <xsl:call-template name="tr-questionnaire-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="questionnaire-head-edit">
    <head>
        <title><xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" type="text/css" />
        <script src="{$ximsroot}scripts/questionnaire.js" type="text/javascript"></script>
    </head>
</xsl:template>

<xsl:template name="tr-questionnaire-edit">
    <tr>
        <td colspan="3">
            <xsl:call-template name="questionnaire"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire">
    <table>
        <xsl:call-template name="questionnaire_title_edit" />
        <xsl:call-template name="questionnaire_comment_edit" />
        <xsl:call-template name="questionnaire_intro_edit" />
        <xsl:call-template name="questionnaire_exit_edit" />
        <xsl:call-template name="questionnaire_options_edit" />
        <xsl:call-template name="markednew"/>
        <xsl:call-template name="questionnaire_tanlists" />
        <xsl:call-template name="questionnaire_actions" />
    </table>
    <hr />
    <xsl:for-each select="body/questionnaire/question">
        <xsl:call-template name="top_question">
           <xsl:with-param name="edit" select="(@edit=1)" />
           <xsl:with-param name="top" select="true()" />
        </xsl:call-template>
        <xsl:if test="(@edit=1)">
            <script type="text/javascript">
              location.hash='<xsl:number level="multiple" count="answer | question" />';
            </script>
        </xsl:if>
    </xsl:for-each>
    <hr />
</xsl:template>

<xsl:template name="questionnaire_options_edit">
    <tr>
        <td valign="top" colspan="2"><strong><xsl:value-of select="$i18n_qn/l/Questionnaire_Options"/></strong>:</td>
    </tr>
    <xsl:call-template name="questionnaire_opt_kioskmode"/>
    <xsl:call-template name="questionnaire_opt_mandatoryanswers"/>
</xsl:template>

<!-- Question template -->
<xsl:template name="top_question" match="question">
    <xsl:param name="edit" select="true()" />
    <xsl:param name="top" select="false()" />
    <xsl:choose>
        <xsl:when test="$edit or $top">
            <table width="100%" class="question-table" border="0" cellpadding="0" cellspacing="0">
                <tr class="question-header">
                    <td>
                        <xsl:call-template name="tb_question_actions" >
                            <xsl:with-param name="edit" select="$edit"/>
                        </xsl:call-template>
                    </td>
                    <xsl:call-template name="question_title" >
                        <xsl:with-param name="edit" select="$edit"/>
                        <xsl:with-param name="top" select="$top"/>
                    </xsl:call-template>
                </tr>
                <xsl:call-template name="question_comment">
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:call-template>
                <xsl:if test="$edit">
                    <xsl:call-template name="question_actions" />
                </xsl:if>
                <tr>
                    <td>&#160;</td>
                    <td colspan="2">
                        <xsl:apply-templates select="child::question | child::answer" >
                            <xsl:with-param name="edit" select="$edit"/>
                        </xsl:apply-templates>
                    </td>
                </tr>
            </table>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="question_title" >
                <xsl:with-param name="edit" select="false()"/>
            </xsl:call-template>
            <xsl:call-template name="question_comment">
                <xsl:with-param name="edit" select="false()"/>
            </xsl:call-template>
            <xsl:apply-templates select="child::question | child::answer" >
                <xsl:with-param name="edit" select="false()"/>
            </xsl:apply-templates>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template name="tb_question_actions">
    <!-- Test on which position the question is -->
    <xsl:variable name="position">
        <xsl:number count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>
    <table>
        <tr>
            <!-- icons for moving the question (up, down) -->
            <td>
                <xsl:choose>
                    <xsl:when test="$position > 1">
                        <input type="image" src="{$ximsroot}skins/{$currentskin}/images/arrow_up_activated.gif" alt="Move Up" onclick="eform.edit.value='move_up';eform.qid.value='{$position_long}'; eform.submit(); return true;" />
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}skins/{$currentskin}/images/arrow_up_deactivated.gif" alt="Deactivated" />
                    </xsl:otherwise>
                </xsl:choose>
                <br />
                <xsl:choose>
                    <xsl:when test="position() != last()">
                        <input type="image" src="{$ximsroot}skins/{$currentskin}/images/arrow_down_activated.gif" alt="Move Down" onclick="eform.edit.value='move_down';eform.qid.value='{$position_long}'; eform.submit(); return true;" />
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}skins/{$currentskin}/images/arrow_down_deactivated.gif" alt="Deactivated" />
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- icons for edit, copy, delete -->
            <td>
                <table>
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="(name() = 'question') and (name(..) = 'questionnaire') and not(@edit)" >
                                    <input
                                        type="image"
                                        src="{$skimages}option_edit.png"
                                        border="0"
                                        width="37"
                                        height="19"
                                        alt="{$i18n_qn/l/Edit_Question}"
                                        title="{$i18n_qn/l/Edit_Question}"
                                        align="left"
                                        onclick="eform.edit.value='edit_question';eform.qid.value='{$position_long}';return true;"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <img src="{$ximsroot}images/spacer_white.gif" width="32"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:if test="(name() = 'question')" >
                                <input
                                    type="image"
                                    src="{$skimages}option_copy.png"
                                    border="0"
                                    width="37"
                                    height="19"
                                    alt="Copy Question"
                                    title="Copy Question"
                                    align="left"
                                    onclick="eform.edit.value='copy_question';eform.qid.value='{$position_long}';return true;"
                                />
                            </xsl:if>
                        </td>
                        <td>
                            <input
                                type="image"
                                src="{$skimages}option_delete.png"
                                border="0"
                                width="37"
                                height="19"
                                alt="Delete"
                                title="Delete"
                                align="left"
                                onclick="eform.edit.value='delete_node';eform.qid.value='{$position_long}';return true;"
                            />
                        </td>
                    </tr>
                </table>
            </td>
            <!-- Positon -->
            <td>
                <xsl:call-template name="numbering" />
            </td>
        </tr>
    </table>
</xsl:template>

<!-- Answer template -->
<xsl:template match="answer">
    <xsl:param name="edit" select="true()" />
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>
    <xsl:variable name="answer_list">
        <xsl:for-each select="title"><xsl:value-of select="." />####</xsl:for-each>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$edit">
            <table border="0" cellpadding="0" cellspacing="0">
                <tr class="answer-header">
                    <td>
                        <xsl:call-template name="tb_question_actions" />
                    </td>
                    <td>
                        <table>
                            <tr>
                                <td>
                                    <xsl:value-of select="$i18n_qn/l/Type"/><br />
                                    <select tabindex="10" name="answer_{$position_long}_type">
                                        <xsl:if test="@type = 'Radio'"><option selected="1">Radio</option></xsl:if>
                                        <xsl:if test="@type != 'Radio'"><option>Radio</option></xsl:if>
                                        <xsl:if test="@type = 'Checkbox'"><option selected="1">Checkbox</option></xsl:if>
                                        <xsl:if test="@type != 'Checkbox'"><option>Checkbox</option></xsl:if>
                                        <xsl:if test="@type = 'Select'"><option selected="1">Select</option></xsl:if>
                                        <xsl:if test="@type != 'Select'"><option>Select</option></xsl:if>
                                        <xsl:if test="@type = 'Text'"><option selected="1">Text</option></xsl:if>
                                        <xsl:if test="@type != 'Text'"><option>Text</option></xsl:if>
                                        <xsl:if test="@type = 'Textarea'"><option selected="1">Textarea</option></xsl:if>
                                        <xsl:if test="@type != 'Textarea'"><option>Textarea</option></xsl:if>
                                    </select>
                                </td>
                                <td>
                                    <xsl:value-of select="$i18n_qn/l/Comment"/><br />
                                    <input type="text" tabindex="10" name="answer_{$position_long}_comment" size="40" class="text" value="{comment}"/>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        &#xa0;
                    </td>
                    <td colspan="2" class="exampleanswers">
                        <xsl:value-of select="$i18n_qn/l/Example_Answers"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        &#xa0;
                    </td>
                    <td align="right" class="exampleanswers">
                        <select tabindex="10" name="answer_{$position_long}_select">
                            <xsl:for-each select="title">
                                <option><xsl:value-of select="." /></option>
                            </xsl:for-each>
                        </select>
                        <input type="button" value="{$i18n_qn/l/Remove_from_selection}" onclick="removeSelection(answer_{$position_long}_select);" />
                        <br />
                        <input type="text" class="text" size="40" tabindex="10" name="answer_{$position_long}_add" value = "" />
                        <input type="button" value="{$i18n_qn/l/Add_to_selection}" onclick="addSelection(answer_{$position_long}_add,answer_{$position_long}_select);" /><br />
                        <input type="hidden" name="answer_{$position_long}_title" value="{$answer_list}" />
                    </td>
                    <td class="exampleanswers" style="vertical-align: top; padding-left: 5px">
                        <span class="answeralignement">
                            <xsl:value-of select="$i18n_qn/l/Alignment"/><br />
                            <select tabindex="10" name="answer_{$position_long}_alignment">
                                <xsl:if test="@alignment = 'Horizontal'"><option selected="1">Horizontal</option></xsl:if>
                                <xsl:if test="@alignment != 'Horizontal'"><option>Horizontal</option></xsl:if>
                                <xsl:if test="@alignment = 'Vertical'"><option selected="1">Vertical</option></xsl:if>
                                <xsl:if test="@alignment != 'Vertical'"><option>Vertical</option></xsl:if>
                            </select>
                        </span>
                    </td>
                </tr>
            </table>
        </xsl:when>
        <xsl:otherwise>
            <input type="hidden" name="answer_{$position_long}_title" value="{$answer_list}" />
            <input type="hidden" name="answer_{$position_long}_type" value="{@type}" />
            <input type="hidden" name="answer_{$position_long}_alignment" value="{@alignment}" />
            <input type="hidden" name="answer_{$position_long}_comment" value="{comment}"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Questionnaire template rules -->
<xsl:template name="questionnaire_title_edit">
    <tr>
        <td valign="top">
            <span class="qu-edit-title"><xsl:value-of select="$i18n/l/Title"/></span>
        </td>
        <td>
            <input type="text" tabindex="10" name="title" size="40" class="text" value="{body/questionnaire/title}"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire_intro_edit">
    <tr>
        <td valign="top">
            <span><xsl:value-of select="$i18n_qn/l/Intro"/></span>
        </td>
        <td>
            <textarea tabindex="10" name="questionnaire_intro" cols="50" rows="3" class="text">
                <xsl:value-of select="body/questionnaire/intro"/>
            </textarea>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire_exit_edit">
    <tr>
        <td valign="top">
            <span><xsl:value-of select="$i18n_qn/l/Exit"/></span>
        </td>
        <td>
            <textarea type="text" tabindex="10" name="questionnaire_exit" cols="50"  rows="3" class="text">
                <xsl:value-of select="body/questionnaire/exit"/>
            </textarea>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire_opt_kioskmode">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n_qn/l/Kioskmode"/>
            <input name="questionnaire_opt_kioskmode" type="radio" value="true">
              <xsl:if test="body/questionnaire/options/kioskmode = '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/Yes"/>
            <input name="questionnaire_opt_kioskmode" type="radio" value="false">
              <xsl:if test="not(body/questionnaire/options/kioskmode) or body/questionnaire/options/kioskmode != '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('kioskmode')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire_opt_mandatoryanswers">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n_qn/l/Mandatory_Answers"/>
            <input name="questionnaire_opt_mandatoryanswers" type="radio" value="true">
              <xsl:if test="body/questionnaire/options/mandatoryanswers = '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/Yes"/>
            <input name="questionnaire_opt_mandatoryanswers" type="radio" value="false">
              <xsl:if test="not(body/questionnaire/options/kioskmode) or body/questionnaire/options/mandatoryanswers != '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('mandatoryanswers')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire_comment_edit">
<!--    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>-->
    <tr>
        <td valign="top">
            <span><xsl:value-of select="$i18n_qn/l/Comment"/></span>
        </td>
        <td>
            <input type="text" tabindex="10" name="questionnaire_comment" size="40" class="text" value="{ body/questionnaire/comment}"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="questionnaire_actions">
    <tr>
        <td valign="top" colspan="2">
            <div>
                <input type="submit" value="{$i18n_qn/l/Add_TAN_List}" onclick="eform.edit.value='add_tanlist';eform.qid.value=eform.TAN_List.value;return true;" />&#xa0;
                <input type="text" name="TAN_List" size="40" class="text" />&#xa0;
                <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={parents/object[@document_id=current()/@parent_id]/@id};contentbrowse=1;otfilter=TAN_List;sbfield=eform.TAN_List')" class="doclink"><xsl:value-of select="$i18n_qn/l/browse_TAN_List"/></a>
            </div>
            <div style="margin-top: 5px">
                <hr />
                <input type="hidden" name="edit" />
                <input type="hidden" name="qid" />
                <input type="submit" value="{$i18n_qn/l/Add_Question}" onclick="eform.edit.value='add_question';eform.qid.value='';return true;" />
            </div>
        </td>
    </tr>
</xsl:template>


<!-- Question template rules -->
<xsl:template name="question_title">
    <xsl:param name="edit" select="true()" />
    <xsl:param name="top" select="false()" />
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$edit">
            <td>
                <a name="{$position_long}"><span class="qn-edit-title"><xsl:value-of select="$i18n_qn/l/Question"/></span></a>
            </td>
            <td width="100%">
                <textarea tabindex="10" name="question_{$position_long}_title" cols="50" rows="3" class="text">
                    <xsl:value-of select="title" />
                </textarea>
                <!-- some hidden attributes, later they will be editable -->
                <input type="hidden" name="question_{$position_long}_type" value="None" />
                <input type="hidden" name="question_{$position_long}_alignment" value="Top" />
            </td>
        </xsl:when>
        <xsl:when test="$top and not($edit)">
            <td width="100%">
                <a href="#{$position_long}" name="{$position_long}" onclick="eform.edit.value='edit_question';eform.qid.value='{$position_long}';eform.submit();return true;"><xsl:value-of select="title" /></a>
                <input type="hidden" name="question_{$position_long}_title" value="{title}" />
                <input type="hidden" name="question_{$position_long}_type" value="None" />
                <input type="hidden" name="question_{$position_long}_alignment" value="Top" />
            </td>
        </xsl:when>
        <xsl:otherwise>
            <input type="hidden" name="question_{$position_long}_title" value="{title}" />
            <input type="hidden" name="question_{$position_long}_type" value="None" />
            <input type="hidden" name="question_{$position_long}_alignment" value="Top" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="question_comment">
    <xsl:param name="edit" select="true()" />
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$edit">
            <tr>
                <td>&#160;</td>
                <td>
                    <xsl:value-of select="$i18n_qn/l/Comment"/>
                </td>
                <td>
                    <input type="text" tabindex="10" name="question_{$position_long}_comment" size="40" class="text" value="{comment}"/>
                </td>
            </tr>
        </xsl:when>
        <xsl:otherwise>
            <input type="hidden" name="question_{$position_long}_comment" value="{comment}"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="question_actions">
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>
    <tr>
        <td>&#160;</td>
        <td valign="top" colspan="2">
            <input type="submit" value="{$i18n_qn/l/Add_Subquestion}" onclick="eform.edit.value='add_question';eform.qid.value='{$position_long}';return true;" />
            &#160;
            <input type="submit" value="{$i18n_qn/l/Add_Answer}" onclick="eform.edit.value='add_answer';eform.qid.value='{$position_long}';return true;" />
            &#160;
        </td>
    </tr>
</xsl:template>

<xsl:template name="numbering">
    <xsl:variable name="position_long_point">
        <xsl:number level="multiple" count="question | answer" />
    </xsl:variable>
    <xsl:variable name="position_long">
        <xsl:value-of select="translate($position_long_point,'.','x')" />
    </xsl:variable>
    <a name="{$position_long}">
        <span class="numbering"><xsl:number level="multiple" count="answer | question" />) </span>
    </a>
</xsl:template>

<xsl:template name="questionnaire_tanlists">
    <tr>
        <td valign="top" colspan="2">
            <hr/>
            TAN-Lists:
            <ul style="margin-top: 0px;">
            <xsl:for-each select="body/questionnaire/tanlist">
                <li>
                <xsl:value-of select="." />
                <input type="hidden" name="tanlist_{@id}_title" value="{.}" />&#xa0;
                <input type="image"
                       src="{$skimages}option_delete.png"
                       style="vertical-align: bottom"                       
                       alt="{$i18n_qn/l/Remove_TAN_List}"
                       title="{$i18n_qn/l/Remove_TAN_List}"
                       value="{$i18n_qn/l/Remove_TAN_List}"
                       onclick="eform.edit.value='remove_tanlist';eform.qid.value={@id};return true;" />
                </li>
            </xsl:for-each>
            </ul>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
