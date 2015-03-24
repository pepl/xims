<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_remove.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:template match="/document">
    <html>
    	<xsl:call-template name="head_default"><xsl:with-param name="mode">user</xsl:with-param></xsl:call-template>
        <!--<head>
            <title>
                <xsl:value-of select="$i18n_users/l/Confirm_User_Deletion"/> - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>-->
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
		
		<div id="content-container">
        <form name="userRemove" action="{$xims_box}{$goxims_users}" method="post">
          <xsl:call-template name="input-token"/>
                  <h1 class="bluebg"><xsl:value-of select="$i18n_users/l/Confirm_User_Deletion"/></h1>
	<p><xsl:value-of select="$i18n/l/AboutDeletionUser"/> '<xsl:value-of select="$name"/>' <xsl:value-of select="$i18n/l/AboutDeletion2"/>.</p>
            <p>
                <strong><xsl:value-of select="$i18n/l/WarnNoUndo"/></strong>
            </p>
            <p>
            <xsl:value-of select="$i18n/l/ClickCancelConf"/>
            </p>

        <xsl:call-template name="exitform">
            <xsl:with-param name="action" select="'remove_update'"/>
            <xsl:with-param name="save" select="$i18n/l/Confirm"/>
        </xsl:call-template>

        </form>
		</div>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template name="title-userpage"><xsl:value-of select="$i18n_users/l/Confirm_User_Deletion"/> - XIMS</xsl:template>

</xsl:stylesheet>

