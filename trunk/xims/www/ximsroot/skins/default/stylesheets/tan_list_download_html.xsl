<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: tan_list_download_html.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str">

<xsl:import href="common.xsl"/>

<xsl:param name="css"/>

<xsl:template match="/document/context/object">
    <xsl:variable name="title">TAN_List '<xsl:value-of select="./title" />'</xsl:variable>
    <html>
        <head>
            <title><xsl:value-of select="$title"/></title>
            <link rel="stylesheet" href="{$ximsroot}stylesheets/tan_list_download.css" type="text/css"></link>
            <xsl:if test="$css != ''">
                <link rel="stylesheet" href="{$css}" type="text/css"></link>
            </xsl:if>
        </head>
        <body>
            <div id="tanlist">
                <xsl:for-each select="str:split(body, ',')">
                    <div class="tan"><xsl:value-of select="."/></div>
                </xsl:for-each>
            </div>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>