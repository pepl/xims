<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
                
<xsl:import href="common.xsl"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<xsl:template match="/document/context/session/user">
	<html>
		<xsl:call-template name="head_default">
			<xsl:with-param name="mode">user</xsl:with-param>
		</xsl:call-template>
		<body>
			<xsl:call-template name="header">
				<xsl:with-param name="noncontent">true</xsl:with-param>
			</xsl:call-template>
			<div id="content-container">
				<h1 class="bluebg">
				<xsl:value-of select="$i18n/l/ManagePersonalSettings"/>
				</h1>
				<form name="userEdit" action="{$xims_box}{$goxims}/userprefs" method="post" id="create-edit-form">
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
				
				<input type="hidden" name="skin"><xsl:attribute name="value"><xsl:value-of select="userprefs/skin"/></xsl:attribute></input>
				
				<xsl:choose>
					<xsl:when test="userprefs/profile_type = 'expert' or userprefs/profile_type = 'webadmin'">
						<input type="hidden" name="skin"><xsl:attribute name="value"><xsl:value-of select="userprefs/skin"/></xsl:attribute></input>
						<strong><xsl:value-of select="$i18n/l/Publish"/></strong><br/>
						<label for="publish_at_save"><xsl:value-of select="$i18n/l/Pub_on_save"/></label> 
						<input type="checkbox" name="publish_at_save" id="publish_at_save" class="checkbox"><xsl:if test="userprefs/publish_at_save = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
					
						<br /><br/>
					
					</xsl:when>
					<xsl:otherwise>
						<input type="hidden" name="publish_at_save" value=""/>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:choose>
					<xsl:when test="userprefs/profile_type = 'expert' or userprefs/profile_type = 'webadmin'">
						<strong><xsl:value-of select="$i18n/l/Container_View"/></strong><br/>
						<xsl:value-of select="$i18n/l/whatToShow"/>? <br />
						<input type="radio" id="conview_title" class="radio-button" name="containerview_show" value="title"><xsl:if test="userprefs/containerview_show = 'title'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="conview_title"><xsl:value-of select="$i18n/l/Title"/></label> <br/>
						<input type="radio" id="conview_loc" class="radio-button" name="containerview_show" value="location"><xsl:if test="userprefs/containerview_show = 'location'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="conview_loc"><xsl:value-of select="$i18n/l/Location"/></label> <br/>
						
						<br/><br/>
						
					</xsl:when>
					<xsl:otherwise>
						<input type="hidden" name="containerview_show" value="title"/>
					</xsl:otherwise>
				</xsl:choose>
				
				
					<strong><xsl:value-of select="$i18n/l/Profiletype"/></strong><br/>
				<input type="radio" id="proftype_std" class="radio-button" name="profile_type" value="standard">
					<xsl:if test="userprefs/profile_type = 'standard'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
					<xsl:if test="admin='0'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
				</input> <label for="proftype_std"><xsl:value-of select="$i18n/l/Standard"/></label> <br/>
				<input type="radio" id="proftype_exp" class="radio-button" name="profile_type" value="expert">
					<xsl:if test="userprefs/profile_type = 'expert'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
					<xsl:if test="admin='0'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
				</input> <label for="proftype_exp"><xsl:value-of select="$i18n/l/Expert"/></label> <br/>
				<input type="radio" id="proftype_wadm" class="radio-button" name="profile_type" value="webadmin">
					<xsl:if test="userprefs/profile_type = 'webadmin'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
					<xsl:if test="admin='0'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
				</input> <label for="proftype_wadm"><xsl:value-of select="$i18n/l/Webadmin"/></label> <br/>
				<input type="hidden" name="name" ><xsl:attribute name="value"><xsl:value-of select="context/user/name"/></xsl:attribute></input>
				
				<br /><br/><br/>
				<input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="userprefs/id"/></xsl:attribute></input>
				<input type="hidden" name="profile_type"><xsl:attribute name="value"><xsl:value-of select="userprefs/profile_type"/></xsl:attribute></input>
				<button name="create" type="submit">
					<xsl:value-of select="$i18n/l/save"/>
				</button>
				&#160;
				<xsl:call-template name="back-to-home"/>
			</form>
		</div>
		<xsl:call-template name="script_bottom" />
	</body>
</html>
 </xsl:template>
</xsl:stylesheet>
