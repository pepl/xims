<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:template match="/document">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/User"/> - XIMS
            </title>
            <xsl:call-template name="css"/>
            <style type="text/css">span.cboxitem { width:180px;}</style>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="/document/context/user"/>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template match="user">
    <form name="userEdit" action="{$xims_box}{$goxims_users}" method="post">
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

                  <xsl:if test="/document/context/session/user/system_privileges/change_user_name = 1">
                      <tr>
                          <td>
                              <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                              <span class="compulsory"><xsl:value-of select="$i18n/l/Username"/></span>:</td>
                          <td><input size="30" maxlength="30" name="name" type="text" value="{name}"/></td>
                      </tr>
                  </xsl:if>

                  <xsl:if test="/document/context/session/user/system_privileges/change_user_fullname = 1">
                      <xsl:call-template name="usermeta"/>
                  </xsl:if>
                  <xsl:if test="/document/context/session/user/system_privileges/change_sysprivs_mask = 1">
                      <xsl:call-template name="system_privileges"/>
                  </xsl:if>
                  <xsl:if test="/document/context/session/user/system_privileges/set_admin_equ = 1">
                      <xsl:call-template name="user_isadmin"/>
                  </xsl:if>
                  <xsl:if test="/document/context/session/user/system_privileges/set_status = 1">
                      <xsl:call-template name="account_enabled"/>
                  </xsl:if>
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

