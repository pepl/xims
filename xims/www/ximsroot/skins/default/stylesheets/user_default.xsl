<?xml version="1.0" encoding="utf-8" ?>

<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="container_common.xsl"/>

<!--<xsl:import href="user_common.xsl"/>-->
<!--<xsl:import href="common.xsl"/>-->

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<xsl:template match="objectlist">
    <table class="objlist">
        <xsl:apply-templates select="object">
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
        </xsl:apply-templates>
    </table>
</xsl:template>

<xsl:template match="object">
    <tr>
        <td class="ctt_df"><xsl:call-template name="cttobject.dataformat"/></td>
        <td class="ctt_loctitle"><xsl:call-template name="cttobject.locationtitle"><xsl:with-param name="link_to_id" select="true()"/></xsl:call-template></td>
        <td class="ctt_lm"><xsl:call-template name="cttobject.last_modified"/> </td>
    </tr>
</xsl:template> 

<xsl:template match="bookmark">
    <li>
        <xsl:choose>
            <xsl:when test="content_id != ''">
                <a href="{$xims_box}{$goxims_content}{content_id}"><xsl:value-of select="content_id"/></a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{$xims_box}{$goxims_content}/">/root</a>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> (</xsl:text>
        <xsl:choose>
            <xsl:when test="owner_id=/document/context/session/user/name"><xsl:value-of select="$i18n/l/personal"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$i18n/l/via_role"/>&#xa0;<xsl:value-of select="owner_id"/></xsl:otherwise>
        </xsl:choose>
        <xsl:if test="stdhome = 1">
            <xsl:text>, </xsl:text><xsl:value-of select="$i18n/l/default_bookmark"/>
        </xsl:if>
        <xsl:text>)</xsl:text>
    </li>
</xsl:template>

</xsl:stylesheet>

