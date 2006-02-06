<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str">

<xsl:output method="html"
            encoding="utf-8"
            media-type="text/html"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
            doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            indent="no"/>

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