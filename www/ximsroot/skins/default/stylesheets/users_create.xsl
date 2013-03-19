<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_create.xsl 2246 2009-08-06 11:52:16Z haensel $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:param name="name"/>

<xsl:template match="/document">
	<html>
	<xsl:call-template name="head_default"><xsl:with-param name="mode">user</xsl:with-param></xsl:call-template>
	<body>
		<xsl:call-template name="header">
			<xsl:with-param name="noncontent">true</xsl:with-param>
		</xsl:call-template>
		
		<div id="content-container">
			<form name="userAdd" action="{$xims_box}{$goxims_users}" method="post">
				<xsl:if test="/document/context/session/warning_msg != ''">
					<div>
						<xsl:call-template name="message"/>
					</div>
				</xsl:if>

				<h1 class="bluebg"><xsl:value-of select="$i18n_users/l/Create_account"/></h1>
				<div class="form-div">
				<div>
					<div class="label-med"><label for="acc-name"> <xsl:value-of select="$i18n/l/Username"/>*:</label></div>
					<input size="30" maxlength="30" name="name" type="text" value="{$name}" id="acc-name"/>
				</div>
				<div>
					<div class="label-med"><label for="acc-pwd"><xsl:value-of select="$i18n_users/l/Password"/>:</label></div>
					<input size="30" maxlength="32" name="password1" type="password" value="" id="acc-pwd"/>
				</div>
				<div>
					<div class="label-med"><label for="acc-confpwd"><xsl:value-of select="$i18n_users/l/Confirm_Password"/>:</label></div>
					<input size="30" maxlength="32" name="password2" type="password" value="" id="acc-confpwd"/>
				</div>
			</div>
                <xsl:call-template name="usermeta"/>
                <br/>
                <xsl:call-template name="system_privileges"/>

	<div class="form-div">
		<div>
			<fieldset>
			<legend class="label-med"><xsl:value-of select="$i18n_users/l/Account_is_Role"/>:</legend>
				<input name="object_type" type="radio" value="role" class="radio-button" id="acc-isrole-true">
					<xsl:if test="$object_type = 'role'">
					<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="acc-isrole-true"><xsl:value-of select="$i18n/l/Yes"/></label>
				<input name="object_type" type="radio" value="user" class="radio-button" id="acc-isrole-false">
				<xsl:if test="$object_type != 'role'">
				<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
				</input>
				<label for="acc-isrole-false"><xsl:value-of select="$i18n/l/No"/></label>
			</fieldset>
		</div>
		<xsl:call-template name="user_isadmin"/>
		<xsl:call-template name="account_enabled"/>
	</div>

                <xsl:call-template name="exitform">
                    <xsl:with-param name="action" select="'create_update'"/>
                </xsl:call-template>

        </form>
        </div>
		<xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template name="title-userpage"><xsl:value-of select="$i18n_users/l/Create_account"/> - XIMS</xsl:template>

</xsl:stylesheet>

