<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:param name="hd">1</xsl:param>

<!-- save those strings in variables as they are called per object in object/children -->
<xsl:variable name="l_location" select="$i18n/l/location"/>
<xsl:variable name="l_created_by" select="$i18n/l/created_by"/>
<xsl:variable name="l_owned_by" select="$i18n/l/owned_by"/>
<xsl:variable name="l_position_object" select="$i18n/l/position_object"/>
<xsl:variable name="l_last_modified_by" select="$i18n/l/last_modified_by"/>

<xsl:template name="autoindex">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n/l/Create_autoindex"/>
            <input name="autoindex" type="radio" value="true">
                <xsl:if test="attributes/autoindex != '0'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input><xsl:value-of select="$i18n/l/Yes"/>
            <input name="autoindex" type="radio" value="false">
                <xsl:if test="attributes/autoindex = '0'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('autoindex')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="childrentable">
    <xsl:choose>
        <xsl:when test="$sb='title'">
            <xsl:choose>
                <xsl:when test="$order='asc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$sklangimages}status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Status}"
                                            title="{$i18n/l/Status}"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$sklangimages}position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="{$i18n/l/Sort_pos_asc}"
                                                title="{$i18n/l/Sort_pos_asc}"
                                                />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title&amp;order=desc;m={$m}">
                                    <img src="{$sklangimages}title_ascending.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_title_desc}"
                                            title="{$i18n/l/Sort_title_desc}"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$skimages}titlecolumn_bg_bright.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=""
                                        />
                            </td>
                            <td width="23">
                                <img src="{$skimages}titlecolumn_rightcorner_bright.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_asc}"
                                            title="{$i18n/l/Sort_lm_asc}"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$sklangimages}size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="{$i18n/l/Size}"
                                        title="{$i18n/l/Size} {$i18n/l/in} kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$sklangimages}options.png"
                                            width="221"
                                            height="20"
                                            alt="{$i18n/l/Options}"
                                            title="{$i18n/l/Options}"
                                            />
                                </td>
                            </xsl:if>
                        </tr>

                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <!-- as long as lower-first is not implemented, we probably have to use lowercase the title here -->
                            <xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                      order="ascending"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
                <xsl:when test="$order='desc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$sklangimages}status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Status}"
                                            title="{$i18n/l/Status}"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$sklangimages}position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="{$i18n/l/Sort_pos_asc}"
                                                title="{$i18n/l/Sort_pos_asc}"
                                                />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;order=asc;m={$m}">
                                    <img src="{$sklangimages}title_descending.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_title_asc}"
                                            title="{$i18n/l/Sort_title_asc}"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$skimages}titlecolumn_bg_bright.png">
                                <img src="{$ximsroot}images/spacer_white.gif" width="50" height="1" border="0" alt=""/>
                            </td>
                            <td width="23">
                                <img src="{$skimages}titlecolumn_rightcorner_bright.png" width="23" height="20" alt="" title="" />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_asc}"
                                            title="{$i18n/l/Sort_lm_asc}"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$sklangimages}size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="{$i18n/l/Size}"
                                        title="{$i18n/l/Size} {$i18n/l/in} kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$sklangimages}options.png"
                                            width="221"
                                            height="20"
                                            alt="{$i18n/l/Options}"
                                            title="{$i18n/l/Options}"
                                            />
                                </td>
                            </xsl:if>
                        </tr>
                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                      order="descending"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="$sb='date'">
            <xsl:choose>
                <xsl:when test="$order='asc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$sklangimages}status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Status}"
                                            title="{$i18n/l/Status}"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$sklangimages}position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="{$i18n/l/Sort_pos_asc}"
                                                title="{$i18n/l/Sort_pos_asc}"
                                                />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$sklangimages}title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_title_asc}"
                                            title="{$i18n/l/Sort_title_asc}"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$skimages}titlecolumn_bg.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=" "/></td>
                            <td width="23">
                                <img src="{$skimages}titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified_ascending.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$sklangimages}size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="{$i18n/l/Size}"
                                        title="{$i18n/l/Size} {$i18n/l/in} kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$sklangimages}options.png"
                                            width="221"
                                            height="20"
                                            alt="{$i18n/l/Options}"
                                            title="{$i18n/l/Options}"
                                            />
                                </td>
                            </xsl:if>
                        </tr>
                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="ascending"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
                <xsl:when test="$order='desc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$sklangimages}status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt = "{$i18n/l/Status}"
                                            title="{$i18n/l/Status}"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$sklangimages}position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="{$i18n/l/Sort_pos_asc}"
                                                title="{$i18n/l/Sort_pos_asc}"
                                                />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$sklangimages}title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_title_asc}"
                                            title="{$i18n/l/Sort_title_asc}"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$skimages}titlecolumn_bg.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=""
                                        />
                            </td>
                            <td width="23">
                                <img src="{$skimages}titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=asc;m={$m}">
                                    <img src="{$sklangimages}last_modified_descending.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_asc}"
                                            title="{$i18n/l/Sort_lm_asc}"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$sklangimages}size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="{$i18n/l/Size}"
                                        title="{$i18n/l/Size} {$i18n/l/in} kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$sklangimages}options.png"
                                            width="221"
                                            height="20"
                                            alt="{$i18n/l/Options}"
                                            title="{$i18n/l/Options}"
                                            />
                                </td>
                            </xsl:if>
                        </tr>
                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
            </xsl:choose>
        </xsl:when>

        <xsl:when test="$sb='position'">
            <xsl:choose>
                <xsl:when test="$order='asc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$sklangimages}status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Status}"
                                            title="{$i18n/l/Status}"
                                            />
                                </td>
                                <td nowrap="nowrap">
                                    <a href="{location}?sb=position;order=desc;m={$m}">
                                        <img src="{$sklangimages}position_ascending.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="{$i18n/l/Sort_pos_desc}"
                                                title="{$i18n/l/Sort_pos_desc}"
                                                />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="42" height="20">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$sklangimages}title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_title_asc}"
                                            title="{$i18n/l/Sort_title_asc}"
                                            />
                                </a>
                            </td>
                            <td width="100%" height="20" background="{$skimages}titlecolumn_bg.png">
                                <xsl:text>&#160;</xsl:text>
                            </td>
                            <td width="23">
                                <img src="{$skimages}titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$sklangimages}size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="{$i18n/l/Size}"
                                        title="{$i18n/l/Size} {$i18n/l/in} kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$sklangimages}options.png"
                                            width="221"
                                            height="20"
                                            alt="{$i18n/l/Options}"
                                            title="{$i18n/l/Options}"
                                            />
                                </td>
                            </xsl:if>
                        </tr>
                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <xsl:sort select="position" order="ascending"  data-type="number"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
                <xsl:when test="$order='desc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$sklangimages}status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt = "{$i18n/l/Status}"
                                            title="{$i18n/l/Status}"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$sklangimages}position_descending.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="{$i18n/l/Sort_pos_asc}"
                                                title="{$i18n/l/Sort_pos_asc}"
                                                />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$sklangimages}title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_title_asc}"
                                            title="{$i18n/l/Sort_title_asc}"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$skimages}titlecolumn_bg.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=""
                                        />
                            </td>
                            <td width="23">
                                <img src="{$skimages}titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=asc;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_asc}"
                                            title="{$i18n/l/Sort_lm_asc}"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$sklangimages}size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="{$i18n/l/Size}"
                                        title="{$i18n/l/Size} {$i18n/l/in} kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$sklangimages}options.png"
                                            width="221"
                                            height="20"
                                            alt="{$i18n/l/Options}"
                                            title="{$i18n/l/Options}"
                                            />
                                </td>
                            </xsl:if>
                        </tr>
                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <xsl:sort select="position" order="descending" data-type="number"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
            </xsl:choose>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template match="children/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
    <xsl:variable name="dfname" select="$df/name"/>
    <xsl:variable name="dfmime" select="$df/mime_type"/>
    <tr height="20">
        <xsl:if test="$m='e'">
            <td width="86">
                <img src="{$ximsroot}images/spacer_white.gif" width="6" height="20" border="0" alt=" " />
                <xsl:call-template name="cttobject.status"/>
            </td>
            <td align="center">
                <xsl:call-template name="cttobject.position"/>
            </td>
        </xsl:if>
        <td width="34">
            <xsl:call-template name="cttobject.dataformat">
                <xsl:with-param name="dfname" select="$dfname"/>
            </xsl:call-template>
        </td>
        <td colspan="2">
            <xsl:call-template name="cttobject.locationtitle">
                <xsl:with-param name="dfname" select="$dfname"/>
                <xsl:with-param name="dfmime" select="$dfmime"/>
            </xsl:call-template>
        </td>
        <td>
            <xsl:call-template name="cttobject.last_modified"/>
        </td>
        <td align="right">
            <xsl:call-template name="cttobject.content_length">
                <xsl:with-param name="dfname" select="$dfname"/>
                <xsl:with-param name="dfmime" select="$dfmime"/>
            </xsl:call-template>
        </td>
        <xsl:if test="$m='e'">
            <td nowrap="nowrap" align="left">
                <xsl:call-template name="cttobject.options"/>
            </td>
        </xsl:if>
    </tr>
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
        <xsl:when test="location='index.html'">
            <xsl:attribute name="background">
                <xsl:value-of select="concat($skimages,'containerlist_bg_hl.gif')"/>
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="background">
                <xsl:value-of select="concat($skimages,'containerlist_bg.gif')"/>
            </xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <span>
        <xsl:attribute name="title">docid: <xsl:value-of select="@document_id"/>, <xsl:value-of select="$l_location"/>: <xsl:value-of
