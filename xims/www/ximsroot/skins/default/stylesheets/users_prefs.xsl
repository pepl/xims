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
<html>
	<xsl:call-template name="head_default"><xsl:with-param name="mode">user</xsl:with-param></xsl:call-template>
	<body>
		<xsl:call-template name="header">
			<xsl:with-param name="noncontent">true</xsl:with-param>
		</xsl:call-template>
		
		<div id="content-container">
			<h1 class="bluebg"><xsl:value-of select="$i18n/l/ManagePersonalSettings"/>&#160;<xsl:value-of select="$i18n/l/of"/>&#160;<xsl:value-of select="$i18n/l/User"/>&#160;<xsl:value-of select="context/user/name"/></h1>
			<!--<xsl:apply-templates select="/document/context/user"/>-->
			
			<form name="userEdit" 
                  action="{$xims_box}{$goxims}/userprefs"
                  method="post" 
                  id="create-edit-form">
              <xsl:call-template name="input-token"/>
				<!--
				<strong><xsl:value-of select="$i18n/l/SelectSkin"/></strong><br/>
				<input type="radio" id="skin_def" class="radio-button" name="skin" value="default">
					<xsl:if test="userprefs/skin = 'default'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
				</input>
				<label for="skin_def">default</label> <br/>
				<input type="radio" id="skin_2p0" class="radio-button" name="skin" value="2punkt0">
					<xsl:if test="userprefs/skin = '2punkt0'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
				</input>
				<label for="skin_2p0">2punkt0</label> <br/>
				<br/> -->
				<input type="hidden" name="skin"><xsl:attribute name="value"><xsl:value-of select="context/user/userprefs/skin"/></xsl:attribute></input>
				<strong><xsl:value-of select="$i18n/l/Publish"/></strong><br/>
				<label for="publish_at_save"><xsl:value-of select="$i18n/l/Pub_on_save"/></label> 
				<input type="checkbox" name="publish_at_save" id="publish_at_save" class="checkbox"><xsl:if test="context/user/userprefs/publish_at_save = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
				<br /><br/>
				<strong><xsl:value-of select="$i18n/l/Container_View"/></strong><br/>
				<xsl:value-of select="$i18n/l/whatToShow"/>? <br />
				<input type="radio" id="conview_title" class="radio-button" name="containerview_show" value="title"><xsl:if test="context/user/userprefs/containerview_show = 'title'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="conview_title"><xsl:value-of select="$i18n/l/Title"/></label> <br/>
				<input type="radio" id="conview_loc" class="radio-button" name="containerview_show" value="location"><xsl:if test="context/user/userprefs/containerview_show = 'location'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="conview_loc"><xsl:value-of select="$i18n/l/Location"/></label> <br/>
				<br />
				<input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="context/user/userprefs/id"/></xsl:attribute></input>
				<!-- admin -->
				<xsl:if test="context/session/user/admin">
					<strong>Profiltyp<!--<xsl:value-of select="$i18n/l/Container_View"/>--></strong><br/>
				<input type="radio" id="proftype_std" class="radio-button" name="profile_type" value="standard"><xsl:if test="context/user/userprefs/profile_type = 'standard'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="proftype_std"><xsl:value-of select="$i18n/l/Standard"/></label> <br/>
				<input type="radio" id="proftype_exp" class="radio-button" name="profile_type" value="expert"><xsl:if test="context/user/userprefs/profile_type = 'expert'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="proftype_exp"><xsl:value-of select="$i18n/l/Expert"/></label> <br/>
				<input type="radio" id="proftype_wadm" class="radio-button" name="profile_type" value="webadmin"><xsl:if test="context/user/userprefs/profile_type = 'webadmin'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="proftype_wadm"><xsl:value-of select="$i18n/l/Webadmin"/></label> <br/>
				<!--<input type="hidden" name="setbyadm" value="1"/>-->
				<input type="hidden" name="name" ><xsl:attribute name="value"><xsl:value-of select="context/user/name"/></xsl:attribute></input>
				</xsl:if>
				
				<br /><br/><br/>
				
				<input type="hidden" name="profile_type"><xsl:attribute name="value"><xsl:value-of select="context/user/userprefs/profile_type"/></xsl:attribute></input>
				<button name="create" type="submit" class="button">
					<xsl:value-of select="$i18n/l/save"/>
				</button>
				&#160;
				<xsl:call-template name="back-to-home"/>
			</form>
			
		 </div>
		<xsl:call-template name="script_bottom"/>
	</body>
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

