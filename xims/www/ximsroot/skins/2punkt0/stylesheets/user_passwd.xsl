<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_passwd.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>
<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document">
    <html>
    <xsl:call-template name="head_default">
			<xsl:with-param name="mode">user</xsl:with-param>
    </xsl:call-template>
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
<div id="table-container">
        <form name="userEdit" action="{$xims_box}{$goxims}/user" method="post">

              <p>
                <xsl:call-template name="message"/>
              </p>

                <h1 class="bluebg">
                <xsl:value-of select="$i18n/l/ChangePwdFor"/>&#160;'<xsl:value-of select="/document/context/session/user/name"/>'
                </h1>
                <p>
										<div id="label-oldpwd"><label for="input-oldpwd"><xsl:value-of select="$i18n/l/OldPwd"/></label></div>
										<input name="password" type="password" value="" id="input-oldpwd"/><br/>
										</p>
										<p>
                    <div id="label-newpwd"><label for="input-newpwd" class="label-newpwd"><xsl:value-of select="$i18n/l/NewPwd"/></label></div>
                    <input name="password1" type="password" value="" id="input-newpwd"/><br/>
                    </p>
                    <p>
                    <div id="label-confirmpwd"><label for="input-confirmpwd" class="label-confirmpwd"><xsl:value-of select="$i18n/l/ConfirmPwd"/></label></div>
                    <input name="password2" type="password" value="" id="input-confirmpwd"/><br/>
                    </p>
<br/><br/>
                        <input name="passwd_update" type="submit" class="ui-state-default ui-corner-all fg-button">
														<xsl:attribute name="value"><xsl:value-of select="$i18n/l/save"/></xsl:attribute>                        
                        </input>
													&#160;
                        <input name="cancel" type="button" class="ui-state-default ui-corner-all fg-button" onclick="javascript:history.go(-1)">
													<xsl:attribute name="value"><xsl:value-of select="$i18n/l/cancel"/></xsl:attribute></input>
                        <a href="{$xims_box}{$goxims}/user" class="ui-state-default ui-corner-all fg-button"><xsl:value-of select="$i18n/l/cancel"/></a>
        </form>
        </div>
        </body>
    </html>
</xsl:template>

        <xsl:template name="title-userpage">
                <xsl:value-of select="$i18n/l/ChangingPassword"/> - XIMS
        </xsl:template>
</xsl:stylesheet>

