<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="common.xsl"/>
<xsl:import href="../text_default.xsl"/>
<xsl:output method="html" encoding="utf-8"/>

<xsl:template name="body_display_format_switcher">
    <xsl:choose>
        <xsl:when test="$pre = '0'">
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=1;m={$m}">Show body pre-formatted</a>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=0;m={$m}">Show body in standard format</a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
