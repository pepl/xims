<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common" xmlns:dyn="http://exslt.org/dynamic"
    extension-element-prefixes="dyn" xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <xsl:import href="users_common.xsl"/>

    <xsl:param name="name"/>

    <xsl:variable name="root" select="/"/>
    <xsl:variable name="non_grouped_davots">
        <xsl:for-each
            select="/document/object_types/object_type[
        is_davgetable = 1 and name != 'Document' and
        name != 'DepartmentRoot' and name != 'File' and name != 'Folder' and
        name != 'Image' and name != 'SiteRoot' and name != 'CSS' and name != 'JavaScript' and name != 'Text' and
        name != 'AxPointPresentation' and name != 'DocBookXML' and name != 'XML' and
        name != 'XSLStylesheet' and name != 'XSPScript' and name != 'sDocBookXML']">
            <xsl:sort
                select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                order="ascending"/>
            <xsl:copy>
                <xsl:copy-of select="@*|*"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>


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
                            <xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of
                                select="$i18n_users/l/Objecttypeprivs"/>
                        </td>
                    </tr>
                    <xsl:call-template name="create_manage_accounts"/>
                </table>

                <table width="100%" cellpadding="2" cellspacing="0" border="0">
                    <tr>
                        <td valign="top" colspan="2" align="center">
                            <h1><xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of
                                select="$i18n_users/l/Objecttypeprivs"/> - <xsl:value-of select="$name"/></h1>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <xsl:call-template name="objecttypeprivlist"/>
                        </td>
                        <td valign="top">
                            <xsl:call-template name="dav_otprivileges"/>
                        </td>
                    </tr>
                </table>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="objecttypeprivlist">
        <h2><xsl:value-of select="$i18n_users/l/Objecttypeprivs_objectCreation"/></h2>
        <xsl:if test="/document/objecttypelist/object_type[grantee_id = $name]">
            <h3>Explicit <xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></h3>
            <ul>
                <xsl:apply-templates
                    select="/document/objecttypelist/object_type[grantee_id = $name]" mode="delete"
                />
            </ul>
        </xsl:if>

        <xsl:if test="/document/objecttypelist/object_type[grantee_id != $name]">
            <h3>Implicit (Role) <xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></h3>
            <ul>
                <xsl:apply-templates
                    select="/document/objecttypelist/object_type[grantee_id != $name]"/>
            </ul>
        </xsl:if>

        <xsl:if test="/document/objecttypelist/object_type[not(can_create)]">
            <h3>
                <xsl:value-of select="$i18n_users/l/Add_objecttypepriv"/>
            </h3>
            <form name="create_objecttypepriv" action="{$xims_box}{$goxims_users}" method="get">
                <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt"
                    name="objtype">
                    <xsl:apply-templates
                        select="/document/objecttypelist/object_type[not(can_create)]" mode="option"
                    />
                </select>
                <xsl:text>&#160;</xsl:text>
                <input type="image" 
                       name="addpriv" 
                       src="{$sklangimages}create.png"
                       alt="{$i18n/l/Create}" 
                       title="{$i18n/l/Create}" />
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
                    <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"
                        />::<xsl:value-of select="name"/>
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
                    <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"
                        />::<xsl:value-of select="name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:value-of select="$fullname"/>&#160; <a
                href="{$xims_box}{$goxims}/users?name={$name};objecttypeprivs=1;delpriv=1;grantor_id={grantor_id};object_type_id={@id};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
                <img src="{$skimages}option_purge.png" border="0" width="37" height="19"
                    alt="{$l_purge}" title="{$l_purge}"/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="object_type" mode="option">
        <xsl:variable name="parent_id" select="parent_id"/>
        <xsl:variable name="fullname">
            <xsl:choose>
                <xsl:when test="$parent_id != ''">
                    <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"
                        />::<xsl:value-of select="name"/>
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

    <xsl:template name="dav_otprivileges">
        <h2>
            <xsl:value-of select="$i18n_users/l/DAV_OTPrivileges"/>
        </h2>
        <form name="dav_ot_privs" action="{$xims_box}{$goxims_users}" method="get">
            <input name="objecttypeprivs" type="hidden" value="1"/>
            <input name="name" type="hidden" value="{$name}"/>
            <input name="sort-by" type="hidden" value="{$sort-by}"/>
            <input name="order-by" type="hidden" value="{$order-by}"/>
            <input name="userquery" type="hidden" value="{$userquery}"/>

            <table>
                <tr>
                    <td>
                        <table cellpadding="2" cellspacing="0" border="0">
                            <tr>
                                <td>
                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_Folder">
                                          <xsl:if test="/document/context/user/dav_otprivileges/Folder = 1">
                                            <xsl:attribute name="checked">checked</xsl:attribute>
                                          </xsl:if>
                                        </input>
                                        <xsl:value-of select="$i18n_users/l/DAV_Container_Binary"/>
                                    </span>
                                </td>
                                <td>
                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_Text">
                                            <xsl:if test="/document/context/user/dav_otprivileges/Text = 1">
                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="$i18n_users/l/DAV_Text"/>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_XML">
                                           <xsl:if test="/document/context/user/dav_otprivileges/XML = 1">
                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="$i18n_users/l/DAV_XML"/>
                                    </span>
                                </td>
                                <td>
                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_Document">
                                            <xsl:if test="/document/context/user/dav_otprivileges/Document = 1">
                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                            </xsl:if>
                                        </input> Document </span>
                                </td>
                            </tr>
                            <xsl:call-template name="dav_ot_tr"/>
                        </table>
                    </td>
                </tr>
            </table>

            <input type="submit" name="dav_otprivs_update" value="Update"/>
        </form>
    </xsl:template>

    <xsl:template name="dav_ot_tr">
        <xsl:for-each select="exslt:node-set($non_grouped_davots)/object_type[position() mod 2 = 1]">
            <tr>
                <xsl:apply-templates
                    select=". | following-sibling::object_type[position() &lt; 2]" mode="dav"/>
            </tr>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="object_type" mode="dav">
        <xsl:variable name="otxpath"
            select="concat('$root/document/context/user/dav_otprivileges/',name,'=1')"/>
        <td>
            <span class="cboxitem">
                <input type="checkbox" name="dav_otprivs_{name}">
                    <xsl:if test="dyn:evaluate($otxpath)">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                </input>
                <xsl:value-of select="name"/>
            </span>
        </td>
    </xsl:template>


</xsl:stylesheet>
