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

<xsl:param name="name"/>

<xsl:template match="/document">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:call-template name="header">
            <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <table width="100%" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <td class="bluebg" align="center">
                    <xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n_users/l/Objecttypeprivs"/>
                </td>
            </tr>
            <xsl:call-template name="create_manage_accounts"/>
        </table>

        <table width="100%" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <td>
                    <xsl:call-template name="objecttypeprivlist"/>
                </td>
            </tr>
        </table>
    </body>
</html>
</xsl:template>

<xsl:template name="objecttypeprivlist">
    <h1><xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n_users/l/Objecttypeprivs"/> - <xsl:value-of select="$name"/></h1>
    <xsl:if test="/document/objecttypelist/object_type[grantee_id = $name]">
        <h2>Explicit <xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></h2>
        <ul>
            <xsl:apply-templates select="/document/objecttypelist/object_type[grantee_id = $name]" mode="delete"/>
        </ul>
    </xsl:if>

    <xsl:if test="/document/objecttypelist/object_type[grantee_id != $name]">
        <h2>Implicit (Role) <xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></h2>
        <ul>
            <xsl:apply-templates select="/document/objecttypelist/object_type[grantee_id != $name]"/>
        </ul>
    </xsl:if>

    <xsl:if test="/document/objecttypelist/object_type[not(can_create)]">
        <h2><xsl:value-of select="$i18n_users/l/Add_objecttypepriv"/></h2>
        <form name="create_objecttypepriv" action="{$xims_box}{$goxims_users}" method="GET">
            <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt" name="objtype">
                <xsl:apply-templates select="/document/objecttypelist/object_type[not(can_create)]" mode="option"/>
            </select>
            <xsl:text>&#160;</xsl:text>
            <input type="image"
                    name="addpriv"
                    src="{$sklangimages}create.png"
                    width="65"
                    height="14"
                    alt="{$i18n/l/Create}"
                    title="{$i18n/l/Create}"
                    border="0" />
            <input name="objecttypeprivs" type="hidden" value="1"/>
            <input name="name" type="hidden" value="{$name}"/>
            <input name="sort-by" type="hidden" value="{$sort-by}"/>
            <input name="order-by" type="hidden" value="{$order-by}"/>
            <input name="userquery" type="hidden" value="{$userquery}"/>
        </form>
    </xsl:if>
</xsl:template>

<xsl:template match="object_type">
    <xsl:variable name="parent_id" select="parent_id"/>
    <xsl:variable name="fullname">
        <xsl:choose>
            <xsl:when test="$parent_id != ''">
                <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <li>
        <xsl:value-of select="$fullname"/>
    </li>
</xsl:template>

<xsl:template match="object_type" mode="delete">
    <xsl:variable name="parent_id" select="parent_id"/>
    <xsl:variable name="fullname">
        <xsl:choose>
            <xsl:when test="$parent_id != ''">
                <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <li>
        <xsl:value-of select="$fullname"/>&#160;
            <a href="{$xims_box}{$goxims}/users?name={$name};objecttypeprivs=1;delpriv=1;grantor_id={grantor_id};object_type_id={@id};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
                <img
                    src="{$skimages}option_purge.png"
                    border="0"
                    width="37"
                    height="19"
                    alt="{$l_purge}"
                    title="{$l_purge}"
                />
            </a>
    </li>
</xsl:template>

<xsl:template match="object_type" mode="option">
    <xsl:variable name="parent_id" select="parent_id"/>
    <xsl:variable name="fullname">
        <xsl:choose>
            <xsl:when test="$parent_id != ''">
                <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <option value="{$fullname}">
        <xsl:value-of select="$fullname"/>
    </option>
</xsl:template>

</xsl:stylesheet>

