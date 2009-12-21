<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_bookmarks.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="../user_common.xsl"/>
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
                    <xsl:value-of select="name"/>'s <xsl:value-of select="$i18n/l/Bookmarks"/>
                </h1>

                <xsl:apply-templates select="bookmarks"/>

                <xsl:call-template name="create_bookmark"/>

                <p>Note:
                    User Default Bookmarks take precedence over Role Default Bookmarks.
                </p>

                <p class="back">
                    <a href="{$xims_box}{$goxims}/user">Back to your personal start page</a>
                </p>

            </div>
            <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