select="location"/>, <xsl:value-of select="$l_created_by"/>: <xsl:call-template name="creatorfullname"/>, <xsl:value-of select="$l_owned_by"/> <xsl:call-template name="ownerfullname"/></xsl:attribute>
        <a>
            <xsl:choose>
                <xsl:when test="$dfmime='application/x-container'">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$dfname='URL'">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="symname_to_doc_id != ''">
                                <xsl:value-of select="concat($goxims_content, symname_to_doc_id, '?sb=',$sb,';order=',$order,';m=',$m)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="location"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?m=',$m)"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="title" />
        </a>
    </span>
</xsl:template>

<xsl:template name="cttobject.position">
    <xsl:variable name="position">
        <xsl:value-of select="position"/>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$m='e' and /document/context/object/user_privileges/write=1">
            <a
href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@document_id};posview=yes;sbfield=reposition{@id}.new_position')"
                title="{$l_position_object}"
            >
                <xsl:value-of select="$position"/>
            </a>
            <!-- the form is needed, so we can write the new position back without reloading this site from the positioning window -->
            <form name="reposition{@id}"
                    style="margin:0px;"
                    method="GET"
                    action="{$xims_box}{$goxims_content}">
                <input type="hidden"
                        name="sb"
                        value="{$sb}"/>
                <input type="hidden"
                        name="m"
                        value="{$m}"/>
                <input type="hidden"
                        name="order"
                        value="{$order}"/>
                <input type="hidden"
                        name="id"
                        value="{@id}"/>
                <input type="hidden"
                        name="reposition"
                        value="yes"/>
                <input type="hidden"
                        name="new_position"
                        value="{$position}"/>
            </form>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$position"/>
        </xsl:otherwise>
    </xsl:choose>
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
    <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
    <span><xsl:attribute name="title"><xsl:value-of select="$l_last_modified_by"/>: <xsl:call-template name="modifierfullname"/></xsl:attribute>
        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
    </span>
</xsl:template>

<xsl:template name="cttobject.content_length">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>
    <xsl:param name="dfmime" select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/>

   <!-- find a better way to do this (OT property "hasloblength" for example) -->
    <xsl:if test="$dfmime !='application/x-container'
            and $dfname!='URL'
            and $dfname!='SymbolicLink' ">
        <xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
        <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
