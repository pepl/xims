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

<xsl:import href="common.xsl"/>
<xsl:output method="html" encoding="utf-8"/>
    
<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <html>
  	 <title><xsl:value-of select="//questionnaire/title" /></title>
<!--        <xsl:call-template name="head_default"/>-->
       <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
	<link style="text/css" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" />

        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
	        <!-- Display Error message if it exists -->
	       <xsl:if test="//questionnaire/error_message != ''">
			<p class="error_msg"><strong>Error:</strong><br /><xsl:value-of select="//questionnaire/error_message" /></p>
		</xsl:if>
           <xsl:apply-templates select="body"/>
        </body>
    </html>
</xsl:template>

<!-- Questionnaire specific templates -->

<xsl:template match="questionnaire">
<xsl:variable name="question_count" select="count(question)" />
<xsl:variable name="tan" select="tan" />
<xsl:variable name="current_question" select="current_question" />
			<xsl:choose>
				<xsl:when test="$current_question > $question_count">
				  <div align="center">
					Thankyou for answering the questions.<br />
					<input type="button" value="Close Window" onclick="window.close();" />
				  </div>
				</xsl:when>
				<xsl:when test="$current_question >= 1">
					<form action="?q={$current_question + 1}" method="post">
						<xsl:call-template name="questionnaire_title" />
						<input type="hidden" name="tan" value="{$tan}" />
						<input type="hidden" name="q" value="{$current_question + 1}" />
						<input type="hidden" name="docid" value="{/document/context/object/@document_id}" />
						<xsl:apply-templates select="question[$current_question + 0]" />
<!--						<xsl:for-each select="question">
							<xsl:call-template name="top_question"/>
							<hr />
						</xsl:for-each>-->
						<input type="submit" name="answer" value="Next >" />
					</form>
				</xsl:when>
				<xsl:otherwise>
				  <div align="center">
					<xsl:call-template name="questionnaire_title" />
					<xsl:call-template name="questionnaire_comment" />
					<p>
					<form action="?q=1" method="post">
						<input type="hidden" name="q" value="1" />
						<input type="hidden" name="docid" value="{/document/context/object/@document_id}" />
						<xsl:if test="count(tanlist) > 0">
							TAN:<input type="text" name="tan" /><br />
						</xsl:if>
						<input type="submit" value="Begin"/>
					</form>
					</p>
				  </div>
				</xsl:otherwise>
			</xsl:choose>
</xsl:template>

<!-- Question template -->
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

<!-- Questionnaire template rules -->
<xsl:template name="questionnaire_title">
	<h2><xsl:value-of select="title" /></h2>
</xsl:template>

<xsl:template name="questionnaire_comment">
	<xsl:if test="comment!=''"><span class="questionnaire_comment_default"><xsl:value-of select="comment" /></span></xsl:if>
</xsl:template>


<!-- Question template rules -->
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

