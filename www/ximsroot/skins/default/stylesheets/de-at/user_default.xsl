<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="user_common.xsl"/>
<xsl:import href="../user_default.xsl"/>
<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/session/user">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            <div id="content">

            <h1>
                Willkommen <xsl:value-of select="firstname" />&#xa0;<xsl:value-of select="lastname" />!
            </h1>

            <h2>Inhalte verwalten</h2>
                <div>
                    Ihre <xsl:value-of select="$i18n/l/Bookmarks"/>:
                    <ul id="bookmarklist">
                        <xsl:apply-templates select="bookmarks/bookmark">
                            <xsl:sort select="stdhome" order="descending"/>
                            <xsl:sort select="content_id" order="ascending"/>
                        </xsl:apply-templates>
                    </ul>
                </div>

                <table>
                    <tr>
                        <th>Ihre <xsl:value-of select="count(/document/userobjectlist/objectlist/object)"/> letzten erstellten oder geänderten Objekte</th>
                        <th>Die <xsl:value-of select="count(/document/objectlist/object)"/> zuletzt geänderten Objekte</th>
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

            <h2>Einstellungen</h2>
                <table width="400">
                    <tr>
                        <td>
                            <p>
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;<a href="{$xims_box}{$goxims}/user?bookmarks=1">Lesezeichen verwalten</a>
                            </p>
                        </td>
                        <td>
                            <xsl:if test="system_privileges/change_password = '1'">
                                <p>
                                    <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;<a href="{$xims_box}{$goxims}/user?passwd=1">Passwort ändern</a>
                                </p>
                            </xsl:if>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <p>
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;Persönliche Einstellungen verwalten
                            </p>
                        </td>
                        <td>
                            <p>
                                <img src="{$ximsroot}images/icons/list_SymbolicLink.gif" border="0" alt="" title=""/>&#160;E-Mail Adresse aktualisieren
                            </p>
                        </td>
                    </tr>
                </table>

            <!-- check sysprivs here and xsl:choose -->
            <xsl:if test="admin = '1'">
                <h2>Verwaltungsoptionen</h2>
                <p>
                    <!-- check sysprivs here and xsl:choose -->
                    Als Mitglied der Admin-Rolle haben Sie folgende administrative Optionen:
                    <ul>
                        <li class="linklist"><a href="{$xims_box}{$goxims_users}">BenutzerInnen und Rollen verwalten</a></li>
                    </ul>
                </p>
            </xsl:if>

        </div>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

