<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="users_common.xsl"/>

<xsl:template match="/document">
    <!--<html>
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/User"/> - XIMS
            </title>
            <xsl:call-template name="css"/>
            <style type="text/css">span.cboxitem { width:180px;}</style>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>-->
		<html>
	<xsl:call-template name="head_default"><xsl:with-param name="mode">user</xsl:with-param></xsl:call-template>
	<body>
		<xsl:call-template name="header">
			<xsl:with-param name="noncontent">true</xsl:with-param>
		</xsl:call-template>
		
		<div id="content-container">
			<h1 class="bluebg"><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$i18n/l/User"/><!--<xsl:value-of select="$i18n_users/l/Edit_account"/>--></h1>
        <xsl:apply-templates select="/document/context/user"/>
		 </div>
		<xsl:call-template name="script_bottom"/>
        </body>
        <!--<xsl:call-template name="script_bottom"/>
        </body>-->
    </html>
</xsl:template>

<xsl:template match="user">
    <form name="userEdit" action="{$xims_box}{$goxims_users}" method="post">

				<div class="form-div block">
					<div>
                <div class="label-med">ID:</div>
                <xsl:value-of select="@id"/>
                </div>

                  
                      <div>
                <div class="label-med"><label for="name"><xsl:value-of select="$i18n/l/Username"/></label>*:</div>
                  <input size="30" maxlength="30" id="name" name="name" type="text" value="{name}">
                  	<xsl:if test="/document/context/session/user/system_privileges/change_user_name != 1">
                  		<xsl:attribute name="readonly">readonly</xsl:attribute>
					</xsl:if>
                  </input>
				</div>
                  

                  <xsl:if test="/document/context/session/user/system_privileges/change_user_fullname = 1">
                      <xsl:call-template name="usermeta"/>
                  </xsl:if>
				  </div>
				  <div class="form-div">
                  <xsl:if test="/document/context/session/user/system_privileges/change_sysprivs_mask = 1">
                      <xsl:call-template name="system_privileges"/>
                  </xsl:if>
				  </div>
				  <div class="form-div">
                  <xsl:if test="/document/context/session/user/system_privileges/set_admin_equ = 1">
                      <xsl:call-template name="user_isadmin"/>
                  </xsl:if>
                  <xsl:if test="/document/context/session/user/system_privileges/set_status = 1">
                      <xsl:call-template name="account_enabled"/>
                  </xsl:if>
				  </div>
                <xsl:call-template name="exitform">
                    <xsl:with-param name="action" select="'update'"/>
                </xsl:call-template>

    </form>
</xsl:template>

</xsl:stylesheet>

