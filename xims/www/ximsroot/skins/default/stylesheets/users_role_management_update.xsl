<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_role_management_update.xsl 2188 2009-01-03 18:24:00Z pepl $
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
				<div class="table-container">
        <form name="userConfirm" action="{$xims_box}{$goxims_users}" method="get">

                <h1 class="bluebg"><xsl:value-of select="$i18n_users/l/User_Updated"/></h1>

                <p><xsl:call-template name="message"/></p>
                    <input type="hidden" name="explicit_only" value="1"/>
                    <input type="hidden" name="name" value="{$name}"/>
                    <input type="hidden" name="manage_roles" value="1"/>
                    <xsl:call-template name="doneform"/>
        </form>
        </div>
        </body>
    </html>
</xsl:template>

<xsl:template name="title-userpage">
	<xsl:value-of select="$i18n_users/l/User_Updated"/> - XIMS
</xsl:template>

</xsl:stylesheet>
