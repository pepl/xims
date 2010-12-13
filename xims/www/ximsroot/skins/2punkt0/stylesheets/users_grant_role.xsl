<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_grant_role.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:template match="/document">
	<html>
		<xsl:call-template name="head_default">
				<xsl:with-param name="mode">mg-acl</xsl:with-param>
		</xsl:call-template>
		<body>
			<xsl:call-template name="header">
				<xsl:with-param name="noncontent">true</xsl:with-param>
			</xsl:call-template>
			<div id="content-container">
				<h1 class="bluebg">
					<xsl:value-of select="$i18n_users/l/Role_Membership"/> '<xsl:value-of select="$name"/>'
				</h1>
				<a href="{$xims_box}{$goxims_users}?name={$name};manage_roles=1;explicit_only=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Manage_Existing_Roles"/></a>
	
				<xsl:apply-templates select="userlist"/>
			</div>
			<xsl:call-template name="script_bottom"/>
		</body>
	</html>
</xsl:template>

<xsl:template name="options">
	<td>
		<a class="button" href="{$xims_box}{$goxims_users}?name={$name};role={name};grant_role_update=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Grant_Role"/></a>
	</td>
</xsl:template>

</xsl:stylesheet>

