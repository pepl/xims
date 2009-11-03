<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<!--<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="name" /> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/userpages.css" type="text/css"/>
        <xsl:call-template name="script_head"/>
    </head>
</xsl:template>-->


</xsl:stylesheet>
