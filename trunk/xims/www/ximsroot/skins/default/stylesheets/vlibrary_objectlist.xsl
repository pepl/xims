<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output
     method="xml"
     encoding="utf-8"
     media-type="text/html"
     doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
     doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
     indent="no"/>


    <xsl:param name="page" select="1" />
    <xsl:param name="vls" />
    <xsl:param name="subject"/>
    <xsl:param name="subject_id"/>
    <xsl:param name="subject_name"/>
    <xsl:param name="author"/>
    <xsl:param name="author_id"/>
    <xsl:param name="author_name"/>
    <xsl:param name="publication"/>
    <xsl:param name="publication_id"/>
    <xsl:param name="publication_name"/>

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
                <xsl:value-of select="$author_name"/>
            </xsl:when>
            <xsl:when test="$publication">
                <xsl:value-of select="$publication_name"/>
            </xsl:when>
            <xsl:when test="$vls">
                <xsl:value-of select="$i18n/l/Search_for"/> '<xsl:value-of select="$vls"/>'
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


<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <script type="text/javascript">
        <xsl:comment>
        function setBg(elid){
            var els = document.getElementsByName(elid);
            /*
               This relies on the fact, that the second assigned stylesheet has
               sane background-color values defined in the first two rules.
            */

            var color0;
            var color1;

            /* IE and the Gecko behaves differently */
            if (document.all) {
                color0 = document.styleSheets[1].rules.item(0).style.backgroundColor;
                color1 = document.styleSheets[1].rules.item(1).style.backgroundColor;
            }
            else {
                color0 = document.styleSheets[1].cssRules[0].style.backgroundColor
                color1 = document.styleSheets[1].cssRules[1].style.backgroundColor
            }

            var i;
            for(i = 0;i&lt;els.length;i++){
                eval("els[i].style.backgroundColor = color"+(i%2));
            }
        }
        //</xsl:comment>
        </script>
        <body onLoad="setBg('vlchildrenlistitem');">
            <xsl:call-template name="header" />
            <h1 id="vlchildrenlisttitle">
                <xsl:value-of select="$objectname"/>
                <span style="font-size: small">
                    (<xsl:value-of select="$objectitems_count"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="decide_plural"/>)
                    <!--<xsl:value-of select="$i18n/l/items"/> -->
                </span>
            </h1>

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

            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="footer"/>
            </table>
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

    <xsl:variable name="totalpages" select="ceiling($totalitems div $itemsperpage)"/>

    <xsl:if test="$totalpages &gt; 1">
        <table style="margin-left:5px; margin-right:10px; margin-top: 10px; width: 99%; padding: 3px; border: thin solid #C1C1C1; background: #F9F9F9 font-size: small;" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <xsl:if test="$currentpage &gt; 1">
                        <a href="{$url};page={number($currentpage)-1}">&lt; <xsl:value-of select="$i18n/l/Previous_page"/></a>
                    </xsl:if>
                    <xsl:if test="$currentpage &gt; 1 and $currentpage &lt; $totalpages">
                        |
                    </xsl:if>
                    <xsl:if test="$currentpage &lt; $totalpages">
                        <a href="{$url};page={number($currentpage)+1}">&gt; <xsl:value-of select="$i18n/l/Next_page"/></a>
                    </xsl:if>
                </td>
            </tr>
            <tr>
                <td>
                    <xsl:call-template name="pageslinks">
                        <xsl:with-param name="page" select="1"/>
                        <xsl:with-param name="current" select="$currentpage"/>
                        <xsl:with-param name="total" select="$totalpages"/>
                        <xsl:with-param name="url" select="$url"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
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



<xsl:template name="childrenlist">
    <div id="vlchildrenlist">
        <xsl:apply-templates select="children/object" mode="divlist"/>
    </div>
</xsl:template>

<xsl:template match="children/object" mode="divlist">
    <div name="vlchildrenlistitem" class="vlchildrenlistitem">
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
    <div class="vltitle">
        <a  title="{$location}"
            href="{$xims_box}{$goxims_content}{$absolute_path}/{$location}">
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
