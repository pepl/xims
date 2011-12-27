<?xml version="1.0" encoding="utf-8" ?>

<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_default.xsl 2216 2009-06-17 12:16:25Z haensel $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="container_common.xsl"/>
<xsl:import href="user_bookmarks.xsl"/>

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

            <h1>
                <xsl:value-of select="$i18n/l/Welcome"/>&#160;<xsl:value-of select="firstname" />&#xa0;<xsl:value-of select="lastname" />!
            </h1>
<div style="float:left">
            <h2><xsl:value-of select="$i18n/l/ManageContent"/></h2>
                <!--<div>-->
                    <xsl:value-of select="$i18n/l/Your"/>&#160;<xsl:value-of select="$i18n/l/Bookmarks"/>:
                   <ul id="bookmarklist">
                        <xsl:apply-templates select="bookmarks/bookmark">
                            <xsl:sort select="stdhome" order="descending"/>
                            <xsl:sort select="content_id" order="ascending"/>
                        </xsl:apply-templates>
                    </ul>
                <!--</div>-->
                <br/>
                <div class="objlastmod">
									<xsl:value-of select="$i18n/l/Your"/>&#160;<xsl:value-of select="count(/document/userobjectlist/objectlist/object)"/>&#160;<xsl:value-of select="$i18n/l/lastObjModByYou"/>
									<xsl:choose>
                                <xsl:when test="/document/userobjectlist/objectlist/object">
                                    <xsl:apply-templates select="/document/userobjectlist/objectlist"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                </div>
                <div class="objlastmod">
                  <xsl:value-of select="$i18n/l/The_fpl"/>&#160;<xsl:value-of select="count(/document/objectlist/object)"/>&#160;<xsl:value-of select="$i18n/l/lastObjMod"/>
                  <xsl:choose>
                                <xsl:when test="/document/objectlist/object">
                                    <xsl:apply-templates select="/document/objectlist"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                </div>
<br/><br/>
</div>

	<br clear="all"/>
	<h2><xsl:value-of select="$i18n/l/Settings"/></h2>
	<ul id="settinglist">
		<li><a href="{$xims_box}{$goxims}/user?bookmarks=1"><xsl:value-of select="$i18n/l/ManageBookmarks"/></a></li>
		<xsl:if test="system_privileges/change_password = '1'">
			<li><a href="{$xims_box}{$goxims}/user?passwd=1"><xsl:value-of select="$i18n/l/ChangePassword"/></a></li>
			<li><xsl:value-of select="$i18n/l/UpdateEmailAdress"/></li>
		</xsl:if>
		<xsl:if test="userprefs/profile_type != 'standard'">
		<li><a href="{$xims_box}{$goxims}/user?prefs=1"><xsl:value-of select="$i18n/l/ManagePersonalSettings"/></a></li>
		</xsl:if>
	</ul>

            
            <!-- check sysprivs here and xsl:choose -->
            <xsl:if test="admin = '1'">
            	<br/>
                <h2><xsl:value-of select="$i18n/l/AdmOptions"/></h2>
                <p>
                    <!-- check sysprivs here and xsl:choose -->
                    <xsl:value-of select="$i18n/l/AsMemberAdmin"/>
                </p>
                    <ul id="adminlist">
                        <li><a href="{$xims_box}{$goxims_users}"><xsl:value-of select="$i18n/l/ManageUserRoles"/></a></li>
                    </ul>
                
            </xsl:if>
            
             <!--<xsl:if test="system_privileges/gen_website">-->
			 <xsl:if test="admin = '1' or userprefs/profile_type = 'webadmin'">
             	<br/>
             <h2><xsl:value-of select="$i18n/l/Additional_tasks"/></h2>
                    <ul>
                        <li><a href="{$xims_box}{$goxims}/user?newwebsite=1"><xsl:value-of select="$i18n/l/GenerateWebsite"/></a></li>
                    </ul>
             </xsl:if>

        </div>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template match="objectlist">
    <table class="obj-table">
    <thead>
    <tr>
					<th>&#160;</th>
					<th><xsl:value-of select="$i18n/l/Title"/></th>
					<th><xsl:value-of select="$i18n/l/Last_modified"/></th>
		</tr>
		</thead>
		<tbody>
		
        <xsl:apply-templates select="object">
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
        </xsl:apply-templates>
       </tbody>
    </table>
</xsl:template>

<xsl:template match="object">
    <tr>
        <td><xsl:call-template name="cttobject.dataformat"/></td>
        <td><xsl:call-template name="cttobject.locationtitle"><xsl:with-param name="link_to_id" select="true()"/></xsl:call-template></td>
        <td class="ctt_lm"><xsl:call-template name="cttobject.last_modified"/> </td>
    </tr>
</xsl:template>

<xsl:template match="bookmark">
	<li>
        <xsl:choose>
            <xsl:when test="content_id != ''">
                <a href="{$xims_box}{$goxims_content}{content_id}"><xsl:value-of select="content_id"/></a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{$xims_box}{$goxims_content}/">/root</a>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> (</xsl:text>
        <xsl:choose>
            <xsl:when test="owner_id=/document/context/session/user/name"><xsl:value-of select="$i18n/l/personal"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$i18n/l/via_role"/>&#xa0;<xsl:value-of select="owner_id"/></xsl:otherwise>
        </xsl:choose>
        <xsl:if test="stdhome = 1">
            <xsl:text>, </xsl:text><xsl:value-of select="$i18n/l/default_bookmark"/>
        </xsl:if>
        <xsl:text>)</xsl:text>
    </li>
</xsl:template>

</xsl:stylesheet>

