<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="header">
    <xsl:param name="noncontent">false</xsl:param>
    <xsl:param name="nopath">false</xsl:param>
    <xsl:param name="containerpath">false</xsl:param>
    <xsl:param name="createwidget">false</xsl:param>
    <xsl:param name="parent_id" />
    <xsl:param name="noarrownavigation">false</xsl:param>
    <xsl:param name="nooptions">false</xsl:param>
    <xsl:param name="nostatus">false</xsl:param>
    <xsl:param name="no_navigation_at_all">false</xsl:param>

    <!-- start 'app graphic' table -->
    <table width="100%" style="margin-top: 2px;" bgcolor="#eeeeee" border="0" cellpadding="3" cellspacing="0" vspace="0" hspace="0" nowrap="nowrap">
        <tr>
            <td valign="bottom">
                <h1 style="font-size: 14pt; color:#004080; margin-bottom: 2px">
                    <xsl:choose>
                        <xsl:when test="title != ''">
                            <xsl:value-of select="title"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="/document/context/session/user/name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
            </td>
            <td align="right" valign="top">
                <a href="http://xims.info/"><img src="{$ximsroot}images/xims_logo.png"/></a>
            </td>
        </tr>
    </table>
    <!-- end 'app graphic' table -->

    <!-- start 'location bar' table -->
    <table border="0" cellpadding="2" cellspacing="0" width="100%" height="20">
        <tr>
            <td width="59%" bgcolor="#ffffff" background="{$skimages}tablebg_2nd_row.png" nowrap="nowrap">
                <xsl:if test="$nopath='false' and $noncontent ='false'">
                    <span style="color: #004080; font-size: 10px; font-family: Arial, Helvetica, sans-serif;">
                    <xsl:choose>
                        <xsl:when test="$containerpath='false'">
                            <xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1]">
                                <xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all" />
                            </xsl:apply-templates>
                            / <a class="" href="{$goxims_content}{$absolute_path}?m={$m}"><xsl:value-of select="location"/></a>
                            <xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- hardcode OT alarm (folder and dept.root -->
                            <xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1 and (preceding-sibling::object/object_type_id=1 or preceding-sibling::object/object_type_id=6)]" >
                                    <xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all" />
                            </xsl:apply-templates>
                            <xsl:text>&#160;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    </span>
                </xsl:if>
            </td>
            <td background="{$skimages}tablebg_2nd_row.png" nowrap="nowrap" align="right">
                <span style="color: #004080; font-size: 10px; font-family: Arial, Helvetica, sans-serif;">
                <xsl:apply-templates select="/document/context/session/date" mode="date"/>
                <xsl:choose>
                    <xsl:when test="/document/context/session/public_user = '1'">
                        / <a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}" class="logout"><xsl:value-of select="$i18n/l/login"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        / <a href="{$xims_box}{$goxims}/user"><xsl:value-of select="/document/context/session/user/name" /></a> / <a href="{$goxims_content}{$absolute_path}?reason=logout" class="logout"><xsl:value-of select="$i18n/l/logout"/></a>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$no_navigation_at_all='true' or $noncontent = 'true'">
                    </xsl:when>
                    <xsl:otherwise>
                        /
                        <xsl:call-template name="mode_switcher"/>
                    </xsl:otherwise>
                </xsl:choose>
                </span>
            </td>
        </tr>
    </table>
    <!-- end 'location bar' table -->

    <xsl:choose>
        <xsl:when test="$noncontent='true'">
        <xsl:call-template name="subheader_noncontent"/>
        </xsl:when>
        <xsl:when test="$no_navigation_at_all='true'">
            <xsl:call-template name="subheader_nonavigation"/>
        </xsl:when>
        <xsl:otherwise>
        <xsl:call-template name="subheader">
            <xsl:with-param name="createwidget"><xsl:value-of select="$createwidget"/></xsl:with-param>
            <xsl:with-param name="parent_id"><xsl:value-of select="$parent_id"/></xsl:with-param>
            <xsl:with-param name="noarrownavigation"><xsl:value-of select="$noarrownavigation"/></xsl:with-param>
            <xsl:with-param name="nooptions"><xsl:value-of select="$nooptions"/></xsl:with-param>
            <xsl:with-param name="nostatus"><xsl:value-of select="$nostatus"/></xsl:with-param>
        </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="subheader_noncontent">
    <table border="0" cellspacing="0" cellpadding="0" width="100%" style="margin-left: 5px; padding-right: 5px;">
        <tr>
            <td align="center" width="758" background="{$skimages}subheader-generic_bg.png">
                <!--<xsl:call-template name="message"/>-->
            </td>
            <xsl:call-template name="header.cttobject.search"/>
        </tr>
    </table>
