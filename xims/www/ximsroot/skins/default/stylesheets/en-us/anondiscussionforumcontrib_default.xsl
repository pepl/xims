<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:import href="common.xsl"/>
<xsl:import href="../../../anondiscussionforum_common.xsl"/>
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
  <head>
    <title><xsl:value-of select="title"/> - Anonymous Discussion Forum - XIMS</title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript" />
    <script type="text/javascript">
        <![CDATA[
        function checkFields() {
           if (document.replyform.title.value.length > 0 && document.replyform.author.value.length > 0 && document.replyform.body.value.length > 0) {
             return true
           }
           else {
             alert ('Please fill out Title, Author and Text!');
             return false
           }
        }
        ]]>
    </script>
  </head>
  <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
    <xsl:call-template name="header">
      <xsl:with-param name="nopath">true</xsl:with-param>
      <xsl:with-param name="nooptions">true</xsl:with-param>
      <xsl:with-param name="nostatus">true</xsl:with-param>
    </xsl:call-template>
    <br />
    <p class="10left">
        <a href="{concat($goxims_content,$parent_path)}">Up</a>
            <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="5" height="10"/>
        |
        <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="5" height="10"/>
    <a>
          <xsl:attribute name="href">
              <xsl:value-of select="$goxims_content"/>
              <xsl:call-template name="path2topics"/>
          </xsl:attribute>Overview of topics
      </a>
   </p>

   <table width="770" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
      <tr>
        <td class="forumhead">
            <xsl:value-of select="title"/>
            (
            <xsl:choose>
                <xsl:when test="attributes/email">
                    <a href="mailto:{attributes/email}"><xsl:value-of select="attributes/author"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="attributes/author"/>
                </xsl:otherwise>
            </xsl:choose>
        <xsl:choose>
                <xsl:when test="attributes/coemail">, <a href="mailto:{attributes/coemail}"><xsl:value-of select="attributes/coauthor"/></a>
                </xsl:when>
                <xsl:when test="attributes/coauthor">, <xsl:value-of select="attributes/coauthor"/>
                </xsl:when>
            </xsl:choose>
            )
        </td>
        <td class="forumhead" align="right">
            <xsl:apply-templates select="creation_time" mode="datetime"/>
        </td>
      </tr>
      <tr>
        <td colspan="2" class="forumcontent">
            <xsl:apply-templates select="body"/>
        </td>
      </tr>
    </table>
    <br />
    
    <p class="10left">
        <a href="#reply">Reply</a>
    </p>
    <br/>
    <xsl:if test="children/object">
        <p class="10left">
            Previous replies:<br/>
            <table>
                <xsl:apply-templates select="children/object"/>
            </table>
        </p>
    </xsl:if>

    <xsl:call-template name="replyform"/>

  </body>
</html>
</xsl:template>

<xsl:template match="children/object">
    <tr>
    <td class="10left">
    <xsl:choose>
        <xsl:when test="@level &gt; '0'">
            <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="{10*@level}" height="10"/><img src="{$ximsroot}images/icons/list_HTML.gif" alt="Discussion-Entry-Icon" width="20" height="18"/><a href="{$goxims_content}?id={@id}"><xsl:value-of select="title"/></a>
            (<xsl:choose>
                <xsl:when test="attributes/email">
                    <a href="mailto:{attributes/email}"><xsl:value-of select="attributes/author"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="attributes/author"/>
                </xsl:otherwise>
            </xsl:choose>,
            <xsl:apply-templates select="creation_time" mode="datetime"/>)
        </xsl:when>
        <xsl:otherwise>
            <img src="{$ximsroot}images/icons/list_HTML.gif" alt="Discussion-Entry-Icon" width="20" height="18"/><xsl:value-of select="title"/>
        </xsl:otherwise>
    </xsl:choose>
    </td>
    <td valign="bottom" height="25">
    <xsl:if test="user_privileges/delete">
        <a href="{$goxims_content}?id={@id};del_prompt=1;">
            <img src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" border="0" width="37" height="19" title="delete" alt="delete"/>
        </a>
    </xsl:if>
    </td>
    </tr>
</xsl:template>

<xsl:template name="replyform">
    <a name="reply"/>
    <form name="replyform" action="{/document/session/serverurl}{$goxims_content}{$absolute_path}?objtype=anondiscussionforumcontrib" method="POST" onSubmit="return checkFields()">

        <table border="0" width="770" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
        <tr>
            <td valign="top" class="forumhead" colspan="2">Reply</td>
        </tr>
        <tr>
            <td valign="middle" class="forumcontent">Title:</td>
            <td><input class="foruminput" type="text" name="title" size="60" value="Re: {title}"/></td>
        </tr>
        <tr>
            <td valign="middle" class="forumcontent">Author:</td>
            <td><input class="foruminput" type="text" name="author" size="60"/></td>
        </tr>
        <tr>
            <td valign="middle" class="forumcontent">Email:</td>
            <td><input class="foruminput" type="text" name="email" size="60"/></td>
        </tr>
        <tr>
            <td></td>
            <td>
                <textarea class="foruminput" name="body" rows="10" cols="80"></textarea>
                <input type="hidden" name="parid" value="{/document/context/object/@document_id}"/>
                <input type="hidden" name="store" value="1"/><br/>
            </td>
        </tr>
        </table>
        <br/>
        <p style="margin-left:240px;">
          <input type="submit" border="0" value="Send reply" name="submit" class="control" />
        </p>
    </form>
</xsl:template>

<xsl:template name="path2topics">
  <xsl:for-each select="parents/object[object_type != 16]">
    <xsl:text>/</xsl:text><xsl:value-of select="location"/>
  </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
