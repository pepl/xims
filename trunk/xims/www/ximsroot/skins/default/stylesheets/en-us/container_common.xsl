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

<xsl:param name="hd">1</xsl:param>

<xsl:template name="autoindex">
    <tr>
        <td colspan="3">
            Create an autoindex for this container during publishing:
            <input name="autoindex" type="radio" value="true">
                <xsl:if test="attributes/autoindex != '0'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input>Yes
            <input name="autoindex" type="radio" value="false">
                <xsl:if test="attributes/autoindex = '0'">
                    <xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
                </xsl:if>
            </input>No
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
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="Status"
                                            title="Status Information"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="Sort by position ascending"
                                                title="Click to sort position ascending"
                                        />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title&amp;order=desc;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title_ascending.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="Sort titles descending"
                                            title="Click to sort titles descending"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg_bright.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=""
                                        />
                            </td>
                            <td width="23">
                                <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner_bright.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="Sort modification dates ascending"
                                            title="Click to sort modification dates ascending" /></a>
                            </td>
                            <td width="80">
                                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="Size"
                                        title="Size in kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/options.png"
                                            width="189"
                                            height="20"
                                            alt="Options"
                                            title="Options"
                                            />
                                </td>
                            </xsl:if>
                        </tr>

                        <xsl:apply-templates select="children/object[user_privileges/view and marked_deleted!=$hd]">
                            <!-- as long as lower-first is not implemented, we probably have to use lowercase the title here -->
                            <xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        order="ascending"
                                        case-order="lower-first"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
                <xsl:when test="$order='desc'">
                    <table style="margin-left:5px; margin-right:5px" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <xsl:if test="$m='e'">
                                <td width="86">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="Status"
                                            title="Status information"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="Sort by position ascending"
                                                title="Click to sort position ascending"
                                        />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;order=asc;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title_descending.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="Sort titles ascending"
                                            title="Click to sort titles ascending"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg_bright.png">
                                <img src="{$ximsroot}images/spacer_white.gif" width="50" height="1" border="0" alt=""/>
                            </td>
                            <td width="23">
                                <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner_bright.png" width="23" height="20" alt="" title="" />
                            </td>
                            <td width="124">
                                <a href="{document/location}?sb=date;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="Sort modification dates ascending"
                                            title="Click to sort modification dates ascending"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="Size"
                                        title="Size in kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/options.png"
                                            width="189"
                                            height="20"
                                            alt="Options"
                                            title="Options"
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
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="Status"
                                            title="Status Information"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="Sort by position ascending"
                                                title="Click to sort position ascending"
                                        />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="Sort titles ascending"
                                            title="Click to sort titles ascending"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=" "/></td>
                            <td width="23">
                                <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=desc;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified_ascending.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="Sort modification dates descending"
                                            title="Click to sort modification dates descending"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="Size"
                                        title="Size in kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/options.png"
                                            width="189"
                                            height="20"
                                            alt="Options"
                                            title="Options"
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
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt = "Status"
                                            title="Status Information"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/position.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="Sort by position ascending"
                                                title="Click to sort position ascending"
                                        />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="Sort titles ascending"
                                            title="Click to sort titles ascending"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=""
                                        />
                            </td>
                            <td width="23">
                                <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=asc;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified_descending.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="Sort modification dates ascending"
                                            title="Click to sort modification dates ascending"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="Size"
                                        title="Size in kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/options.png"
                                            width="189"
                                            height="20"
                                            alt="Options"
                                            title="Options"
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
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt="Status"
                                            title="Status Information"
                                            />
                                </td>
                                <td nowrap="nowrap">
                                    <a href="{location}?sb=position;order=desc;m={$m}" alt="Sort position by ascending" title="Click to sort by position ascending">
                                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/position_ascending.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="Sort by position descending"
                                                title="Click to sort position descending"
                                        />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="42" height="20">
                                <a href="{location}?sb=title;m={$m}" alt="Sort titles ascending" title="Click to sort titles ascending">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="Sort titles ascending"
                                            title="Click to sort titles ascending"
                                            />
                                </a>
                            </td>
                            <td width="100%" height="20" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg.png">
                                <xsl:text>&#160;</xsl:text>
                            </td>
                            <td width="23">
                                <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=desc;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="Sort modification dates descending"
                                            title="Click to sort modification dates descending"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="Size"
                                        title="Size in kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/options.png"
                                            width="189"
                                            height="20"
                                            alt="Options"
                                            title="Options"
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
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status.png"
                                            width="86"
                                            height="20"
                                            border="0"
                                            alt = "Status"
                                            title="Status Information"
                                            />
                                </td>
                                <td>
                                    <a href="{location}?sb=position;order=asc;m={$m}">
                                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/position_descending.png"
                                                width="45"
                                                height="20"
                                                border="0"
                                                alt="Sort by position ascending"
                                                title="Click to sort position ascending"
                                        />
                                    </a>
                                </td>
                            </xsl:if>
                            <td width="51">
                                <a href="{location}?sb=title;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/title.png"
                                            width="45"
                                            height="20"
                                            border="0"
                                            alt="Sort titles ascending"
                                            title="Click to sort titles ascending"
                                            />
                                </a>
                            </td>
                            <td width="100%" background="{$ximsroot}skins/{$currentskin}/images/titlecolumn_bg.png">
                                <img src="{$ximsroot}images/spacer_white.gif"
                                        width="50"
                                        height="1"
                                        border="0"
                                        alt=""
                                        />
                            </td>
                            <td width="23">
                                <img src="{$ximsroot}skins/{$currentskin}/images/titlecolumn_rightcorner.png"
                                        width="23"
                                        height="20"
                                        alt=""
                                        />
                            </td>
                            <td width="124">
                                <a href="{location}?sb=date;order=asc;m={$m}">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/last_modified.png"
                                            width="124"
                                            height="20"
                                            border="0"
                                            alt="Sort modification dates ascending"
                                            title="Click to sort modification dates ascending"
                                            />
                                </a>
                            </td>
                            <td width="80">
                                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/size.png"
                                        width="80"
                                        height="20"
                                        border="0"
                                        alt="Size"
                                        title="Size in kB"
                                        />
                            </td>
                            <xsl:if test="$m='e'">
                                <td width="134">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/options.png"
                                            width="189"
                                            height="20"
                                            alt="Options"
                                            title="Options"
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
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:variable name="position">
        <xsl:value-of select="position"/>
    </xsl:variable>
    <tr height="20">
        <xsl:if test="$m='e'">
            <td width="86">
                <img src="{$ximsroot}images/spacer_white.gif" width="6" height="20" border="0" alt=" " />
                <xsl:choose>
                    <xsl:when test="marked_new= '1'">
                        <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status_markednew.png"
                                border="0"
                                width="26"
                                height="19"
                                title="This object is marked as new."
                                alt="New"
                                />
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                width="26"
                                height="19"
                                border="0"
                                alt=""
                                />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="published = '1'">
                        <a href="{$publishingroot}{$absolute_path}/{location}">
                            <img border="0"
                                    width="26"
                                    height="19"
                                    alt="Published"
                            >
                                <xsl:choose>
                                    <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                                        <xsl:attribute name="title">This object has last been published at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> by <xsl:call-template name="lastpublisherfullname"/> at <xsl:value-of select="concat($publishingroot,$absolute_path,'/',location)"/></xsl:attribute>
                                        <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub.png</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="title">This object has been modified since the last publication by <xsl:call-template name="lastpublisherfullname"/> at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>.</xsl:attribute>
                                        <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub_async.png</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </img>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                width="26"
                                height="19"
                                border="0"
                                alt=""
                                />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="locked_by_id != '' and locked_time != '' and locked_by_id = /document/context/session/user/@id">
                        <a href="{$goxims_content}?id={@document_id};cancel=1;r={/document/context/object/@document_id}">
                            <img src="{$ximsroot}skins/{$currentskin}/images/status_locked.png"
                                    width="26"
                                    height="19"
                                    border="0"
                                    alt="Unlock"
                                    title="Click here to remove your lock on this object."
                                    />
                        </a>
                    </xsl:when>
                    <xsl:when test="locked_by_id != '' and locked_time != ''">
                        <img src="{$ximsroot}skins/{$currentskin}/images/status_locked.png"
                                width="26"
                                height="19"
                                border="0"
                                alt="Locked"
                                >
                            <xsl:attribute name="title">This object has been locked at <xsl:apply-templates select="locked_time" mode="datetime"/> by <xsl:call-template name="lockerfullname"/>.</xsl:attribute>
                        </img>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                width="26"
                                height="19"
                                border="0"
                                alt=""
                                />
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        <!-- end of status information -->
            <td align="center">
                <xsl:choose>
                    <xsl:when test="$m='e' and /document/context/object/user_privileges/write=1">
                        <a
