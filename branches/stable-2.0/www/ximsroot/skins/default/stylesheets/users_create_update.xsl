<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_create_update.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:template match="/document">
<html>
    <xsl:call-template name="head_default"/>
    <body>
    <xsl:call-template name="header">
        <xsl:with-param name="noncontent">true</xsl:with-param>
    </xsl:call-template>

    <form name="userConfirm" action="{$xims_box}{$goxims_users}" method="get">
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
            <td class="bluebg"><xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/></td>
            </tr>
            <tr>
            <td>&#160;</td>
            </tr>
            <tr>
            <td>
                <span class="message">
                <xsl:choose>
                    <xsl:when test="/document/userlist/user/object_type='0'">
                        <xsl:value-of select="$i18n/l/User"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$i18n/l/Role"/>
                    </xsl:otherwise>
                </xsl:choose>
                '<xsl:value-of select="/document/userlist/user/name"/>' <xsl:value-of select="$i18n/l/created"/>.
                </span>
            </td>
            </tr>
            <tr>
            <td>&#160;</td>
            </tr>
            <tr>
            <td align="center">
                <input name="name" type="hidden" value="{/document/userlist/user/name}"/>
                <input class="control" name="grant_role" type="submit" value="{$i18n_users/l/Grant_Role}"/>
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
    <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

</xsl:stylesheet>

