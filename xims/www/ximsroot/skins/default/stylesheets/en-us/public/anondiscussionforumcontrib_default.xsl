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

<xsl:import href="common.xsl"/>
<xsl:import href="../../../../../stylesheets/anondiscussionforum_common.xsl"/>
<xsl:output method="html" encoding="utf-8"/>
<xsl:param name="request.uri"/>

<xsl:template match="/document/context/object">
<html>
  <head>
    <title><xsl:value-of select="title"/> - XIMS</title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="/scripts/default.js" type="text/javascript" />
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

   <body margintop="0" marginleft="0" marginwidth="0" marginheight="0">
    <table border="0" cellpadding="0" cellspacing="0" width="790">
            <xsl:call-template name="header">
                <!-- we need a more flexible header-template; for now, there is no nocreatewidget-param -->
                <xsl:with-param name="nocreatewidget">true</xsl:with-param>
            </xsl:call-template>
            <tr>
                <td class="links">
                <!-- Begin Standard Links -->
                <xsl:call-template name="stdlinks"/>
                <!-- End Standard Links -->

                <!-- Begin Department Links -->
                <xsl:call-template name="deptlinks"/>
                <!-- End Department Links -->

                <!-- Begin Document Links -->
                <!-- End Document Links -->
             </td>
             <td>

            <!-- Begin forum -->
            <p>
                <a href="{concat($xims_box,$goxims_content,$parent_path)}">Up</a>
                <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="5" height="10"/>
             |
             <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="5" height="10"/>
            <a>
                <xsl:attribute name="href">
                        <xsl:value-of select="concat($xims_box,$goxims_content)"/>
                        <xsl:call-template name="path2topics"/>
                </xsl:attribute>Overview of topics
            </a>
        </p>

          <table width="608" style="border: 1px solid #888888; margin-bottom: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
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
                        <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="forumcontent">
                        <xsl:apply-templates select="body"/>
                    </td>
                </tr>
            </table>

            <p>
                <a href="#reply">Reply</a>
            </p>
            <br />

        <xsl:if test="/document/objectlist/object">
                <p>
                Previous replies:<br/>
                <table>
                    <xsl:apply-templates select="/document/objectlist/object"/>
                </table>
                </p>
        </xsl:if>

        <xsl:call-template name="replyform"/>

        <!-- End forum -->
        <!-- Begin footer -->
            <xsl:call-template name="copyfooter"/>
        <!-- End footer -->

                </td>
           </tr>

    </table>
    </body>
</html>
</xsl:template>

<xsl:template match="/document/objectlist/object">
    <tr>
    <td>
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
            <xsl:apply-templates select="creation_timestamp" mode="datetime"/>)
        </xsl:when>
        <xsl:otherwise>
            <img src="{$ximsroot}images/icons/list_HTML.gif" alt="Discussion-Entry-Icon" width="20" height="18"/><xsl:value-of select="title"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="user_privileges/delete">
        <a href="{$xims_box}{$goxims_content}?id={@id};delete_prompt=1;">
            <img src="{$skimages}option_delete.png" border="0" width="37" height="19" title="delete" alt="delete"/>
        </a>
    </xsl:if>
    </td>
    </tr>
</xsl:template>


<xsl:template name="replyform">
    <a name="reply"/>
    <form name="replyform" action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=AnonDiscussionForumContrib" method="GET" onSubmit="return checkFields()">
        <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
        <table width="608" style="border: 1px solid #888888; margin-bottom: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
            <tr>
                <td class="forumhead" colspan="2">Reply</td>
            </tr>
            <tr>
                <td valign="middle" class="forumcontent">Title:</td>
                <td><input class="foruminput" type="text" name="title" size="33" value="Re: {title}"/></td>
            </tr>
            <tr>
                <td valign="middle" class="forumcontent">Author:</td>
                <td><input class="foruminput" type="text" name="author" size="33"/></td>
            </tr>
            <tr>
                <td valign="middle" class="forumcontent">Email:</td>
                <td><input class="foruminput" type="text" name="email" size="33"/></td>
            </tr>
            <tr>
                <td valign="middle" class="forumcontent"></td>
                <td>
                    <textarea class="foruminput" name="body" rows="10" cols="35"></textarea>
                    <input type="hidden" name="store" value="1"/><br/>
                </td>
            </tr>
      </table>
     <div align="center">
          <input type="submit" border="0" value="Send reply" name="submit" class="control" />
      </div>
  </form>
</xsl:template>

<xsl:template match="body">
    <xsl:call-template name="br-replace">
        <xsl:with-param name="word" select="."/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