href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@document_id};posview=yes;sbfield=reposition{@id}.new_position')">
                            <xsl:apply-templates select="position"/>
                        </a>

                        <!-- the form is needed, so we can write the new position back without reloading this site from the positioning window -->
                        <form name="reposition{@id}"
                                style="margin:0px;"
                                method="get"
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
                        <xsl:apply-templates select="position"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- end of position -->
        </xsl:if>
        <td width="34">
            <xsl:choose>
                <xsl:when test="marked_deleted=1">
                    <xsl:attribute name="bgcolor">#c6c6c6</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <img src="{$ximsroot}images/spacer_white.gif" width="12" height="20" border="0" alt=" " />
            <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif"
                    border="0"
                    alt="{/document/data_formats/data_format[@id=$dataformat]/name}"
                    title="{/document/data_formats/data_format[@id=$dataformat]/name}"
                    />
        </td>
        <td colspan="2">
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
                        <xsl:value-of select="concat($ximsroot,'skins/',$currentskin,'/images/containerlist_bg_deleted.gif')"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="location='index.html'">
                    <xsl:attribute name="background">
                        <xsl:value-of select="concat($ximsroot,'skins/',$currentskin,'/images/containerlist_bg_hl.gif')"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="background">
                        <xsl:value-of select="concat($ximsroot,'skins/',$currentskin,'/images/containerlist_bg.gif')"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <span>
                <xsl:attribute name="title">docid: <xsl:value-of select="@document_id"/>, location: <xsl:value-of
