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
                <xsl:value-of select="$i18n_users/l/Role_Membership"/> '<xsl:value-of select="$name"/>'
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <br/>
        <table align="center" colspan="2" cellpadding="2" cellspacing="0" border="0">
          <tr>
            <td align="center" class="bluebg"><xsl:value-of select="$i18n_users/l/Role_Membership"/> '<xsl:value-of select="$name"/>'</td>
          </tr>
          <tr>
            <td>
                <a href="{$xims_box}{$goxims_users}?name={$name};manage_roles=1;explicit_only=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Manage_Existing_Roles"/></a>
            </td>
          </tr>
        </table>
        <br/><br/>
        <xsl:apply-templates select="userlist"/>
        </body>
    </html>

</xsl:template>

<xsl:template name="options">
   <!-- begin options bar -->
   <td width="250" align="left">
        <a href="{$xims_box}{$goxims_users}?name={$name};role={name};grant_role_update=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Grant_Role"/></a>
   </td>
   <!-- end options bar -->
</xsl:template>

</xsl:stylesheet>

