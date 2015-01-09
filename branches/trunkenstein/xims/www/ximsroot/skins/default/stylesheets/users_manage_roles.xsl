<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_manage_roles.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:param name="explicit_only"/>

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
			<h1 class="bluebg"><xsl:value-of select="$i18n_users/l/Role_Membership"/> '<xsl:value-of select="$name"/>'</h1>
			<p>
				<a class="button" href="{$xims_box}{$goxims_users}?name={$name}&amp;grant_role=1&amp;sort-by={$sort-by}&amp;order-by={$order-by}&amp;userquery={$userquery}&amp;object_type=1"><xsl:value-of select="$i18n_users/l/Grant_Role"/></a>
				<!--&#160;<xsl:value-of select="$i18n/l/or"/>&#160;
				<a href="{$xims_box}{$goxims_users}?sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/go_back"/></a>-->
			</p>
			<p>
				<xsl:choose>
					<xsl:when test="$explicit_only = '1'">
						<a class="button" href="{$xims_box}{$goxims_users}?name={$name}&amp;manage_roles=1&amp;sort-by={$sort-by}&amp;order-by={$order-by}&amp;userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Show_implicitly_granted"/></a>
					</xsl:when>
					<xsl:otherwise>
						<a class="button" href="{$xims_box}{$goxims_users}?name={$name}&amp;manage_roles=1&amp;explicit_only=1&amp;sort-by={$sort-by}&amp;order-by={$order-by}&amp;userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Show_explicitly_granted"/></a>
					</xsl:otherwise>
				</xsl:choose>
			</p>
			<br/>
			<xsl:apply-templates select="userlist"/>
			<br/>
			<a class="button" href="{$xims_box}{$goxims_users}?sort-by={$sort-by}&amp;order-by={$order-by}&amp;userquery={$userquery}"><xsl:value-of select="$i18n/l/cancel"/></a>
		</div>
		<xsl:call-template name="script_bottom"/>
	</body>
	</html>

</xsl:template>

<xsl:template name="options">
    <!-- begin options bar -->
    <!--<td width="250" align="left">-->
	<td>
        <xsl:if test="$explicit_only = '1'">
            <a class="button" href="{$xims_box}{$goxims_users}?name={$name}&amp;role={name}&amp;revoke_role=1&amp;sort-by={$sort-by}&amp;order-by={$order-by}&amp;userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Revoke_Role_Grant"/></a>
        </xsl:if>
    </td>
    <!-- end options bar -->
</xsl:template>

<xsl:template name="title-userpage">
<xsl:value-of select="$i18n_users/l/Role_Membership"/> '<xsl:value-of select="$name"/>' - XIMS
</xsl:template>

</xsl:stylesheet>

