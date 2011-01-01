<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_remove.xsl 2188 2009-01-03 18:24:00Z pepl $
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
                <xsl:value-of select="$i18n_users/l/Confirm_User_Deletion"/> - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <form name="userRemove" action="{$xims_box}{$goxims_users}" method="post">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
            <tr background="{$skimages}generic_tablebg_1x20.png">
              <td>&#160;</td>
            </tr>
            <tr>
              <td align="center">

              <br />
              <!-- begin widget table -->
              <table width="300" cellpadding="2" cellspacing="0" border="0">
                <tr>
                  <td class="bluebg"><xsl:value-of select="$i18n_users/l/Confirm_User_Deletion"/></td>
                </tr>
                <tr>
                  <td>&#160;</td>
                </tr>

                <xsl:call-template name="confirm_user_deletion"/>

              </table>
              <!-- end widget table -->

              </td>
            </tr>
        </table>
        </form>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