select="location"/>, created by: <xsl:call-template name="creatorfullname"/>, owned by: <xsl:call-template name="ownerfullname"/></xsl:attribute>
                <a>
                    <xsl:choose>
                        <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='Container'">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat($goxims_content,$absolute_path,'/',location,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
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
        </td>
        <td>
            <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
            <span><xsl:attribute name="title">last modified by: <xsl:call-template name="modifierfullname"/></xsl:attribute>
                <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
            </span>
        </td>
        <td align="right">
            <!-- we may put /document/data-format[@id=$dataformat]/name into a var or find a better way to do this (OT property "hasloblength" for example) -->
            <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name!='Container' and /document/object_types/object_type[@id=$objecttype]/name!='URLLink' and /document/data_formats/data_format[@id=$objecttype]/name!='SymbolicLink'">
                <xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
                <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
            </xsl:if>
        </td>
        <xsl:if test="$m='e'">
            <td nowrap="nowrap" align="left">
                <!-- <img src="{$ximsroot}images/spacer_white.gif" width="4" border="0" alt="spacer 9x0" align="left" /> -->
                <xsl:choose>
                    <xsl:when test="marked_deleted != '1' and user_privileges/write = '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                        <a href="{$goxims_content}?id={@id};edit=1">
                            <img src="{$ximsroot}skins/{$currentskin}/images/option_edit.png"
                                    alt="Edit"
                                    title="Edit this object"
                                    border="0"
                                    width="32"
                                    height="19"
                                    onmouseover="pass('edit{@id}','edit','h'); return true;"
                                    onmouseout="pass('edit{@id}','edit','c'); return true;"
                                    onmousedown="pass('edit{@id}','edit','s'); return true;"
                                    onmouseup="pass('edit{@id}','edit','c'); return true;"
                                    name="edit{@document_id}"
                                    align="left"
                                    />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                width="32"
                                height="19"
                                border="0"
                                alt=""
                                align="left"
                                />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="marked_deleted != '1' and user_privileges/move and published != '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                        <a href="{$goxims_content}?id={@id};move_browse=1;to={@id}">
                            <img src="{$ximsroot}skins/{$currentskin}/images/option_move.png"
                                    border="0"
                                    alt="Move"
                                    title="Move this object"
                                    width="32"
                                    height="19"
                                    onmouseover="pass('move{@id}','move','h'); return true;"
                                    onmouseout="pass('move{@id}','move','c'); return true;"
                                    onmousedown="pass('move{@id}','move','s'); return true;"
                                    onmouseup="pass('move{@id}','move','c'); return true;"
                                    name="move{@id}"
                                    align="left"
                                    />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                border="0"
                                width="32"
                                height="19"
                                alt=""
                                align="left"
                                />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="marked_deleted != '1' and (user_privileges/publish|user_privileges/publish_all) and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                        <a href="{$goxims_content}?id={@id};publish_prompt=1">
                            <img src="{$ximsroot}skins/{$currentskin}/images/option_pub.png"
                                    border="0"
                                    alt="Publishing options"
                                    title="Publishing options"
                                    name="publish{@document_id}"
                                    width="32"
                                    height="19"
                                    align="left"
                                    />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                border="0"
                                width="32"
                                height="19"
                                alt=""
                                align="left"
                                />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="marked_deleted != '1' and (user_privileges/grant|user_privileges/grant_all) and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                        <a href="{$goxims_content}?id={@id};obj_acllist=1">
                            <img src="{$ximsroot}skins/{$currentskin}/images/option_acl.png"
                                    border="0"
                                    alt="Access control"
                                    title="Access control"
                                    width="32"
                                    height="19"
                                    align="left"
                                    />
                        </a>
                    </xsl:when>
                    <xsl:when test="marked_deleted = 1">
                        <a href="{$goxims_content}?id={@id};undelete=1">
                            <img src="{$ximsroot}skins/{$currentskin}/images/option_undelete.png"
                                    border="0"
                                    alt="Undelete"
                                    title="Undelete this object"
                                    width="32"
                                    height="19"
                                    align="left"
                                    />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                border="0"
                                width="32"
                                height="19"
                                alt=""
                                align="left"
                                />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="user_privileges/delete and marked_deleted = 1">
                        <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                        <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
                        <form style="margin:0px;" name="delete"
                                method="GET"
                                action="{$xims_box}{$goxims_content}">
                            <input type="hidden" name="delete_prompt" value="1"/>
                            <input type="hidden" name="id" value="{@id}"/>
                            <input
                                    type="image"
                                    name="del{@id}"
                                    src="{$ximsroot}skins/{$currentskin}/images/option_purge.png"
                                    border="0"
                                    width="37"
                                    height="19"
                                    alt="Permanent delete"
                                    title="Permanently delete this object"
                                    />
                        </form>
                    </xsl:when>
                    <xsl:when test="user_privileges/delete and published != '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                        <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                        <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
                        <form style="margin:0px;" name="trashcan"
                                method="GET"
                                action="{$xims_box}{$goxims_content}">
                            <input type="hidden" name="trashcan_prompt" value="1"/>
                            <input type="hidden" name="id" value="{@id}"/>
                            <input
                                    type="image"
                                    name="del{@id}"
                                    src="{$ximsroot}skins/{$currentskin}/images/option_delete.png"
                                    border="0"
                                    width="37"
                                    height="19"
                                    alt="Delete"
                                    title="Delete this object"
                                    />
                        </form>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                                border="0"
                                width="37"
                                height="19"
                                alt=""
                                />
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:if>
    </tr>
</xsl:template>

</xsl:stylesheet>
