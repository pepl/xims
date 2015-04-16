<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
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
				<a href="{$xims_box}{$goxims_users}?name={$name}&amp;manage_roles=1&amp;explicit_only=1&amp;sort-by={$sort-by}&amp;order-by={$order-by}&amp;userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Manage_Existing_Roles"/></a>
	
				<xsl:apply-templates select="userlist"/>
			</div>
			<xsl:call-template name="script_bottom"/>
		</body>
	</html>
</xsl:template>

<xsl:template name="options">
  <td>
    <form action="{$xims_box}{$goxims_users}" method="post">
      <xsl:call-template name="input-token"/>
      <input type="hidden" name="name" value="{$name}"/>
      <input type="hidden" name="role" value="{name}"/>
      <input type="hidden" name="sort-by" value="{$sort-by}"/>
      <input type="hidden" name="order-by" value="{$order-by}"/>
      <input type="hidden" name="userquery" value="{$userquery}"/>
      <button class="button"
              type="submit"
              name="grant_role_update">
        <xsl:value-of select="$i18n_users/l/Grant_Role"/>
      </button>
    </form>
	</td>
</xsl:template>

</xsl:stylesheet>

