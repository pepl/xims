<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="container_common.xsl"/>
    <xsl:import href="referencelibraryitem_common.xsl"/>

    <xsl:param name="onepage"/>
    <xsl:param name="date"/>
    <xsl:param name="author_id"/>
    <xsl:param name="serial_id"/>
    <xsl:param name="author_lname"/>
    <xsl:param name="reference_type_id"/>
    <xsl:param name="workgroup_id"/>
    <xsl:param name="reflibsearch"/>

    <xsl:variable name="objectitems_count"><xsl:choose><xsl:when test="/document/context/object/children/@totalobjects"><xsl:value-of select="/document/context/object/children/@totalobjects"/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:variable>
    <xsl:variable name="objectitems_rowlimit" select="'20'"/>
    <xsl:variable name="totalpages" select="ceiling($objectitems_count div $objectitems_rowlimit)"/>

    <!--<xsl:variable name="subjectcolumns" select="'3'"/>-->

    <xsl:template match="/document/context/object">
        <xsl:variable name="pagenavurl"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?date=',$date,';serial_id=',$serial_id,';author_id=',$author_id,';author_lname=',$author_lname,';workgroup_id=',$workgroup_id,';m=',$m)"/><xsl:if test="$reflibsearch != ''"><xsl:value-of select="concat(';reflibsearch=',$reflibsearch)"/></xsl:if></xsl:variable>
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header"/>

                <div id="vlbody">
                    <h1>
                        <xsl:value-of select="title"/>
                    </h1>

                    <xsl:call-template name="reflib.options"/>

                    <div id="reflib_resulttitle">
                        <table width="100%">
                            <tr>
                                <td>
                                    <xsl:if test="$date != '' or $author_id != '' or $reference_type_id != '' or $serial_id != '' or $author_lname != ''">
                                        <strong>Filtered View</strong>:
                                        <xsl:if test="$date != ''">
                                            <span class="reflib_filter">Date '<xsl:value-of select="$date"/>'</span></xsl:if>
                                        <xsl:if test="$serial_id != ''"><xsl:if test="$date != ''">, </xsl:if>
                                            <span class="reflib_filter">Serial '<xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>'</span></xsl:if>
                                        <xsl:if test="$reference_type_id != ''"><xsl:if test="$date != '' or $serial_id != ''">, </xsl:if>
                                            <span class="reflib_filter">Reference Type '<xsl:value-of select="/document/reference_types/reference_type[@id=$reference_type_id]/name"/>'</span></xsl:if>
                                        <xsl:if test="$author_id != ''"><xsl:if test="$date != '' or $serial_id != '' or $reference_type_id != ''">, </xsl:if>
                                            <span class="reflib_filter">Author '<xsl:value-of select="concat(children/object/authorgroup/author[id=$author_id]/firstname, ' ', children/object/authorgroup/author[id=$author_id]/lastname)" />'</span></xsl:if>
                                        <xsl:if test="$author_lname != ''"><xsl:if test="$date != '' or $serial_id != '' or $author_id != ''">, </xsl:if>
                                            <span class="reflib_filter">Author lastname '<xsl:value-of select="$author_lname"/>'</span></xsl:if>.
                                        <a href="{$xims_box}{$goxims_content}{$absolute_path}">Reset filter</a>
                                    </xsl:if>
                                </td>
                                <td align="right">
                                    <span style="font-size: small">
                                        <xsl:call-template name="items_page_info"/>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <xsl:call-template name="reflib.authorsearch"/>
                    <xsl:call-template name="pagenav">
                        <xsl:with-param name="totalitems" select="$objectitems_count"/>
                        <xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
                        <xsl:with-param name="currentpage" select="$page"/>
                        <xsl:with-param name="url" select="$pagenavurl"/>
                    </xsl:call-template>
                    <xsl:call-template name="childrenlist"/>
                    <xsl:call-template name="pagenav">
                        <xsl:with-param name="totalitems" select="$objectitems_count"/>
                        <xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
                        <xsl:with-param name="currentpage" select="$page"/>
                        <xsl:with-param name="url" select="$pagenavurl"/>
                    </xsl:call-template>
                </div>
                <xsl:call-template name="script_bottom"/>
                <script src="{$ximsroot}skins/{$currentskin}/scripts/tooltip.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            </body>
        </html>
    </xsl:template>