</xsl:template>

<xsl:template name="subheader_nonavigation">
    <table border="0" cellspacing="0" cellpadding="5" width="100%" style="margin-left: 5px; padding-right: 5px;">
        <tr>
            <td align="center" background="{$skimages}subheader-generic_bg.png">
                <xsl:call-template name="message"/>
            </td>
        </tr>
    </table>
</xsl:template>


<xsl:template name="subheader">
    <xsl:param name="createwidget">false</xsl:param>
    <xsl:param name="parent_id" />
    <xsl:param name="noarrownavigation">false</xsl:param>
    <xsl:param name="nooptions">false</xsl:param>
    <xsl:param name="nostatus">false</xsl:param>

    <table border="0" cellspacing="0" cellpadding="0" width="100%" style="padding-right: 5px;">
        <tr>
            <xsl:call-template name="header.arrownavigation"/>
            <xsl:choose>
                <xsl:when test="$m='e'">
                    <xsl:choose>
                        <xsl:when test="/document/context/object/user_privileges/create
                                       and $createwidget = 'true'
                                       and /document/object_types/object_type[can_create]">
                            <xsl:call-template name="header.cttobject.createwidget">
                                <xsl:with-param name="parent_id"><xsl:value-of select="$parent_id"/></xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <td width="215" background="{$skimages}options_bg.png" nowrap="nowrap">
                                <xsl:if test="$nooptions='false'">
                                    <xsl:call-template name="cttobject.options"/>
                                </xsl:if>
                            </td>
                            <td width="80" background="{$skimages}subheader-generic_bg.png" nowrap="nowrap">
                                <xsl:if test="$nostatus='false'">
                                    <xsl:call-template name="cttobject.status"/>
                                </xsl:if>
                            </td>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <td width="126" background="{$skimages}options_bg.png" nowrap="nowrap"><xsl:text>&#160;</xsl:text></td>
                    <td width="80" background="{$skimages}subheader-generic_bg.png"><xsl:text>&#160;</xsl:text></td>
                </xsl:otherwise>
            </xsl:choose>
            <td width="629" background="{$skimages}subheader-generic_bg.png">
                <xsl:call-template name="message"/>
            </td>
            <xsl:call-template name="header.cttobject.search"/>
        </tr>
    </table>
</xsl:template>

<xsl:template name="header.arrownavigation">
    <td width="57" bgcolor="#ffffff" background="{$skimages}navigate_bg.png" align="center" nowrap="nowrap">
        <a href="javascript:history.go(-1)" onmouseover="pass('back','back','h'); return true;" onmouseout="pass('back','back','c'); return true;" onmousedown="pass('back','back','s'); return true;" onmouseup="pass('back','back','s'); return true;">
            <img src="{$skimages}navigate-back.png"
                    width="28"
                    height="28"
                    border="0"
                    alt="{$i18n/l/Back}"
                    title="{$i18n/l/Back}"
                    name="back"
            />
        </a>
    </td>
    <td width="41" bgcolor="#ffffff" background="{$skimages}navigate_bg.png" align="left" nowrap="nowrap">
        <xsl:choose>
            <xsl:when test="$parent_path != ''">
                <a
                    onmouseover="pass('up','up','h'); return true;"
                    onmouseout="pass('up','up','c'); return true;"
                    onmousedown="pass('up','up','s'); return true;"
                    onmouseup="pass('up','up','s'); return true;">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($goxims_content,$parent_path,'?m=',$m)"/>
                        <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                    </xsl:attribute>
                    <img src="{$skimages}navigate-up.png"
                            width="28"
                            height="28"
                            border="0"
                            alt="{$i18n/l/Up}"
                            title="{$i18n/l/Up}"
                            name="up"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$skimages}navigate-up.png"
                        width="28"
                        height="28"
                        border="0"
                        alt="{$i18n/l/Up}"
                        title="{$i18n/l/Up}"
                        name="up"/>
            </xsl:otherwise>
        </xsl:choose>
    </td>
    <td width="59" background="{$skimages}navigate-forward_bg.png" align="left" nowrap="nowrap">
        <a href="javascript:history.go(+1)"
            onmouseover="pass('forward','forward','h'); return true;"
            onmouseout="pass('forward','forward','c'); return true;"
            onmousedown="pass('forward','forward','s'); return true;"
            onmouseup="pass('forward','forward','s'); return true;"
        >
            <img src="{$skimages}navigate-forward.png"
                    width="28"
                    height="28"
                    border="0"
                    alt="{$i18n/l/Forward}"
                    title="{$i18n/l/Forward}"
                    name="forward"
            />
        </a>
    </td>
