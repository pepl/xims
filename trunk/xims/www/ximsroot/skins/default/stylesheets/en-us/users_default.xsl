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

<xsl:template match="/document">
    <html>
        <head>
            <title>
                Manage Users and Roles - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <div align="center">
            <p>
                <a href="{$xims_box}{$goxims_users}?create=1">Create New User</a>
            </p>
        </div>

        <xsl:apply-templates select="userlist"/>
        </body>
    </html>

</xsl:template>

<xsl:template name="options">
   <!-- begin options bar -->
   <td width="400" align="right">
   <table width="400" cellpadding="0" cellspacing="2" border="0">
   <tr>
   <td><a href="{$xims_box}{$goxims_users}?edit=1;name={name}">Edit User</a></td>
   <td><a href="{$xims_box}{$goxims_users}?passwd=1;name={name}">Change Password</a></td>
   <td><a href="{$xims_box}{$goxims_users}?remove=1;name={name}">Delete User</a></td>
   <td><a href="{$xims_box}{$goxims_users}?name={name};manage_roles=1;explicit_only=1">Role Membership</a></td>
   </tr>
   </table>
   </td>
   <!-- end options bar -->
</xsl:template>

</xsl:stylesheet>