<xsl:template name="reference_type.createwidget">
    <xsl:apply-templates select="/document/reference_types/reference_type" mode="descriptions"/>
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0;" method="get" id="reftype_creator" name="reftype_creator">
        <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="reftype" id="reftype">
            <xsl:apply-templates select="/document/reference_types/reference_type" mode="selectoptions">
                <xsl:sort select="name" order="ascending"/>
            </xsl:apply-templates>
        </select>
        (<a href="javascript:void(0);" style="text-decoration:none;" onmouseover="fixedtooltip(getRefTypeDescription(document.reftype_creator.reftype.options[document.reftype_creator.reftype.selectedIndex].value), this, event, '200px')" onmouseout="delayhidetip()">?</a>)
            <input type="image"
                    name="create"
                    src="{$sklangimages}create.png"                    
                    alt="{$i18n/l/Create}"
                    title="{$i18n/l/Create}"/>
            <input name="page" type="hidden" value="{$page}"/>
            <input name="r" type="hidden" value="{/document/context/object/@id}"/>
            <input name="objtype" type="hidden" value="ReferenceLibraryItem"/>
            <xsl:if test="$defsorting != 1">
                <input name="sb" type="hidden" value="{$sb}"/>
                <input name="order" type="hidden" value="{$order}"/>
            </xsl:if>
    </form>
</xsl:template>

<xsl:template match="reference_type" mode="selectoptions">
    <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="reference_type" mode="descriptions">
    <div id="reftype{@id}" style="display: none;"><xsl:value-of select="description"/></div>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
        <script src="{$jquery}" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="jquery-listitems-bg">
          <xsl:with-param name="pick" select="'div.vlchildrenlistitem'"/>
        </xsl:call-template>

        <style type="text/css">
          #fixedtipdiv{
              position:absolute;
              padding: 2px;
              border:1px solid black;
              font: normal 10pt helvetica, arial, sans-serif;
              line-height: 18px;
              z-index: 100;
          }
        </style>
    </head>
</xsl:template>

<xsl:template name="childrenlist">
    <div id="vlchildrenlist">
        <xsl:apply-templates select="children/object" mode="divlist">
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="children/object" mode="divlist">
    <xsl:variable name="date" select="reference_values/reference_value[property_id=$daterefpropid]/value"/>
    <xsl:variable name="btitle" select="reference_values/reference_value[property_id=$btitlerefpropid]/value"/>
    <xsl:variable name="serial_id" select="serial_id"/>
    <div class="vlchildrenlistitem">
        <div class="reflib_authortitle">
            <xsl:choose>
                <xsl:when test="authorgroup/author">
                    <xsl:apply-templates select="authorgroup/author">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    Anonymous</xsl:otherwise>
            </xsl:choose>:
            <xsl:call-template name="reftitle"/>
            (<a href="{$xims_box}{$goxims_content}{$absolute_path}?reference_type_id={current()/reference_type_id}"><xsl:value-of select="/document/reference_types/reference_type[@id=current()/reference_type_id]/name"/></a>)
        </div>
        <div class="reflib_published">
            <strong>Published</strong>:
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?date={$date}">
                <xsl:value-of select="$date"/>
            </a>
            <xsl:if test="$serial_id != '' or $btitle != ''">,
                <strong>in</strong>:
                <xsl:choose>
                    <xsl:when test="$serial_id != ''">
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?serial_id={$serial_id}">
                            <xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$btitle"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </div>
        <xsl:if test="editorgroup/author">
            <div class="reflib_editors">
                <strong>Editors</strong>:
                    <xsl:apply-templates select="editorgroup/author">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
            </div>
        </xsl:if>
        <xsl:call-template name="last_modified"/>
            <xsl:call-template name="status"/>
            <xsl:if test="$m='e'">
                <span class="vloptions">
                    <xsl:call-template name="cttobject.options"/>
                </span>
            </xsl:if>
        <div class="vlabstract">
            <xsl:apply-templates select="abstract"/>
        </div>
    </div>
</xsl:template>

<xsl:template name="last_modified">
    <span class="vllastmodified">
        <strong>
            <xsl:value-of select="$i18n/l/Last_modified"/>:
        </strong>
        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
    </span>
</xsl:template>

<xsl:template name="status">
        <xsl:call-template name="cttobject.status"/>
</xsl:template>

<xsl:template name="reftitle">
    <span class="reftitle">
        <a  title="{location}"
            href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
            <xsl:value-of select="reference_values/reference_value[property_id=$titlerefpropid]/value"/>
        </a>
    </span>
</xsl:template>

