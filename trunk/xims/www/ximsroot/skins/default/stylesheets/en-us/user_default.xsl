<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="common.xsl"/>
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<xsl:template match="/document/context/session/user">
    <html>
        <head>
            <title>
                <xsl:value-of select="name" /> - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            <h1>
                Welcome <xsl:value-of select="name" />!
            </h1>

            <h2>Manage content</h2>
                <p>
                    Proceed to your <a href="{$xims_box}{$goxims}/defaultbookmark">default bookmark</a>
                </p>

                <p>
                    Your last XX updated objects|Last XX updated objects
                </p>
                <p>
                    <a href="{$xims_box}{$goxims}/defaultbookmark?search=1;s=M:1">Objects updated today</a><br/>
                </p>

            <hr/>

            <p>
                Manage bookmarks
            </p>

            <p>
                Manage personal preferences
            </p>

            <xsl:if test="system_privileges/change_password = '1'">
                <p>
                    <a href="{$xims_box}{$goxims}/user?passwd=1">Update password</a>
                </p>
            </xsl:if>

            <p>
                Update e-mail address
            </p>


            <!-- check sysprivs here and xsl:choose -->
            <xsl:if test="admin = '1'">
                <hr/>
                <p>
                    <!-- check sysprivs here and xsl:choose -->
                    As a member of the admins role you have the following administrative options:
                    <ul>
                        <li><a href="{$xims_box}{$goxims_users}">Manage users and roles</a></li>
                    </ul>
                </p>
            </xsl:if>

        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

