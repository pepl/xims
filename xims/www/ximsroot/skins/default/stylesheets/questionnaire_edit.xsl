<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: questionnaire_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common.xsl"/>
	
	<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))"/>
	<xsl:param name="questionnaire" select="true()"/>
	
	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>		
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="questionnaire"/>
		<xsl:call-template name="questions"/>
	</xsl:template>
	
	<xsl:template name="questionnaire">
		<xsl:call-template name="questionnaire-meta"/>
		<xsl:call-template name="questionnaire_options_edit"/>
		<xsl:call-template name="questionnaire_tanlists"/>
	</xsl:template>
	
	<xsl:template name="questions">
		<div class="form-div block">
			<h2><xsl:value-of select="$i18n_qn/l/Questions"/></h2>
			<xsl:call-template name="questionnaire_add_question"/>
		</div>
		<div>
		<xsl:for-each select="body/questionnaire/question">
			<xsl:call-template name="top_question">
				<xsl:with-param name="edit" select="(@edit=1)"/>
				<xsl:with-param name="top" select="true()"/>
			</xsl:call-template>
			<xsl:if test="(@edit=1)">
				<script type="text/javascript">
              location.hash='<xsl:number level="multiple" count="answer | question"/>';
            </script>
			</xsl:if>
		</xsl:for-each>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire-meta">
		<div class="form-div block">
		<xsl:call-template name="questionnaire_comment_edit"/>
		<xsl:call-template name="questionnaire_intro_edit"/>
		<xsl:call-template name="questionnaire_exit_edit"/>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_options_edit">
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n_qn/l/Questionnaire_Options"/></h2>
		<xsl:call-template name="questionnaire_opt_kioskmode"/>
		<xsl:call-template name="questionnaire_opt_mandatoryanswers"/>
		</div>
	</xsl:template>
	
	<!-- Question template -->
	<xsl:template name="top_question" match="question">
		<xsl:param name="edit" select="true()"/>
		<xsl:param name="top" select="false()"/>
		
		<div class="ui-widget-content ui-corner-all question" >
		<xsl:choose>
			<xsl:when test="$edit or $top">
				
					<xsl:call-template name="tb_question_actions">
						<xsl:with-param name="edit" select="$edit"/>
					</xsl:call-template>
				<div class="question-main">
					<xsl:call-template name="question_title">
						<xsl:with-param name="edit" select="$edit"/>
						<xsl:with-param name="top" select="$top"/>
					</xsl:call-template>
					<!--<br/>-->
					<xsl:call-template name="question_comment">
						<xsl:with-param name="edit" select="$edit"/>
					</xsl:call-template>
					<xsl:if test="$edit">
						<xsl:call-template name="question_actions"/>
					</xsl:if>

					<xsl:apply-templates select="child::answer">
						<xsl:with-param name="edit" select="$edit"/>
					</xsl:apply-templates>

					<xsl:apply-templates select="child::question">
						<xsl:with-param name="edit" select="$edit"/>
					</xsl:apply-templates>
					<!--<xsl:apply-templates select="child::question | child::answer">
						<xsl:with-param name="edit" select="$edit"/>
					</xsl:apply-templates>-->
				</div>	
				
	
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="question_title">
					<xsl:with-param name="edit" select="false()"/>
				</xsl:call-template>
				<xsl:call-template name="question_comment">
					<xsl:with-param name="edit" select="false()"/>
				</xsl:call-template>
				<xsl:apply-templates select="child::question | child::answer">
					<xsl:with-param name="edit" select="false()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<br class="clear"/>
		</div>
	</xsl:template>
	
	<xsl:template name="tb_question_actions">
		<!-- Test on which position the question is -->
		<xsl:variable name="position">
			<xsl:number count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long_point">
			<xsl:number level="multiple" count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long">
			<xsl:value-of select="translate($position_long_point,'.','x')"/>
		</xsl:variable>
		<div class="question-options">
			<xsl:choose>
				<xsl:when test="$position > 1">
				<a class="button up" href="#{$position_long}" onclick="eform.edit.value='move_up';eform.qid.value='{$position_long}'; eform.submit(); return true;">&#xa0;</a>
				</xsl:when>
				<xsl:otherwise>
					<a class="button option-disabled">&#160;</a>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="position() != last()">
					<a class="button down" href="#{$position_long}" onclick="eform.edit.value='move_down';eform.qid.value='{$position_long}'; eform.submit(); return true;">&#xa0;</a>
				</xsl:when>
				<xsl:otherwise>
					<a class="button option-disabled">&#160;</a>
				</xsl:otherwise>
			</xsl:choose>
			&#160;&#160;&#160;
			<xsl:choose>
				<xsl:when test="(name() = 'question') and (name(..) = 'questionnaire') and not(@edit)">
				<a class="button option-edit" href="#{$position_long}" name="{$position_long}" onclick="eform.edit.value='edit_question';eform.qid.value='{$position_long}';eform.submit();return true;">
						<xsl:value-of select="$i18n/l/Edit"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<a class="button option-disabled">&#160;</a>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="(name() = 'question')">
				<a class="button option-copy" href="#" onclick="eform.edit.value='copy_question';eform.qid.value='{$position_long}';eform.submit();return true;">
						<xsl:value-of select="$i18n/l/Copy"/>
				</a>
			</xsl:if>
			<a class="button option-delete" href="#" onclick="eform.edit.value='delete_node';eform.qid.value='{$position_long}';eform.submit();return true;">
					<xsl:value-of select="$i18n/l/delete"/>
			</a>
		</div>
	</xsl:template>
		
	<!-- Answer template -->
	<xsl:template match="answer">
		<xsl:param name="edit" select="true()"/>
		<xsl:variable name="position_long_point">
			<xsl:number level="multiple" count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long">
			<xsl:value-of select="translate($position_long_point,'.','x')"/>
		</xsl:variable>
		<xsl:variable name="answer_list">
			<xsl:for-each select="title">
				<xsl:value-of select="."/>####</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$edit">
				<br class="clear"/>
				<div class="ui-widget-content ui-corner-all question">
					<!--<p class="answer-header">-->
						<div class="question-options">
							<xsl:call-template name="tb_question_actions"/>
						</div>
						<p>&#160;<xsl:value-of select="$i18n_qn/l/Answer"/>&#160;-&#160;
							<xsl:value-of select="$i18n_qn/l/Type"/>&#160;
							<select name="answer_{$position_long}_type">
								<xsl:if test="@type = 'Radio'">
									<option selected="1">Radio</option>
								</xsl:if>
								<xsl:if test="@type != 'Radio'">
									<option>Radio</option>
								</xsl:if>
								<xsl:if test="@type = 'Checkbox'">
									<option selected="1">Checkbox</option>
								</xsl:if>
								<xsl:if test="@type != 'Checkbox'">
									<option>Checkbox</option>
								</xsl:if>
								<xsl:if test="@type = 'Select'">
									<option selected="1">Select</option>
								</xsl:if>
								<xsl:if test="@type != 'Select'">
									<option>Select</option>
								</xsl:if>
								<xsl:if test="@type = 'Text'">
									<option selected="1">Text</option>
								</xsl:if>
								<xsl:if test="@type != 'Text'">
									<option>Text</option>
								</xsl:if>
								<xsl:if test="@type = 'Textarea'">
									<option selected="1">Textarea</option>
								</xsl:if>
								<xsl:if test="@type != 'Textarea'">
									<option>Textarea</option>
								</xsl:if>
							</select>
						</p>
						<p>
							<xsl:value-of select="$i18n_qn/l/Comment"/>&#160;
							<input type="text" tabindex="10" name="answer_{$position_long}_comment" size="40" class="text" value="{comment}"/>
						</p>


						<p>
							<xsl:value-of select="$i18n_qn/l/Example_Answers"/>
						</p>

						<p>
							<select tabindex="10" name="answer_{$position_long}_select">
								<xsl:for-each select="title">
									<option>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>&#160;
							<button type="button" class="button" onclick="removeSelection(answer_{$position_long}_select);"><xsl:value-of select="$i18n_qn/l/Remove_from_selection"/></button>
						</p>
						<p>
							<input type="text" class="text" size="40" name="answer_{$position_long}_add" value=""/>&#160;
							<button type="button" class="button" onclick="addSelection(answer_{$position_long}_add,answer_{$position_long}_select);"><xsl:value-of select="$i18n_qn/l/Add_to_selection"/></button>
							<input type="hidden" name="answer_{$position_long}_title" value="{$answer_list}"/>
						</p>
						<p>
							<xsl:value-of select="$i18n_qn/l/Alignment"/>&#160;
							<select name="answer_{$position_long}_alignment">
								<xsl:if test="@alignment = 'Horizontal'">
									<option selected="1">Horizontal</option>
								</xsl:if>
								<xsl:if test="@alignment != 'Horizontal'">
									<option>Horizontal</option>
								</xsl:if>
								<xsl:if test="@alignment = 'Vertical'">
									<option selected="1">Vertical</option>
								</xsl:if>
								<xsl:if test="@alignment != 'Vertical'">
									<option>Vertical</option>
								</xsl:if>
							</select>							
						</p>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<input type="hidden" name="answer_{$position_long}_title" value="{$answer_list}"/>
				<input type="hidden" name="answer_{$position_long}_type" value="{@type}"/>
				<input type="hidden" name="answer_{$position_long}_alignment" value="{@alignment}"/>
				<input type="hidden" name="answer_{$position_long}_comment" value="{comment}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	
	<!--Why is input-fiel named "questionnaire_title" and not "title" like in anywhere else???-->
	<!--<xsl:template name="questionnaire_title_edit">-->
	<xsl:template name="form-title-edit">
		<div id="tr-title">
			<div class="label-std">
				<label for="input-title">
					<xsl:value-of select="$i18n/l/Title"/>&#160;*
				</label>
			</div>
			<input type="text" name="questionnaire_title" size="60" class="text" id="input-title" value="{body/questionnaire/title}">
				<xsl:attribute name="onchange">return testtitle();</xsl:attribute>
			</input>
			<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Title')" class="doclink">
				<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Title"/>
				</xsl:attribute>(?)</a>-->
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_intro_edit">
		<div>
			<div id="label-intro">
				<label for="input-intro">
					<xsl:value-of select="$i18n_qn/l/Intro"/>
				</label>
			</div>
			<br/>
			<textarea type="text" name="questionnaire_intro" cols="74" rows="3" class="text" id="input-intro">
				<xsl:value-of select="body/questionnaire/intro"/>
			</textarea>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_exit_edit">
		<div>
			<div id="label-exit">
				<label for="input-exit">
					<xsl:value-of select="$i18n_qn/l/Exit"/>
				</label>
			</div>
			<br/>
			<textarea type="text" name="questionnaire_exit" cols="74" rows="3" class="text" id="input-exit">
				<xsl:value-of select="body/questionnaire/exit"/>
			</textarea>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_opt_kioskmode">
		<div>
			<fieldset>
				<xsl:value-of select="$i18n_qn/l/Kioskmode"/>
				<input name="questionnaire_opt_kioskmode" type="radio" value="true" class="radio-button" id="input-rb-kiosk-true">
					<xsl:if test="body/questionnaire/options/kioskmode = '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="input-rb-kiosk-true">
					<xsl:value-of select="$i18n/l/Yes"/>
				</label>
				<input name="questionnaire_opt_kioskmode" type="radio" value="false" class="radio-button" id="input-rb-kiosk-false">
					<xsl:if test="not(body/questionnaire/options/kioskmode) or body/questionnaire/options/kioskmode != '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="input-rb-kiosk-no">
					<xsl:value-of select="$i18n/l/No"/>
				</label>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('kioskmode')" class="doclink">(?)</a>-->
			</fieldset>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_opt_mandatoryanswers">
		<div>
			<fieldset>
				<xsl:value-of select="$i18n_qn/l/Mandatory_Answers"/>
				<input name="questionnaire_opt_mandatoryanswers" type="radio" value="true" class="radio-button" id="input-rb-manan-true">
					<xsl:if test="body/questionnaire/options/mandatoryanswers = '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="input-rb-manan-true">
					<xsl:value-of select="$i18n/l/Yes"/>
				</label>
				<input name="questionnaire_opt_mandatoryanswers" type="radio" value="false" class="radio-button" id="input-rb-manan-false">
					<xsl:if test="not(body/questionnaire/options/kioskmode) or body/questionnaire/options/mandatoryanswers != '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="input-rb-manan-false">
					<xsl:value-of select="$i18n/l/No"/>
				</label>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('mandatoryanswers')" class="doclink">(?)</a>-->
			</fieldset>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_comment_edit">
		<div>
			<div class="label-std">
				<label for="input-comment">
					<xsl:value-of select="$i18n_qn/l/Comment"/>
				</label>
			</div>
			<input type="text" name="questionnaire_comment" size="60" class="text" value="{ body/questionnaire/comment}" id="input-comment"/>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_tanlists">
		<div class="form-div block">
		<h2>TAN-Lists</h2>
		<ul>
			<xsl:for-each select="body/questionnaire/tanlist">
				<li>
					<xsl:value-of select="."/>
					<input type="hidden" name="tanlist_{@id}_title" value="{.}"/>&#xa0;
							<a class="button option-delete" onclick="eform.edit.value='remove_tanlist';eform.qid.value={@id};return true;">
						<span>
							<xsl:value-of select="$i18n_qn/l/Remove_TAN_List"/>
						</span>&#160;</a>
				</li>
			</xsl:for-each>
		</ul>
		
		<div>			
		<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={parents/object[@document_id=current()/@parent_id]/@id};contentbrowse=1;otfilter=TAN_List;sbfield=eform.TAN_List','default-dialog','{$i18n_qn/l/browse_TAN_List}')" class="button">
				<xsl:value-of select="$i18n_qn/l/browse_TAN_List"/>
			</a>&#xa0;	
		<input type="text" name="TAN_List" id="TAN_List" size="40" class="text" />&#xa0;
			<button type="submit" onclick="eform.edit.value='add_tanlist';eform.qid.value=eform.TAN_List.value;return true;" id="add_tanlist" >
				<xsl:value-of select="$i18n_qn/l/Add_TAN_List"/>
			</button>
		</div>
		</div>
	</xsl:template>
	
	<xsl:template name="questionnaire_add_question">
		<div>
			<input type="hidden" name="edit"/>
			<input type="hidden" name="qid"/>
			<button type="submit" onclick="eform.edit.value='add_question';eform.qid.value='';return true;"><xsl:value-of select="$i18n_qn/l/Add_Question"/></button>
		</div>
	</xsl:template>
	
	<!-- Question template rules -->
	<xsl:template name="question_title">
		<xsl:param name="edit" select="true()"/>
		<xsl:param name="top" select="false()"/>
		<xsl:variable name="position_long_point">
			<xsl:number level="multiple" count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long">
			<xsl:value-of select="translate($position_long_point,'.','x')"/>
		</xsl:variable>
		
		<p>
		&#160;<xsl:call-template name="numbering"/>
			<xsl:choose>
				<xsl:when test="$edit">
					<!--<div class="label-std">--><label for="input-question" class="label-question">
						<xsl:value-of select="$i18n_qn/l/Question"/>
					</label><!--</div>-->
								&#160;
					<textarea name="question_{$position_long}_title" cols="40" rows="2" class="text" id="input-question">
						<xsl:value-of select="title"/>
					</textarea>
					<!-- some hidden attributes, later they will be editable -->
					<input type="hidden" name="question_{$position_long}_type" value="None"/>
					<input type="hidden" name="question_{$position_long}_alignment" value="Top"/>
				</xsl:when>
				<xsl:when test="$top and not($edit)">
					<a href="#{$position_long}" name="{$position_long}" onclick="eform.edit.value='edit_question';eform.qid.value='{$position_long}';eform.submit();return true;">
						<xsl:value-of select="title"/>
					</a>
					<input type="hidden" name="question_{$position_long}_title" value="{title}"/>
					<input type="hidden" name="question_{$position_long}_type" value="None"/>
					<input type="hidden" name="question_{$position_long}_alignment" value="Top"/>
				</xsl:when>
				<xsl:otherwise>
					<input type="hidden" name="question_{$position_long}_title" value="{title}"/>
					<input type="hidden" name="question_{$position_long}_type" value="None"/>
					<input type="hidden" name="question_{$position_long}_alignment" value="Top"/>
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:template>
	
	<xsl:template name="question_comment">
		<xsl:param name="edit" select="true()"/>
		<xsl:variable name="position_long_point">
			<xsl:number level="multiple" count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long">
			<xsl:value-of select="translate($position_long_point,'.','x')"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$edit">
				<p id="question-comment">
            &#160;
                   <label for="input-comment">
						<xsl:value-of select="$i18n_qn/l/Comment"/>
					</label> 
                &#160;
                    <input type="text" name="question_{$position_long}_comment" size="47" class="text" value="{comment}" id="input-comment"/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<input type="hidden" name="question_{$position_long}_comment" value="{comment}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="question_actions">
		<xsl:variable name="position_long_point">
			<xsl:number level="multiple" count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long">
			<xsl:value-of select="translate($position_long_point,'.','x')"/>
		</xsl:variable>
        <p>
        	&#160;
            <button type="submit" onclick="eform.edit.value='add_question';eform.qid.value='{$position_long}';return true;" class="button"><xsl:value-of select="$i18n_qn/l/Add_Subquestion"/></button>
            &#160;
            <button type="submit" onclick="eform.edit.value='add_answer';eform.qid.value='{$position_long}';return true;" class="button"><xsl:value-of select="$i18n_qn/l/Add_Answer"/></button>
	</p>
	</xsl:template>
	
	<xsl:template name="numbering">
		<xsl:variable name="position_long_point">
			<xsl:number level="multiple" count="question | answer"/>
		</xsl:variable>
		<xsl:variable name="position_long">
			<xsl:value-of select="translate($position_long_point,'.','x')"/>
		</xsl:variable>
		<a name="{$position_long}">
			<span class="numbering">
				<xsl:number level="multiple" count="answer | question"/>) </span>
		</a>
    &#160;
</xsl:template>

<!-- as Questionnaire can not be reedited when published, automatic publishing makes no sense-->
<xsl:template name="publish-on-save"/>

</xsl:stylesheet>