<xsl:template name="items_page_info">
    (<xsl:value-of select="$objectitems_count"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="decide_plural"/>
    <xsl:if test="$onepage = '' and $totalpages > 0">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$i18n_vlib/l/Page"/>
        <xsl:text> </xsl:text><xsl:value-of select="$page"/>/<xsl:value-of select="$totalpages"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
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

<xsl:template name="reflib.authorsearch">
    <div id="reflib_authorsearch">
        <table>
            <tr>
                <td>
                    <div>
                        Search <a href="javascript:openDocWindow('SearchingReferenceLibraries')" class="doclink">(?)</a>:<br/>
                        Example: <em>zoller serial:"Phys. Rev" date:2005</em>
                    </div>
                </td>
                <td align="right">
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}">
                        <input type="text" name="reflibsearch" id="reflibsearch" size="42" maxlength="200">
                            <xsl:if test="$reflibsearch != ''">
                                <xsl:attribute name="value"><xsl:value-of select="$reflibsearch"/></xsl:attribute>
                        </xsl:if>
                        </input>
                        <xsl:text>&#160;</xsl:text>
                        <input type="image"
                                src="{$skimages}go.png"
                                name="submit"
                                alt="{$i18n/l/search}"
                                title="{$i18n/l/search}"
                                style="vertical-align: text-bottom;"
                        />
                    </form>
                </td>
            </tr>
        </table>
    </div>
</xsl:template>

<xsl:template name="reflib.options">
    <div id="reflib_options">
        <table align="center" cellpadding="5" style="border: 1px dotted black; margin-bottom: 5px;">
            <tr>
                <td colspan="2" style="border: 1px dotted black;">
                    <xsl:if test="$m='e' and /document/context/object/user_privileges/create">
                        <div class="vlitemcreate">
                            <xsl:call-template name="reference_type.createwidget"/>
                        </div>
                     </xsl:if>
                </td>
                <td style="border: 1px dotted black;">
                    <div>
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?import_prompt=1">Import</a>
                    </div>
                </td>
            </tr>
            <tr>
                <td style="border: 1px dotted black;">
                    <div>
                        View citations <xsl:call-template name="reflib_citationview"/>
                    </div>
                </td>
                <td style="border: 1px dotted black;">
                    <div>
                        <!--<a href="{$xims_box}{$goxims_content}{$absolute_path}?serials=1">-->Serials<!--</a>-->
                    </div>
                </td>
                <td style="border: 1px dotted black;">
                    <div>
                        Export MODS file <xsl:call-template name="reflib_exportwidget"/>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</xsl:template>

<xsl:template name="reflib_exportwidget">
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="display: inline; margin-bottom: 0;" method="get" id="export" name="export">
        <xsl:if test="$reflibsearch != ''">
            <input type="hidden" name="reflibsearch" value="{$reflibsearch}"/>
        </xsl:if>
        <input type="hidden" name="author_lname" value="{$author_lname}"/>
        <input type="hidden" name="author_id" value="{$author_id}"/>
        <input type="hidden" name="serial_id" value="{$serial_id}"/>
        <input type="hidden" name="date" value="{$date}"/>
        <input type="hidden" name="style" value="export_mods"/>
        <input type="image"
                name="export"
                src="{$skimages}go.png"
                alt="{$i18n/l/search}"
                title="{$i18n/l/search}"
                style="vertical-align: text-bottom;" />
    </form>
</xsl:template>

<xsl:template name="reflib_citationview">
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="display: inline; margin-bottom: 0;" method="get" id="citation_view" name="citation_view">
        <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="style" id="style">
            <option value="cv_defaultstyle" selected="selected">default style</option>
            <option value="cv_printstyle">print style</option>
            <option value="cv_wordmlstyle">WordML</option>
        
        </select>
        <xsl:if test="$reflibsearch != ''">
            <input type="hidden" name="reflibsearch" value="{$reflibsearch}"/>
        </xsl:if>
        <input type="hidden" name="author_lname" value="{$author_lname}"/>
        <input type="hidden" name="author_id" value="{$author_id}"/>
        <input type="hidden" name="serial_id" value="{$serial_id}"/>
        <input type="hidden" name="date" value="{$date}"/>
        <input type="image"
                name="citations"
                src="{$skimages}go.png"
                alt="{$i18n/l/search}"
                title="{$i18n/l/search}"
                style="vertical-align: text-bottom;" />
    </form>
</xsl:template>

</xsl:stylesheet>
