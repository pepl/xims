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
  <xsl:import href="../../../stylesheets/anondiscussionforum_common.xsl"/>

  <xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
  </xsl:template>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head-create_discussionforum"/>
      <body onLoad="document.eform.body.value='';document.eform.title.focus()"
            margintop="0"
            marginleft="0"
            marginwidth="0"
            marginheight="0"
            background="{$skimages}body_bg.png">
        <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;" >
          <input type="hidden" name="objtype" value="{$objtype}"/>
          <input type="hidden" name="parid" value="{@id}" />
          <table border="0" width="770" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
            <tr>
              <td valign="top" class="forumhead" colspan="2"><xsl:value-of select="$i18n/l/Create_topic"/></td>
            </tr>
            <tr>
              <td valign="middle" class="forumcontent" width="80"><xsl:value-of select="$i18n/l/Topic"/>:</td>
              <td><input type="text" name="title" size="60"/></td>
            </tr>
            <tr>
              <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Author"/>:</td>
              <td><input type="text" name="author" size="30"/></td>
            </tr>
            <tr>
              <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Email"/>:</td>
              <td><input type="text" name="email" size="30"/></td>
            </tr>
            <tr>
              <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Coauthor"/>:</td>
              <td><input type="text" name="coauthor" size="30"/></td>
            </tr>
            <tr>
              <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Coauthor"/>&#160;<xsl:value-of select="$i18n/l/Email"/>:</td>
              <td><input type="text" name="coemail" size="30"/></td>
            </tr>
            <tr>
              <td valign="top" class="forumcontent" style="padding-top:3px;"><xsl:value-of select="$i18n/l/Text"/>:</td>
              <td>
                <textarea name="body" rows="20" cols="70"><xsl:text>&#160;</xsl:text></textarea>
              </td>
            </tr>
          </table>
          <br />
          <p style="margin-left:380px;">
            <xsl:call-template name="saveaction"/>
          </p>
        </form>
        <xsl:call-template name="cancelaction"/>
      </body>
    </html>
  </xsl:template>


<xsl:template name="head-create_discussionforum">
    <head>
        <title><xsl:value-of select="$i18n/l/Create_topic"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

</xsl:stylesheet>
