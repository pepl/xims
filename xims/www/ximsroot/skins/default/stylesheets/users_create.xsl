<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:param name="name"/>

<xsl:template match="/document">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n_users/l/Create_account"/> - XIMS
            </title>
            <xsl:call-template name="css"/>
            <style type="text/css">span.cboxitem { width:180px;}</style>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <form name="userAdd" action="{$xims_box}{$goxims_users}" method="post">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
            <tr style="background:url('{$skimages}generic_tablebg_1x20.png');">
              <td>&#160;</td>
            </tr>
            <tr>
              <td align="center">

              <br />
              <!-- begin widget table -->
              <table cellpadding="2" cellspacing="0" border="0">
                <xsl:if test="/document/context/session/warning_msg != ''">
                    <tr>
                        <td colspan="2" align="center">
                            <div style="margin-bottom: 5px">
                                <xsl:call-template name="message"/>
                            </div>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                  <td align="center" class="bluebg" colspan="2"><xsl:value-of select="$i18n_users/l/Create_account"/></td>
                </tr>
                <tr>
                  <td colspan="2"><xsl:call-template name="marked_mandatory"/></td>
                </tr>
                <tr>
                  <td>
                      <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                      <span class="compulsory"><xsl:value-of select="$i18n/l/Username"/>:</span>
                  </td>
                  <td><input size="30" maxlength="30" name="name" type="text" value="{$name}"/></td>
                </tr>
                <tr>
                  <td>
                      <span><xsl:value-of select="$i18n_users/l/Password"/>:</span>
                  </td>
                  <td><input size="30" maxlength="32" name="password1" type="password" value=""/></td>
                </tr>
                <tr>
                  <td>
                      <span><xsl:value-of select="$i18n_users/l/Confirm_Password"/>:</span>
                  </td>
                  <td><input size="30" maxlength="32" name="password2" type="password" value=""/></td>
                </tr>

                <xsl:call-template name="usermeta"/>
                <xsl:call-template name="system_privileges"/>

                <tr>
                  <td><xsl:value-of select="$i18n_users/l/Account_is_Role"/>:</td>
                  <td>
                      <input name="object_type" type="radio" value="role">
                        <xsl:if test="$object_type = 'role'">
                          <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                      </input><xsl:value-of select="$i18n/l/Yes"/>
                      <input name="object_type" type="radio" value="user">
                        <xsl:if test="$object_type != 'role'">
                          <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                      </input><xsl:value-of select="$i18n/l/No"/>
                  </td>
                </tr>

                <xsl:call-template name="user_isadmin"/>
                <xsl:call-template name="account_enabled"/>

                <xsl:call-template name="exitform">
                    <xsl:with-param name="action" select="'create_update'"/>
                </xsl:call-template>

              </table>
              <!-- end widget table -->
              <br />

              </td>
            </tr>
        </table>
        </form>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

