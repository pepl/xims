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

    <xsl:output method="html"
                encoding="utf-8"
                media-type="text/html"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                indent="no"/>

    <xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
    <xsl:variable name="user_privileges" select="/document/context/object/user_privileges" />

    <xsl:param name="mo" />
    <xsl:param name="colms" select="3"/>
    <xsl:param name="vls"/>
    <xsl:param name="date_from" />
    <xsl:param name="date_to" />
    <xsl:param name="publications"/>
    <xsl:param name="authors"/>
    <xsl:param name="page" select="1" />
    <xsl:param name="subject"/>
    <xsl:param name="subject_id"/>
    <xsl:param name="subject_name"/>
    <xsl:param name="author"/>
    <xsl:param name="author_id"/>
    <xsl:param name="author_firstname"/>
    <xsl:param name="author_middlename"/>
    <xsl:param name="author_lastname"/>
    <xsl:param name="publication"/>
    <xsl:param name="publication_id"/>
    <xsl:param name="publication_name"/>
    <xsl:param name="publication_volume"/>
    <xsl:param name="most_recent"/>
    <xsl:param name="chronicle_from" />
    <xsl:param name="chronicle_to" />

    <xsl:template name="head_default">
        <head>
            <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
            <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}scripts/vlibrary_default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
    </xsl:template>

    <xsl:template name="item">
        <tr>
            <td>
                <xsl:call-template name="item_div">
                    <xsl:with-param name="mo" select="$mo"/>
                </xsl:call-template>
            </td>
            <xsl:for-each select="following-sibling::node()[position() &lt; $colms]">
                <td>
                    <xsl:call-template name="item_div">
                        <xsl:with-param name="mo" select="$mo"/>
                    </xsl:call-template>
                </td>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:template name="item_div">
        <div class="vliteminfo" name="vliteminfo" align="center">
            <xsl:choose>
                <xsl:when test="$mo = 'author'">
                    <div>
                        <xsl:call-template name="author_link"/>
                    </div>
                    <div>
                        <xsl:call-template name="item_count"/>
                    </div>
                </xsl:when>
                <xsl:when test="$mo = 'publication'">
                    <div>
                        <xsl:call-template name="publication_link"/>
                    </div>
                    <div>
                        <xsl:call-template name="item_count"/>
                    </div>
                </xsl:when>
                <xsl:when test="$mo = 'keyword'">
                    <div>
                        <xsl:call-template name="keyword_link"/>
                    </div>
                    <div>
                        <xsl:call-template name="item_count"/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div>
                        <xsl:call-template name="subject_link"/>
                    </div>
                    <div>
                        <xsl:call-template name="item_count"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$i18n_vlib/l/last_modified_at"/>
                        <br />
                        <xsl:apply-templates select="last_modification_timestamp" mode="datetime" />
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="item_count">
        <xsl:value-of select="object_count"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="decide_plural">
            <xsl:with-param name="objectitems_count" select="object_count"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="decide_plural">
        <xsl:choose>
            <xsl:when test="number($objectitems_count) = 1">
                <xsl:value-of select="$i18n_vlib/l/item"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$i18n_vlib/l/items"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="switch_vlib_views_action">
        <table cellpadding="0" cellspacing="0" style="margin: 0px;">
            <tr>
                <td valign="top">
                    <strong>
                        <xsl:value-of select="$i18n_vlib/l/Switch_to"/>
                    </strong>
                </td>
                <td valign="top">
                    <ul>
                        <xsl:if test="$mo != 'subject'">
                            <li>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?m={$m}">
                                    <xsl:value-of select="$i18n_vlib/l/subject_list"/>
                                </a>
                            </li>
                        </xsl:if>
                        <xsl:if test="$mo != 'author'">
                            <li>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?authors=1;m={$m}">
                                    <xsl:value-of select="$i18n_vlib/l/author_list"/>
                                </a>
                            </li>
                        </xsl:if>
                        <xsl:if test="$mo != 'publication'">
                            <li>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?publications=1;m={$m}">
                                    <xsl:value-of select="$i18n_vlib/l/publication_list"/>
                                </a>
                            </li>
                        </xsl:if>
                        <xsl:if test="$most_recent != '1'">
                            <li>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?most_recent=1;m={$m}">
                                    <xsl:value-of select="$i18n_vlib/l/Latest_entries"/>
                                </a>
                            </li>
                        </xsl:if>
                    </ul>
                </td>
            </tr>
        </table>
    </xsl:template>


    <xsl:template name="vlib_create_action">
        - <a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype=VLibraryItem::DocBookXML">
        <xsl:value-of select="$i18n_vlib/l/create_new_vlibraryitem"/>: DocBookXML
        </a>
        <br/>
        - <a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype=VLibraryItem::URLLink">
        <xsl:value-of select="$i18n_vlib/l/create_new_vlibraryitem"/>: URLLink
        </a>
        <br/>
        - <a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype=VLibraryItem::Document">
        <xsl:value-of select="$i18n_vlib/l/create_new_vlibraryitem"/>: Document
        </a>
    </xsl:template>

    <xsl:template name="vlib_search_action">
        <xsl:variable name="Search" select="$i18n_vlib/l/Fulltext_search"/>
        <form style="margin-bottom: 0px;" action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" name="vlib_search">
            <strong><xsl:value-of select="$Search"/></strong>
            <xsl:text>&#160;</xsl:text>
            <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" type="text" name="vls" size="17" maxlength="200">
            <xsl:if test="$vls != ''">
                <xsl:attribute name="value"><xsl:value-of select="$vls"/></xsl:attribute>
            </xsl:if>
            </input>
            <xsl:text>&#160;</xsl:text>
            <input type="image"
                    src="{$skimages}go.png"
                    name="submit"
                    width="25"
                    height="14"
                    alt="{$Search}"
                    title="{$Search}"
                    border="0"
                    style="vertical-align: text-bottom;"
            />
            <input type="hidden" name="start_here" value="1"/>
            <input type="hidden" name="vlsearch" value="1"/>
        </form>
    </xsl:template>

    <xsl:template name="author_link">
      <a href="{$xims_box}{$goxims_content}{$absolute_path}?author=1;author_id={id};author_firstname={firstname};author_middlename={middlename};author_lastname={lastname}">
        <xsl:value-of select="firstname"/>
        <xsl:text> </xsl:text>
        <xsl:if test="middlename">
          <xsl:value-of select="middlename"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="lastname"/></a>&#160;
        <!-- only show Edit-icon if user has the privilege "write" on the VLibray -->
        <xsl:if test="$user_privileges/write=1">
          <a href="javascript:editAuthorWindow('{$xims_box}{$goxims_content}{$absolute_path}?author_edit=1;author_id={id}')">
            <img src="{$skimages}option_edit.png" 
                 alt="{$i18n_vlib/l/manage_authors}" 
                 title="{$i18n_vlib/l/manage_authors}" />
          </a>
        </xsl:if>
    </xsl:template>


    <xsl:template name="publication_link">
        <xsl:variable name="publication_url" select="concat($xims_box,$goxims_content,$absolute_path,'?publication=1;publication_id=',id,';publication_name=',name,';publication_volume=',volume)"/>
        <a href="{$publication_url}">
            <xsl:value-of select="name"/> (<xsl:value-of select="volume"/>)
        </a>
    </xsl:template>

    <xsl:template name="subject_link">
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?subject=1;subject_id={id}">
            <xsl:value-of select="name"/>
        </a>&#160;
        <!-- only show Edit-icon if user has the privilege "write" on the VLibray -->
        <xsl:if test="$user_privileges/write=1">
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?subject_edit=1;subject_id={id}">
                <img src="{$skimages}option_edit.png" alt="{$i18n_vlib/l/manage_subjects}" title="{$i18n_vlib/l/manage_subjects}" />
            </a>
        </xsl:if>
        </xsl:template>

    <xsl:template name="keyword_link">
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?keyword=1;keyword_id={id}">
            <xsl:value-of select="name"/>
        </a>
    </xsl:template>

    <xsl:template name="search_switch">
        <xsl:param name="mo"/>
        <table width="100%" border="0" style="margin: 0px;" id="vlsearchswitch">
            <tr>
                <td valign="top" width="50%" align="center" class="vlsearchswitchcell">
                    <xsl:call-template name="vlib_search_action"/>
                </td>
                <td valign="top" width="50%" align="center" class="vlsearchswitchcell">
                    <xsl:call-template name="switch_vlib_views_action">
                        <xsl:with-param name="mo" select="$mo"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>

    <xsl:template name="chronicle_switch">
        <table width="100%" border="0" style="margin: 0px;" id="vlsearchswitch">
            <tr>
                <td valign="top" width="50%" align="center" class="vlsearchswitchcell">
        <form style="margin-bottom: 0px;" action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" name="vlib_searc\
