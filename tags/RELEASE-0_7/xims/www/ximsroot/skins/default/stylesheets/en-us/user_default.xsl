<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="common.xsl"/>
<xsl:import href="user_common.xsl"/>
<xsl:import href="../user_default.xsl"/>
<xsl:output method="xml" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/session/user">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            <div id="content">

            <h1>
                Welcome <xsl:value-of select="name" />!
            </h1>

            <h2>Manage content</h2>
                <p>
                    Proceed to your <a href="{$xims_box}{$goxims}/defaultbookmark">default bookmark</a>
                </p>

                <table>
                    <tr>
                        <th><xsl:value-of select="count(/document/userobjectlist/objectlist/object)"/> last objects created or modified by you</th>
                        <th><xsl:value-of select="count(/document/objectlist/object)"/> last modified objects</th>
                    </tr>
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="/document/userobjectlist/objectlist/object">
                                    <xsl:apply-templates select="/document/userobjectlist/objectlist"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
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
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;Manage personal preferences
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
                    <!-- check sysprivs here and xsl:choose -->
                    As a member of the admins role you have the following administrative options:
                    <ul>
                        <li class="linklist"><a href="{$xims_box}{$goxims_users}">Manage users and roles</a></li>
                    </ul>
                </p>
            </xsl:if>

        </div>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

