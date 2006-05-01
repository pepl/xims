<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
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
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?process_xsp=1;m={$m}">Zeige Body XSP prozessiert</a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?do_not_process_xsp=1;m={$m}">Zeige Body ohne XSP Prozessierung</a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