</xsl:template>

<xsl:template name="header.cttobject.createwidget">
    <xsl:param name="parent_id" />
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0;" method="GET">
        <td width="126" background="{$skimages}options_bg.png" nowrap="nowrap">
            <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt" name="objtype">
                <!-- Do not display object types that either are not fully implemented or that are not meant to be created directly.
                     We may consider adding an object type property for the latter types.
                     jokar, 2006-05-03: parameter parent_id, to prevent the diret creation of e.g. VLibraryItem::Document-s
                -->
                <xsl:apply-templates select="/document/object_types/object_type[can_create and name != 'Portal' and name != 'Annotation' and name != 'AnonDiscussionForumContrib' and name != 'VLibraryItem' and parent_id = $parent_id]"/>
            </select>
        </td>
        <td width="80" background="{$skimages}subheader-generic_bg.png" style="padding-top: 4">
            <xsl:text>&#160;</xsl:text>
            <input type="image"
                    name="create"
                    src="{$sklangimages}create.png"
                    width="65"
                    height="14"
                    alt="{$i18n/l/Create}"
                    title="{$i18n/l/Create}"
                    border="0" />
            <input name="page" type="hidden" value="{$page}"/>
            <input name="r" type="hidden" value="{/document/context/object/@id}"/>
            <xsl:if test="$defsorting != 1">
                <input name="sb" type="hidden" value="{$sb}"/>
                <input name="order" type="hidden" value="{$order}"/>
            </xsl:if>
        </td>
    </form>
</xsl:template>

<xsl:template name="header.cttobject.search">
    <xsl:variable name="Search" select="$i18n/l/Search"/>
    <form style="margin-bottom: 0;" method="GET" name="quicksearch">
        <xsl:attribute name="action">
            <xsl:choose>
                <xsl:when test="$absolute_path != ''">
                    <xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($xims_box,$goxims,'/user')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <td width="182" align="right">
            <table width="100%" border="0" height="42" background="{$skimages}subheader-generic_bg.png" cellpadding="0" cellspacing="0">
                <tr>
                    <td nowrap="nowrap">
                        <xsl:value-of select="$i18n/l/From_here"/>
                        <input type="checkbox" name="start_here" value="1">
                            <xsl:if test="$start_here != ''">
                                <xsl:attribute name="checked">true</xsl:attribute>
                            </xsl:if>
                        </input>
                        <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" type="text" name="s" size="17" maxlength="200">
                        <xsl:choose>
                            <xsl:when test="$s != ''">
                                <xsl:attribute name="value"><xsl:value-of select="$s"/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value">[<xsl:value-of select="$Search"/>]</xsl:attribute>
                                <xsl:attribute name="onfocus">document.quicksearch.s.value=&apos;&apos;;</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        </input>
                        <xsl:text>&#160;</xsl:text>
                        <input type="image"
                                src="{$sklangimages}search.png"
                                name="submit"
                                width="65"
                                height="14"
                                alt="{$Search}"
                                title="{$Search}"
                                border="0"
                        />
                        <input type="hidden" name="search" value="1"/>
                    </td>
                </tr>
            </table>
        </td>
    </form>
</xsl:template>

<xsl:template name="mode_switcher">
    <xsl:choose>
        <xsl:when test="$m='e'">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,$absolute_path,'?m=b')"/>
                    <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                </xsl:attribute>
                <xsl:value-of select="$i18n/l/switch_to_browse"/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,$absolute_path,'?m=e')"/>
                    <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                </xsl:attribute>
                <xsl:value-of select="$i18n/l/switch_to_edit"/>
            </a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="object_type">
    <xsl:variable name="parent_id" select="parent_id"/>
    <xsl:variable name="fullname">
        <xsl:choose>
            <xsl:when test="$parent_id != ''">
                <xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <option value="{$fullname}"><xsl:value-of select="$fullname"/></option>
</xsl:template>



</xsl:stylesheet>