<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/document">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/User"/>
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <style type="text/css">span.cboxitem { width:180px;}</style>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="/document/context/user"/>
        </body>
    </html>
</xsl:template>

<xsl:template match="user">
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
                  <td align="center" class="bluebg" colspan="2">
                      <xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/User"/>
                  </td>
                </tr>
                <tr>
                  <td>ID:</td>
                  <td><xsl:value-of select="@id"/></td>
                </tr>
                <tr>
                  <td>
                      <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                      <span class="compulsory"><xsl:value-of select="$i18n/l/Username"/></span>:</td>
                  <td><input size="30" maxlength="30" name="name" type="text" value="{name}"/></td>
                </tr>

                <xsl:call-template name="usermeta"/>
                <xsl:call-template name="system_privileges"/>
                <xsl:call-template name="user_isadmin"/>
                <xsl:call-template name="account_enabled"/>

                <xsl:call-template name="exitform">
                    <xsl:with-param name="action" select="'update'"/>
                </xsl:call-template>

              </table>
              <!-- end widget table -->
              <br />

              </td>
            </tr>
        </table>
    </form>
</xsl:template>

</xsl:stylesheet>
