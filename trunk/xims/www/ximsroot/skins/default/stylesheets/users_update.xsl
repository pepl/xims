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
                <xsl:value-of select="$i18n_users/l/User_Updated"/>
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <form name="userConfirm" action="{$xims_box}{$goxims_users}" method="GET">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr background="{$skimages}generic_tablebg_1x20.png">
            <td>&#160;</td>
          </tr>
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table width="200" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg"><xsl:value-of select="$i18n_users/l/User_Updated"/></td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td><xsl:call-template name="message"/></td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td align="center">
                    <xsl:call-template name="doneform"/>
                </td>
              </tr>
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

