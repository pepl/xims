<?xml version="1.0" encoding="utf-8" ?>
<!--
     # Copyright (c) 2002-2004 The XIMS Project.
     # See the file "LICENSE" for information on usage and redistribution
     # of this file, and for a DISCLAIMER OF ALL WARRANTIES.
     # $Id$
     -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

  <xsl:import href="../../../stylesheets/anondiscussionforum_common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title><xsl:value-of select="title"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script type="text/javascript">
        function checkFields() {
            if (document.replyform.title.value.length &gt; 0 &amp;&amp; document.replyform.author.value.length &gt; 0 &amp;&amp; document.replyform.body.value.length &gt; 0) {
                return true
            }
            else {
                alert (&apos;Please fill out Title, Author and Text!&apos;);
                return false
            }
        }
        </script>
      </head>
      <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="nopath">true</xsl:with-param>
          <xsl:with-param name="nooptions">true</xsl:with-param>
          <xsl:with-param name="nostatus">true</xsl:with-param>
        </xsl:call-template>
        <br />
        <p class="10left">
          <a href="{concat($xims_box,$goxims_content,$parent_path)}"><xsl:value-of select="$i18n/l/Up"/></a>
          <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="5" height="10"/>
          |
          <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="5" height="10"/>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="concat($xims_box,$goxims_content)"/>
              <xsl:call-template name="path2topics"/>
            </xsl:attribute><xsl:value-of select="$i18n/l/Topic_overview"/>
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
          <a href="#reply"><xsl:value-of select="$i18n/l/reply"/></a>
        </p>
        <br/>
        <xsl:if test="../../objectlist/object">
          <p class="10left">
            <xsl:value-of select="$i18n/l/Previous_replies"/>:<br/>
            <table>
              <xsl:apply-templates select="/document/objectlist/object"/>
            </table>
          </p>
        </xsl:if>

        <xsl:call-template name="replyform"/>

      </body>
    </html>
  </xsl:template>


  <xsl:template match="/document/objectlist/object">
    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr>
      <td class="10left">
        <img src="{$ximsroot}images/spacer_white.gif"
             alt="spacer"
             width="{20*(number(@level)-ceiling(number(/document/objectlist/object/@level)))+1}"
             height="10"
             />
        <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif"
             alt=""
             width="20"
             height="18"
             />
        <a href="{$goxims_content}?id={@id}"><xsl:value-of select="title"/></a>
        (
        <xsl:choose>
          <xsl:when test="attributes/email">
            <a href="mailto:{attributes/email}"><xsl:value-of select="attributes/author"/></a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="attributes/author"/>
          </xsl:otherwise>
        </xsl:choose>
        ,
        <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
        )
      </td>
      <td valign="bottom" height="25">
        <xsl:if test="/document/context/object/user_privileges/delete">
          <a href="{$goxims_content}?id={@id};delete_prompt=1;">
            <img src="{$skimages}option_delete.png" border="0" width="37" height="19" title="{$i18n/l/delete}" alt="{$i18n/l/delete}"/>
          </a>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="replyform">
    <a name="reply"/>
    <form name="replyform"
          action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=AnonDiscussionForumContrib"
          method="GET"
          onSubmit="return checkFields()">
      <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
      <table border="0" width="770"
             style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px"
             cellpadding="3"
             cellspacing="0">
        <tr>
          <td valign="top" class="forumhead" colspan="2"><xsl:value-of select="$i18n/l/reply"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Title"/>:</td>
          <td><input class="foruminput" type="text" name="title" size="60" value="Re: {title}"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Author"/>:</td>
          <td><input class="foruminput" type="text" name="author" size="30"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Email"/>:</td>
          <td><input class="foruminput" type="text" name="email" size="30"/></td>
        </tr>
        <tr>
          <td></td>
          <td>
            <textarea class="foruminput" name="body" rows="10" cols="80"></textarea>
          </td>
        </tr>
      </table>
      <br />
      <p style="margin-left:240px;">
        <xsl:call-template name="saveaction"/>
      </p>
    </form>
  </xsl:template>

<xsl:template name="path2topics">
    <xsl:for-each select="parents/object[object_type_id != 14]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template match="body">
    <xsl:call-template name="br-replace">
        <xsl:with-param name="word" select="."/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
