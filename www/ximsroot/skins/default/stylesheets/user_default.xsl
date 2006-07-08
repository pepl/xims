<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<!-- save those strings in variables as they are called per object in object/children -->
<xsl:variable name="l_location" select="$i18n/l/location"/>
<xsl:variable name="l_created_by" select="$i18n/l/created_by"/>
<xsl:variable name="l_owned_by" select="$i18n/l/owned_by"/>
<xsl:variable name="l_last_modified_by" select="$i18n/l/last_modified_by"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<xsl:template match="objectlist">
    <table>
        <xsl:apply-templates select="object">
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
        </xsl:apply-templates>
    </table>
</xsl:template>

<xsl:template match="object">
    <tr>
        <td><xsl:call-template name="cttobject.dataformat"/></td><td><xsl:call-template name="cttobject.locationtitle"/></td><td><xsl:call-template name="cttobject.last_modified"/> </td>
    </tr>
</xsl:template>

<xsl:template name="cttobject.dataformat">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>

    <xsl:choose>
        <xsl:when test="marked_deleted=1">
            <xsl:attribute name="bgcolor">#c6c6c6</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <img src="{$ximsroot}images/spacer_white.gif"
        width="12"
        height="20"
        border="0"
        alt=" " />
    <img src="{$ximsroot}images/icons/list_{$dfname}.gif"
        border="0"
        alt="{$dfname}"
        title="{$dfname}"
     />
</xsl:template>

<xsl:template name="cttobject.last_modified">
    <xsl:choose>
        <xsl:when test="marked_deleted=1">
            <xsl:attribute name="bgcolor">#c6c6c6</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>

    <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
    <span><xsl:attribute name="title"><xsl:value-of select="$l_last_modified_by"/>: <xsl:call-template name="modifierfullname"/></xsl:attribute>
        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
    </span>
</xsl:template>

<xsl:template name="cttobject.locationtitle">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>
    <xsl:param name="dfmime" select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/>

    <xsl:choose>
        <xsl:when test="marked_deleted=1">
            <xsl:attribute name="bgcolor">#c6c6c6</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
        <xsl:when test="marked_deleted=1">
            <xsl:attribute name="background">
                <xsl:value-of select="concat($skimages,'containerlist_bg_deleted.gif')"/>
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="background">
                <xsl:value-of select="concat($skimages,'containerlist_bg.gif')"/>
            </xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <span>
        <xsl:attribute name="title">id: <xsl:value-of select="@id"/>, <xsl:value-of select="$l_location"/>: <xsl:value-of
select="location"/>, <xsl:value-of select="$l_created_by"/>: <xsl:call-template name="creatorfullname"/>, <xsl:value-of select="$l_owned_by"/> <xsl:call-template name="ownerfullname"/></xsl:attribute>
        <a>
            <xsl:choose>
                <xsl:when test="$dfmime='application/x-container'">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($goxims_content,'?id=',@id,';sb=',$sb,';order=',$order,';m=',$m)"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$dfname='URL'">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="symname_to_doc_id != ''">
                                <xsl:value-of select="concat($goxims_content,'?id=',@id,';sb=',$sb,';order=',$order,';m=',$m)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="location"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m)"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="title" />
        </a>
    </span>
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

