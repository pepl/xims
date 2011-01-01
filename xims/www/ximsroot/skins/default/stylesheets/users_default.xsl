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

<xsl:template match="/document">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <table width="100%" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <td class="bluebg" align="center">
                    <xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/>
                </td>
            </tr>
            <xsl:call-template name="create_manage_accounts"/>
        </table>

        <table width="100%" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <td>
                    <xsl:apply-templates select="userlist"/>
                </td>
            </tr>
        </table>
        <xsl:call-template name="script_bottom"/>
              <xsl:comment>[if lte IE 6]&gt;
                    &lt;script type="text/javascript"&gt;
                         $(function() {
                             $('.objrow').hover(function(){
                                 $(this).children('td').addClass('objrow-over');
                             }, function() {
                                $(this).children('td').removeClass('objrow-over');
                             });
                         });
                     &lt;/script&gt;
                 &lt;![endif]</xsl:comment>
    </body>
</html>
</xsl:template>

<xsl:template name="options">
   <!-- begin options bar -->
   <td width="500" align="right">
   <table width="500" cellpadding="0" cellspacing="2" border="0">
   <tr>
   <td><a href="{$xims_box}{$goxims_users}?edit=1;name={name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/edit"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?passwd=1;name={name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Change_password"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?remove=1;name={name};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/delete"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?name={name};manage_roles=1;explicit_only=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Role_membership"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?name={name};bookmarks=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Bookmarks"/></a></td>
   <td><a href="{$xims_box}{$goxims_users}?name={name};objecttypeprivs=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></a></td>
   </tr>
   </table>
   </td>
   <!-- end options bar -->
</xsl:template>

</xsl:stylesheet>

