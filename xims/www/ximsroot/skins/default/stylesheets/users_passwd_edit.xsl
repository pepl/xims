<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_passwd_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

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
		<form name="userEdit" action="{$xims_box}{$goxims_users}" method="post">
	
			<p><xsl:call-template name="message"/></p>
			<h1 class="bluebg"><xsl:value-of select="$i18n/l/ChangePwdFor"/> '<xsl:value-of select="$name"/>'</h1>
	
			<div class="form-div">
				<div>
					<div class="label-med"><label for="input-newpwd" class="label-newpwd"><xsl:value-of select="$i18n/l/NewPwd"/></label></div>
					<input name="password1" type="password" value="" id="input-newpwd"/>
				</div>
				<div>
					<div class="label-med"><label for="input-confirmpwd" class="label-confirmpwd"><xsl:value-of select="$i18n/l/ConfirmPwd"/></label></div>
					<input name="password2" type="password" value="" id="input-confirmpwd"/><br/>
				</div>
			</div>
			<xsl:call-template name="exitform">
				<xsl:with-param name="action" select="'passwd_update'"/>
			</xsl:call-template>
		</form>
		<xsl:call-template name="script_bottom"/>
	</div>
</body>
</html>
</xsl:template>

        <xsl:template name="title-userpage">
                <xsl:value-of select="$i18n/l/ChangingPassword"/> - XIMS
        </xsl:template>
        
</xsl:stylesheet>

