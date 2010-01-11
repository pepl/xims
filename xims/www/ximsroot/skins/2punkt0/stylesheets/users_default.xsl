<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:template match="/document">
<html>
    <xsl:call-template name="head_default">
			<xsl:with-param name="mode">user</xsl:with-param>
    </xsl:call-template>
    <body>
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <div id="content-container">

                <h1 class="bluebg">
                    <xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/>
                </h1>
            <xsl:call-template name="create_manage_accounts"/>

        <table>
            <tr>
                <td>
                    <xsl:apply-templates select="userlist"/>
                </td>
            </tr>
        </table>
        </div>
    </body>
</html>
</xsl:template>

<xsl:template name="options">
   <!-- begin options bar -->
   <td>
   <a class="sprite sprite-option_edit" href="{$xims_box}{$goxims_users}?edit=1;name={name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><span><xsl:value-of select="$i18n/l/edit"/></span>&#160;</a>
   <a href="{$xims_box}{$goxims_users}?passwd=1;name={name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Change_password"/></a>&#160;
   <a class="sprite sprite-option_purge" href="{$xims_box}{$goxims_users}?remove=1;name={name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><span><xsl:value-of select="$i18n/l/delete"/></span>&#160;</a>
   <a href="{$xims_box}{$goxims_users}?name={name};manage_roles=1;explicit_only=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Role_membership"/></a>&#160;
   <a href="{$xims_box}{$goxims_users}?name={name};bookmarks=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Bookmarks"/></a>&#160;
   <a href="{$xims_box}{$goxims_users}?name={name};objecttypeprivs=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></a>&#160;
   </td>
   <!-- end options bar -->
</xsl:template>

</xsl:stylesheet>
