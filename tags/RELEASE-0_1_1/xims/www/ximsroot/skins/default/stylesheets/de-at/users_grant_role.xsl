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
<xsl:import href="users_common.xsl"/>
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
<xsl:param name="name"/>

<xsl:template match="/document">
    <html>
        <head>
            <title>
                <xsl:value-of select="title" /> - XIMS
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
            <td align="center" class="bluebg">Role Membership for user '<xsl:value-of select="$name"/>'</td>
          </tr>
          <tr>
            <td>
                <a href="{$xims_box}{$goxims_users}?name={$name};manage_roles=1;explicit_only=1">Manage existing Roles</a>
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
   <td width="250" align="right">
   <table width="250" cellpadding="0" cellspacing="2" border="0">
   <tr>
   <td colspan="3">
        <a href="{$xims_box}{$goxims_users}?name={$name};role={name};grant_role_update=1">Grant Role</a>
    </td>
   </tr>
   </table>
   </td>
   <!-- end options bar -->
</xsl:template>

</xsl:stylesheet>

