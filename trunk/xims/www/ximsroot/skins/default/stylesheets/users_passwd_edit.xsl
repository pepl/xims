<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/document">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n_users/l/Changing_Password"/> '<xsl:value-of select="$name"/>'
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

       <!-- begin main content -->
        <form name="userEdit" action="{$xims_box}{$goxims_users}" method="POST">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
            <tr background="{$skimages}generic_tablebg_1x20.png">
              <td>&#160;</td>
            </tr>
            <tr>
              <td align="center">

              <br />
              <!-- begin widget table -->
              <table cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td colspan="2">
                  <xsl:call-template name="message"/>
                </td>
              </tr>
              <tr><td><br/></td></tr>
                <tr>
                  <td align="center" class="bluebg" colspan="2">
                    <xsl:value-of select="$i18n_users/l/Changing_Password"/> '<xsl:value-of select="$name"/>'
                  </td>
                </tr>

                <tr>
                  <td colspan="2"><xsl:call-template name="marked_mandatory"/></td>
                </tr>
                <tr>
                  <td>
                      <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                      <span class="compulsory"><xsl:value-of select="$i18n_users/l/New_System_Password"/>:</span>
                  </td>
                  <td><input name="password1" type="password" value=""/></td>
                </tr>
                <tr>
                  <td>
                      <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                      <span class="compulsory"><xsl:value-of select="$i18n_users/l/Confirm_Password"/>:</span>
                  </td>
                  <td><input name="password2" type="password" value=""/></td>
                </tr>

                <xsl:call-template name="exitform">
                    <xsl:with-param name="action" select="'passwd_update'"/>
                </xsl:call-template>

              </table>
              <!-- end widget table -->
              <br />

              </td>
            </tr>
        </table>
        </form>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

