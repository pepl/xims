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


<xsl:variable name="pagesperpagenav" select="10" />
<xsl:variable name="totalpages" select="ceiling(/document/context/object/children/@totalobjects div $searchresultrowlimit)"/>

<!-- save those strings in variables as they are called per object in object/children -->
<xsl:variable name="l_location" select="$i18n/l/location"/>
<xsl:variable name="l_created_by" select="$i18n/l/created_by"/>
<xsl:variable name="l_owned_by" select="$i18n/l/owned_by"/>
<xsl:variable name="l_position_object" select="$i18n/l/position_object"/>
<xsl:variable name="l_last_modified_by" select="$i18n/l/last_modified_by"/>

<xsl:template name="autoindex">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n/l/Omit_autoindex"/>
            <input name="autoindex" type="checkbox" value="false">
                <xsl:if test="attributes/autoindex = '0'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('autoindex')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="defaultsorting">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n/l/Sort_children_default"/>
            <select name="defaultsortby">
                <option value="position">
                    <xsl:value-of select="$i18n/l/Position"/>
                </option>
                <option value="title">
                    <xsl:if test="attributes/defaultsortby = 'title'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$i18n/l/Title"/>
                </option>
                <option value="date">
                    <xsl:if test="attributes/defaultsortby = 'date'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$i18n/l/Last_Modification_Date"/>
                </option>
            </select>
            <input name="defaultsort" type="radio" value="asc">
                <xsl:if test="not(attributes/defaultsort) or attributes/defaultsort != 'desc'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input><xsl:value-of select="$i18n/l/ascending"/>
            <input name="defaultsort" type="radio" value="desc">
                <xsl:if test="attributes/defaultsort = 'desc'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input><xsl:value-of select="$i18n/l/descending"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('defaultsorting')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="pagenav">
    <xsl:param name="totalitems"/>
    <xsl:param name="itemsperpage"/>
    <xsl:param name="currentpage"/>
    <xsl:param name="url"/>

    <xsl:if test="$totalpages &gt; 1">
        <div id="pagenav">
            <div>
                <xsl:if test="$currentpage &gt; 1">
                    <a href="{$url};page={number($currentpage)-1}">&lt; <xsl:value-of select="$i18n/l/Previous_page"/></a>
                </xsl:if>
                <xsl:if test="$currentpage &gt; 1 and $currentpage &lt; $totalpages">
                    |
                </xsl:if>
                <xsl:if test="$currentpage &lt; $totalpages">
                    <a href="{$url};page={number($currentpage)+1}">&gt; <xsl:value-of select="$i18n/l/Next_page"/></a>
                </xsl:if>
            </div>
            <div>
                <xsl:call-template name="pageslinks">
                    <xsl:with-param name="page" select="1"/>
                    <xsl:with-param name="current" select="$currentpage"/>
                    <xsl:with-param name="total" select="$totalpages"/>
                    <xsl:with-param name="url" select="$url"/>
                </xsl:call-template>
            </div>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="pageslinks">
    <xsl:param name="page"/>
    <xsl:param name="current"/>
    <xsl:param name="total"/>
    <xsl:param name="url"/>

    <xsl:choose>
        <xsl:when test="$page = $current">
            <strong><a href="{$url};page={$page}"><xsl:value-of select="$page" /></a></strong>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$url};page={$page}"><xsl:value-of select="$page" /></a>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:text> </xsl:text>

    <xsl:if test="$page &lt; $total and $page &lt; ($current + $pagesperpagenav)">
        <xsl:call-template name="pageslinks">
            <xsl:with-param name="page" select="$page + 1" />
            <xsl:with-param name="current" select="$current" />
            <xsl:with-param name="total" select="$total" />
            <xsl:with-param name="url" select="$url" />
        </xsl:call-template>
    </xsl:if>

    <xsl:if test="$page = ($current + $pagesperpagenav)">
    ...
    </xsl:if>

</xsl:template>

<xsl:template name="pagenavtable">
    <xsl:variable name="navurl"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?m=',$m)"/><xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:variable>
    <xsl:if test="$totalpages &gt; 1">
        <table style="margin-left:5px; margin-right:10px; margin-top: 10px; margin-bottom: 0px; width: 99%; padding: 3px; border: thin solid #C1C1C1; background: #F9F9F9 font-size: small;" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <xsl:call-template name="pagenav">
                        <xsl:with-param name="totalitems" select="/document/context/object/children/@totalobjects"/>
                        <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
                        <xsl:with-param name="currentpage" select="$page"/>
                        <xsl:with-param name="url" select="$navurl"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:if>
</xsl:template>

