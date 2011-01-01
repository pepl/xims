<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="../user_default.xsl"/>
<xsl:import href="../user_common.xsl"/>


<xsl:template match="/document/context/session/user">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            <div id="content">

            <h1>
                Welcome <xsl:value-of select="firstname" />&#xa0;<xsl:value-of select="lastname" />!
            </h1>

            <h2>Manage Content</h2>
                <div>
                    Your <xsl:value-of select="$i18n/l/Bookmarks"/>:
                    <ul id="bookmarklist">
                        <xsl:apply-templates select="bookmarks/bookmark">
                            <xsl:sort select="stdhome" order="descending"/>
                            <xsl:sort select="content_id" order="ascending"/>
                        </xsl:apply-templates>
                    </ul>
                </div>

                <table class="uol">
                    <tr>
                        <th><xsl:value-of select="count(/document/userobjectlist/objectlist/object)"/> last objects created or modified by you</th>
                        <th><xsl:value-of select="count(/document/objectlist/object)"/> last modified objects</th>
                    </tr>
                    <tr>
                        <td valign="top">
                            <xsl:choose>
                                <xsl:when test="/document/userobjectlist/objectlist/object">
                                    <xsl:apply-templates select="/document/userobjectlist/objectlist"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td valign="top">
                            <xsl:choose>
                                <xsl:when test="/document/objectlist/object">
                                    <xsl:apply-templates select="/document/objectlist"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>

            <h2>Settings</h2>
                <table width="400">
                    <tr>
                        <td>
                            <p>
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;<a href="{$xims_box}{$goxims}/user?bookmarks=1">Manage bookmarks</a>
                            </p>
                        </td>
                        <td>
                            <xsl:if test="system_privileges/change_password = '1'">
                                <p>
                                    <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;<a href="{$xims_box}{$goxims}/user?passwd=1">Update password</a>
                                </p>
                            </xsl:if>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <p>
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/><a href="{$xims_box}{$goxims}/user?prefs=1">&#160;Manage personal preferences</a>
                            </p>
                        </td>
                        <td>
                            <p>
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;Update e-mail address
                            </p>
                        </td>
                    </tr>
                </table>

            <!-- check sysprivs here and xsl:choose -->
            <xsl:if test="admin = '1'">
                <h2>Administrative Options</h2>
                <p>
                    As a member of the admins role you have the following administrative options:
                </p>
                    <ul>
                        <li class="linklist"><a href="{$xims_box}{$goxims_users}">Manage users and roles</a></li>
                    </ul>
                
            </xsl:if>
<br/><br/>
             <xsl:if test="system_privileges/gen_website">
             <h2>Additional tasks</h2>
                    <ul>
                        <li class="linklist">
                        	<a href="{$xims_box}{$goxims}/user?newwebsite=1">
								Create Departmentroot
							</a>
						</li>
                    </ul>
             </xsl:if>
        </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="object">
    <tr>
        <td class="ctt_df"><xsl:call-template name="cttobject.dataformat"/></td>
        <td class="ctt_loctitle"><xsl:call-template name="cttobject.locationtitle"><xsl:with-param name="link_to_id" select="true()"/></xsl:call-template></td>
        <td class="ctt_lm"><xsl:call-template name="cttobject.last_modified"/> </td>
    </tr>
</xsl:template>

</xsl:stylesheet>

