<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="../container_common.xsl"/>

<xsl:template name="deleted_objects">
        <xsl:choose>
            <xsl:when test="$hd=0">
                <tr><td>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};hd=1">Verstecke die gelöschten Objekte</a>
                </td></tr>
            </xsl:when>
            <xsl:when test="$deleted_children > 0">
                <tr><td>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};hd=0">Zeige alle (<xsl:value-of select="$deleted_children"/>) gelöschten Objekte in diesem Container</a>
                </td></tr>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>

</xsl:stylesheet>
