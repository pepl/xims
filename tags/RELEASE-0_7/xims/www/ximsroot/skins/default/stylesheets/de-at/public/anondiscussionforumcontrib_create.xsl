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
    <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=AnonDiscussionForumContrib" method="POST">
        <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
        <input type="hidden" name="parid" value="{@id}" />
        <table border="0" width="600" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
        <tr>
                    <td valign="top" class="forumhead" colspan="2">Create new Topic</td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent" width="80"><span class="compulsory">Topic</span></td>
                    <td><input type="text" class="text" name="title" size="60"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent"><span class="compulsory">Author</span></td>
                    <td><input type="text" class="text" name="author" size="40"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent">Email</td>
                    <td><input type="text" class="text" name="email" size="40"/></td>
            </tr>
            <tr>
                    <td valign="middle" class="forumcontent">Co-Author</td>
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
                        <input type="hidden" name="store" value="1"/><br/>
                    </td>
                </tr>
        </table>
        <br/>
        <p>
            <input type="submit" name="submit" value="Save" class="control"/>
        </p>
      </form>

        <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST">
            <input type="submit" name="cancel_create" value="Cancel" class="control"/>
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

</xsl:stylesheet>
