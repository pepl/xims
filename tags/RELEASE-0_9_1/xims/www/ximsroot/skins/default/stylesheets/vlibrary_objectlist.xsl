<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:variable name="subjectID">
        <xsl:choose>
            <xsl:when test="$subject_name">
                <xsl:value-of select="/document/context/vlsubjectinfo/subject[name=$subject_name]/id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$subject_id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="objectname">
        <xsl:choose>
            <xsl:when test="$subject">
                <xsl:value-of select="/document/context/vlsubjectinfo/subject[id=$subjectID]/name"/>
            </xsl:when>
            <xsl:when test="$author">
                <xsl:value-of select="$author_firstname"/>
                <xsl:text> </xsl:text>
                <xsl:if test="string-length($author_middlename) &gt; 0">
                    <xsl:value-of select="$author_middlename"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="$author_lastname"/>
            </xsl:when>
            <xsl:when test="$publication">
                <xsl:value-of select="$publication_name"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$publication_volume"/>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:when test="$vls">
                <xsl:value-of select="$i18n/l/Search_for"/> '<xsl:value-of select="$vls"/>'
            </xsl:when>
            <xsl:when test="$most_recent">
                <xsl:value-of select="$i18n_vlib/l/Latest_entries"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="objectitems_count">
        <xsl:choose>
            <xsl:when test="$subject">
                <xsl:value-of select="/document/context/vlsubjectinfo/subject[id=$subjectID]/object_count"/>
            </xsl:when>
            <xsl:when test="/document/context/session/searchresultcount != ''">
                <xsl:value-of select="/document/context/session/searchresultcount"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(/document/context/object/children/object)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="objectitems_rowlimit" select="'5'"/>
    <xsl:variable name="totalpages" select="ceiling($objectitems_count div $objectitems_rowlimit)"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body onLoad="setBg('vlchildrenlistitem');">
            <xsl:call-template name="header" />

            <div id="vlbody">
                <h1 id="vlchildrenlisttitle">
                    <xsl:value-of select="$objectname"/>
                    <span style="font-size: small">
                        <xsl:call-template name="items_page_info"/>
                    </span>
                </h1>

                <xsl:call-template name="search_switch"/>

                <xsl:call-template name="childrenlist"/>

                <xsl:choose>
                    <xsl:when test="$subject">
                        <xsl:call-template name="pagenav">
                            <xsl:with-param name="totalitems" select="$objectitems_count"/>
                            <xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
                            <xsl:with-param name="currentpage" select="$page"/>
                            <xsl:with-param name="url"
                                            select="concat($xims_box,$goxims_content,$absolute_path,'?subject=1;subject_id=',$subjectID,';m=',$m)"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="/document/context/session/searchresultcount != ''">
                        <xsl:call-template name="pagenav">
                            <xsl:with-param name="totalitems" select="$objectitems_count"/>
                            <xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
                            <xsl:with-param name="currentpage" select="$page"/>
                            <xsl:with-param name="url"
                                            select="concat($xims_box,$goxims_content,$absolute_path,'?vls=',$vls,';vlsearch=1;start_here=1;m=',$m)"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template name="cttobject.content_length">
    <xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
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

    <xsl:if test="$page &lt; $total">
        <xsl:call-template name="pageslinks">
            <xsl:with-param name="page" select="$page + 1" />
            <xsl:with-param name="current" select="$current" />
            <xsl:with-param name="total" select="$total" />
            <xsl:with-param name="url" select="$url" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="items_page_info">
    (<xsl:value-of select="$objectitems_count"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="decide_plural"/>
    <xsl:if test="$subject">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$i18n_vlib/l/Page"/>
        <xsl:text> </xsl:text><xsl:value-of select="$page"/>/<xsl:value-of select="$totalpages"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template name="childrenlist">
    <div id="vlchildrenlist">
        <xsl:choose>
            <xsl:when test="$most_recent ='1'">
                <xsl:apply-templates select="children/object" mode="divlist">
                    <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="children/object" mode="divlist"/>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>

<xsl:template match="children/object" mode="divlist">
    <div class="vlchildrenlistitem" name="vlchildrenlistitem">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="authorgroup"/>
        <xsl:call-template name="last_modified"/>,
        <xsl:call-template name="size"/>
        <span id="vlstatus_options">
            <xsl:call-template name="status"/>
            <xsl:if test="$m='e'">
                <xsl:call-template name="cttobject.options"/>
            </xsl:if>
        </span>
        <xsl:apply-templates select="abstract"/>
    </div>
</xsl:template>


<xsl:template match="title">
    <xsl:variable name="location" select="../location"/>
    <xsl:variable name="hlsstring" select="concat('?hls=',$vls)"/>

    <div class="vltitle">
        <a  title="{$location}"
            href="{$xims_box}{$goxims_content}{$absolute_path}/{$location}{$hlsstring}">
            <xsl:apply-templates/>
        </a>
    </div>
</xsl:template>

<xsl:template match="authorgroup">
    <div class="vlauthorgroup">
        <xsl:variable name="author_count" select="count(author)"/>
        <strong>
            <xsl:if test="$author_count = 1">
                <xsl:value-of select="$i18n_vlib/l/author"/>
            </xsl:if>
            <xsl:if test="$author_count &gt; 1">
                <xsl:value-of select="$i18n_vlib/l/authors"/>
            </xsl:if>
            <xsl:text>: </xsl:text>
        </strong>

        <xsl:apply-templates select="author">
            <xsl:sort select="lastname" order="ascending"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="author">
    <xsl:call-template name="author_link"/>
    <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="abstract">
    <xsl:if test="text() != ''">
        <div class="vlabstract">
            <strong>
                <xsl:value-of select="$i18n/l/Abstract"/>
                <xsl:text>: </xsl:text>
            </strong>
            <xsl:apply-templates/>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="last_modified">
    <span class="vllastmodified">
        <strong>
            <xsl:value-of select="$i18n/l/Last_modified"/>:
        </strong>
        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
    </span>
</xsl:template>

<xsl:template name="size">
    <span class="vlsize">
        <strong>
            <xsl:value-of select="$i18n/l/Size"/>:
        </strong>
        <xsl:call-template name="cttobject.content_length"/>
        kb
    </span>
</xsl:template>

<xsl:template name="status">
    <span class="vlstatus">
        <xsl:call-template name="cttobject.status"/>
    </span>
</xsl:template>

<xsl:template name="cttobject.options">
    <span class="vloptions">
        <xsl:call-template name="cttobject.options.edit"/>
        <xsl:call-template name="cttobject.options.publish"/>
        <xsl:call-template name="cttobject.options.acl_or_undelete"/>
        <xsl:call-template name="cttobject.options.purge_or_delete"/>
    </span>
</xsl:template>

</xsl:stylesheet>
