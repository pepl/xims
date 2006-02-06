<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="user_common.xsl"/>
    <xsl:import href="../user_bookmarks.xsl"/>
    <xsl:output method="html" encoding="utf-8"/>

    <xsl:template match="/document/context/session/user">
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="noncontent">true</xsl:with-param>
                </xsl:call-template>
                <div id="content">

                <h1>
                    <xsl:value-of select="name"/>s <xsl:value-of select="$i18n/l/Bookmarks"/>
                </h1>

                <xsl:apply-templates select="bookmarks"/>

                <xsl:call-template name="create_bookmark"/>

                <p>Hinweis:
                    BenutzerIn Standard Lesezeichen haben Vorrang gegenüber Rollen Standard Lesezeichen.
                </p>

                <p class="back">
                    <a href="{$xims_box}{$goxims}/user">Zurück zu Ihrer persönlichen Startseite</a>
                </p>

            </div>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
