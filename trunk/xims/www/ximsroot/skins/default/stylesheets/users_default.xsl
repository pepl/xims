<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/document">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <div align="center" style="margin: 5px 5px 0 0">
            <p>
                <a href="{$xims_box}{$goxims_users}?create=1"><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$i18n/l/User"/></a>
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
   <td><a href="{$xims_box}{$goxims_users}?edit=1;name={name}"><xsl:value-of select="$i18n/l/edit"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?passwd=1;name={name}"><xsl:value-of select="$i18n/l/Change_password"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?remove=1;name={name}"><xsl:value-of select="$i18n/l/delete"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?name={name};manage_roles=1;explicit_only=1"><xsl:value-of select="$i18n/l/Role_membership"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?name={name};bookmarks=1"><xsl:value-of select="$i18n/l/Bookmarks"/></a></td>
   </tr>
   </table>
   </td>
   <!-- end options bar -->
</xsl:template>

</xsl:stylesheet>

