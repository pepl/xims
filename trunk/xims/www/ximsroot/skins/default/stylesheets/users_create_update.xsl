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

<xsl:template match="/document">
<html>
    <xsl:call-template name="head_default"/>
    <body>
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
            <td class="bluebg"><xsl:value-of select="$i18n/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/></td>
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
                <input class="control" name="grant_role" type="submit" value="{$i18n/l/Grant_role}"/>
                <input class="control" name="exit" type="submit" value="{$i18n/l/cancel}"/>
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

