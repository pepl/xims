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

<xsl:import href="../container_common.xsl"/>

<xsl:template name="deleted_objects">
        <xsl:choose>
            <xsl:when test="$hd=0 and $deleted_children > 0">
                <tr><td colspan="3">
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=1">Hide deleted Objects</a>
                </td></tr>
            </xsl:when>
            <xsl:when test="$deleted_children > 0">
                <tr><td colspan="3">
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=0">Show the  <xsl:value-of select="$deleted_children"/> deleted Object(s) in this Container</a>
                </td></tr>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>


</xsl:stylesheet>