<xsl:template name="childrentable">
    <xsl:variable name="location" select="concat($goxims_content,$absolute_path)"/>
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
                                    <a href="{$location}?sb=position;order=asc;m={$m}">
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
                                <a href="{$location}?sb=title;order=desc;m={$m}">
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
                                <a href="{$location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <xsl:call-template name="th-size"/>
                            <xsl:if test="$m='e'">
                                <xsl:call-template name="th-options"/>
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
                                    <a href="{$location}?sb=position;order=asc;m={$m}">
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
                                <a href="{$location}?sb=title;order=asc;m={$m}">
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
                                <a href="{$location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <xsl:call-template name="th-size"/>
                            <xsl:if test="$m='e'">
                                <xsl:call-template name="th-options"/>
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
                                    <a href="{$location}?sb=position;order=asc;m={$m}">
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
                                <a href="{$location}?sb=title;order=asc;m={$m}">
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
                                <a href="{$location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified_ascending.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <xsl:call-template name="th-size"/>
                            <xsl:if test="$m='e'">
                                <xsl:call-template name="th-options"/>
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
                                    <a href="{$location}?sb=position;order=asc;m={$m}">
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
                                <a href="{$location}?sb=title;order=asc;m={$m}">
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
                                <a href="{$location}?sb=date;order=asc;m={$m}">
                                    <img src="{$sklangimages}last_modified_descending.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_asc}"
                                            title="{$i18n/l/Sort_lm_asc}"
                                            />
                                </a>
                            </td>
                            <xsl:call-template name="th-size"/>
                            <xsl:if test="$m='e'">
                                <xsl:call-template name="th-options"/>
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
                                    <a href="{$location}?sb=position;order=desc;m={$m}">
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
                                <a href="{$location}?sb=title;order=asc;m={$m}">
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
                                <a href="{$location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <xsl:call-template name="th-size"/>
                            <xsl:if test="$m='e'">
                                <xsl:call-template name="th-options"/>
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
                                    <a href="{$location}?sb=position;order=asc;m={$m}">
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
                                <a href="{$location}?sb=title;order=asc;m={$m}">
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
                                <a href="{$location}?sb=date;order=desc;m={$m}">
                                    <img src="{$sklangimages}last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="{$i18n/l/Sort_lm_desc}"
                                            title="{$i18n/l/Sort_lm_desc}"
                                            />
                                </a>
                            </td>
                            <xsl:call-template name="th-size"/>
                            <xsl:if test="$m='e'">
                                <xsl:call-template name="th-options"/>
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

<xsl:template name="th-size">
    <td width="80">
        <img src="{$sklangimages}size.png"
                width="80"
                height="20"
                border="0"
                alt="{$i18n/l/Size}"
                title="{$i18n/l/Size} {$i18n/l/in} kB"
                />
    </td>
</xsl:template>

<xsl:template name="th-options">
    <td width="134">
        <img src="{$sklangimages}options.png"
                width="221"
                height="20"
                alt="{$i18n/l/Options}"
                title="{$i18n/l/Options}"
                />
    </td>
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
        <td background="{$skimages}containerlist_bg_transparent.gif">
            <xsl:call-template name="cttobject.last_modified"/>
        </td>
        <td background="{$skimages}containerlist_bg_transparent.gif" align="right">
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
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>
    <xsl:param name="dfmime" select="/document/data_formats/data_format[@id=current()/data_format_id]/mime_type"/>

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
        <xsl:when test="starts-with(location, 'index.')">
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
        <xsl:attribute name="title">id: <xsl:value-of select="@id"/>, <xsl:value-of select="$l_location"/>: <xsl:value-of
select="location"/>, <xsl:value-of select="$l_created_by"/>: <xsl:call-template name="creatorfullname"/>, <xsl:value-of select="$l_owned_by"/>: <xsl:call-template name="ownerfullname"/></xsl:attribute>
        <a>
          <xsl:attribute name="href">
            <xsl:choose>
                <xsl:when test="$dfmime='application/x-container'">
                    <xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?m=',$m)"/><xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                </xsl:when>
                <xsl:when test="$dfname='URL'">
                    <xsl:choose>
                        <xsl:when test="symname_to_doc_id != ''">
                            <xsl:value-of select="concat($goxims_content, symname_to_doc_id, '?m=',$m)"/><xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                        </xsl:when>
                        <xsl:when test="starts-with(location,'/')"><!--  Treat links relative to '/' as relative to the current SiteRoot -->
                            <xsl:value-of select="concat($goxims_content, '/', /document/context/object/parents/object[@parent_id=1]/location, location)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="location"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="marked_deleted=1">
                    <xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?m=',$m)"/>
                </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
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
href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};posview=yes;sbfield=reposition{@id}.new_position')"
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
                        name="m"
                        value="{$m}"/>
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
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=$dataformat]/name"/>
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>

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
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>
    <xsl:param name="dfmime" select="/document/data_formats/data_format[@id=current()/data_format_id]/mime_type"/>

   <!-- find a better way to do this (OT property "hasloblength" for example) -->
    <xsl:if test="$dfmime !='application/x-container'
            and $dfname!='URL'
            and $dfname!='SymbolicLink' ">
        <xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
        <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