h">
            Chronik von
            <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" type="text" name="chronicle_from" size="10" maxlength="200" value="{$chronicle_from}" />
            bis
            <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" type="text" name="chronicle_to" size="10" maxlength="200" value="{$chronicle_to}" />
            <xsl:text>&#160;</xsl:text>
            <input type="image"
                    src="{$skimages}go.png"
                    name="submit"
                    width="25"
                    height="14"
                    alt=""
                    title=""
                    border="0"
                    style="vertical-align: text-bottom;"
            />
            <input type="hidden" name="start_here" value="1"/>
            <input type="hidden" name="vlchronicle" value="1"/>
        </form>
                </td>
            </tr>
        </table>

    </xsl:template>

    <xsl:template name="mode_switcher">
        <xsl:variable name="vlqs" select="concat('publication=',$publication,';publication_id=',$publication_id,';author=',$author,';author_id=',$author_id,';subject=',$subject,';subject_id=',$subject_id,';publications=',$publications,';authors=',$authors,';page=',$page,';most_recent=',$most_recent)"/>
        <xsl:choose>
            <xsl:when test="$m='e'">
                <a href="{$goxims_content}{$absolute_path}?m=b;{$vlqs}"><xsl:value-of select="$i18n/l/switch_to_browse"/></a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{$goxims_content}{$absolute_path}?m=e;{$vlqs}"><xsl:value-of select="$i18n/l/switch_to_edit"/></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
