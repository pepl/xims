<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../anondiscussionforumcontrib_create.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:param name="id"/>

<xsl:template name="head_default">
    <head>
        <xsl:call-template name="meta"/>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
        <script src="{$ximsroot}scripts/anondiscussionforum.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

</xsl:stylesheet>
