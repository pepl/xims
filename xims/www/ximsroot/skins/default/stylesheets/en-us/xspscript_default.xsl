<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="common.xsl"/>
    <xsl:import href="../xspscript_default.xsl"/>
    <xsl:output method="html" encoding="utf-8"/>

    <xsl:param name="process_xsp" select="'0'"/>
    <xsl:template name="processxsp_switcher">
        <xsl:choose>
            <xsl:when test="$process_xsp = '0'">
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?process_xsp=1;m={$m}">Show body XSP processed</a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?do_not_process_xsp=1;m={$m}">Do not XSP process body</a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
