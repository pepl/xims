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
<xsl:import href="default_header.xsl"/>
<xsl:import href="../../../../../stylesheets/config.xsl"/>
<xsl:import href="../../../../../anondiscussionforum_common.xsl"/>
<xsl:output method="html" encoding="ISO-8859-1"/>
<xsl:param name="request.uri"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

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
                  <td class="links" colspan="5">
             
               <!-- Begin Search -->
                <xsl:call-template name="search"/>
               <!-- End Search -->
             
              <!-- Begin Standard Links -->
                <xsl:call-template name="stdlinks"/>
              <!-- End Standard Links -->

              <!-- Begin Department Links -->
                <xsl:call-template name="deptlinks"/>
              <!-- End Department Links -->

              <!-- Begin Document Links -->
              <!-- End Document Links -->

             </td>           
             <td class="content" colspan="16">
               
              <!-- Begin forum -->
    <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=anondiscussionforumcontrib" method="POST">
        <table border="0" width="600" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
        <tr>
                    <td valign="top" class="forumhead" colspan="2">Neues Thema erstellen:</td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent" width="80"><span class="compulsory">Thema</span></td>
                    <td><input type="text" class="text" name="title" size="60"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent"><span class="compulsory">Autor</span></td>
                    <td><input type="text" class="text" name="author" size="40"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent">Email</td>
                    <td><input type="text" class="text" name="email" size="40"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent">Co-Autor</td>
                    <td><input type="text" class="text" name="coauthor" size="40"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent">Co-Autor-Email</td>
                    <td><input type="text" class="text" name="coemail" size="40"/></td>
            </tr>
             <tr>
                    <td valign="top" class="forumcontent" style="padding-top:3px;"><span class="compulsory">Text</span></td>
                    <td>
                        <textarea class="text" name="body" rows="20" cols="50"><xsl:text>&#160;</xsl:text></textarea>
                        <input type="hidden" name="parid" value="{@document_id}"/>
                        <input type="hidden" name="store" value="1"/><br/>
                    </td>
                </tr>
        </table>
        <br/>
        <p>
            <input type="submit" name="submit" value="Speichern" class="control"/>
        </p>   
      </form>
      
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST">
            <input type="submit" name="cancel_create" value="Abbrechen" class="control"/>
        </form>

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



<xsl:template match="children/object">
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
            <xsl:apply-templates select="creation_time" mode="datetime"/>)
        </xsl:when>
        <xsl:otherwise>
            <img src="{$ximsroot}images/icons/list_HTML.gif" alt="Discussion-Entry-Icon" width="20" height="18"/><xsl:value-of select="title"/>
        </xsl:otherwise>
    </xsl:choose>
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
                    <input type="hidden" name="parid" value="{/document/context/object/@document_id}"/>
                    <input type="hidden" name="store" value="1"/><br/>
                </td>
            </tr>
      </table>
     <div align="center">
          <input type="submit" border="0" value="Send reply" name="submit" class="control" />
      </div>
  </form>
</xsl:template>


<xsl:template name="path2topics">
    <xsl:for-each select="parents/object[object_type != 16]">
            <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
