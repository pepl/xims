<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:dyn="http://exslt.org/dynamic"
                extension-element-prefixes="exslt dyn">

    <xsl:param name="filter"/>
    <xsl:param name="sid"/>
    <xsl:param name="kid"/>
    <xsl:param name="otid"/>
    <xsl:param name="mt"/>
    <xsl:param name="pbl"/>
    <xsl:param name="sto"/>
    <xsl:param name="status"/>
    <xsl:param name="cf"/>
    <xsl:param name="ct"/>

    <!-- Keep that in sync with the actually registered filter related params -->
    <xsl:variable name="filterparams">
        <fp name="vls"/>
        <fp name="sid"/>
        <fp name="kid"/>
        <fp name="otid"/>
        <fp name="mt"/>
        <fp name="pbl"/>
        <fp name="sto"/>
        <fp name="status"/>
        <fp name="cf"/>
        <fp name="ct"/>
    </xsl:variable>

  <xsl:variable name="xsl.order">
    <xsl:choose>
      <xsl:when test="$order='desc'">
        <xsl:text>descending</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>ascending</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

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
              <xsl:value-of select="/document/context/vlauthorinfo/author/firstname"/>
              <xsl:text> </xsl:text>
              <xsl:if test="string-length(/document/context/vlauthorinfo/author/middlename) &gt; 0">
                <xsl:value-of select="/document/context/vlauthorinfo/author/middlename"/>
                <xsl:text> </xsl:text>
              </xsl:if>
              <xsl:value-of select="/document/context/vlauthorinfo/author/lastname"/>
            </xsl:when>
            <xsl:when test="$keyword">
              <xsl:value-of select="/document/context/vlkeywordinfo/keyword/name"/>
            </xsl:when>
            <xsl:when test="$publication">
              <xsl:value-of select="/document/context/vlpublicationinfo/publication/name"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="/document/context/vlpublicationinfo/publication/volume"/>
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

    <xsl:variable name="objectdescription">
       <xsl:choose>
            <xsl:when test="$subject and /document/context/vlsubjectinfo/subject[id=$subjectID]/description/*">
              <div>
                <xsl:copy-of select="/document/context/vlsubjectinfo/subject[id=$subjectID]/description"/>
              </div>
            </xsl:when>
            <xsl:when test="$keyword and /document/context/vlkeywordinfo/keyword/description/*">
              <div>
                <xsl:copy-of select="/document/context/vlkeywordinfo/keyword/description"/>
              </div>
            </xsl:when>
       </xsl:choose>
    </xsl:variable>

    <xsl:variable name="objectitems_count">
        <xsl:choose>
            <xsl:when test="$subject">
                <xsl:value-of select="/document/context/vlsubjectinfo/subject/object_count"/>
            </xsl:when>
            <xsl:when test="$author">
                <xsl:value-of select="/document/context/vlauthorinfo/author/object_count"/>
            </xsl:when>
            <xsl:when test="$keyword">
                <xsl:value-of select="/document/context/vlkeywordinfo/keyword/object_count"/>
            </xsl:when>
            <xsl:when test="$publication">
                <xsl:value-of select="/document/context/vlpublicationinfo/publication/object_count"/>
            </xsl:when>
            <xsl:when test="/document/context/session/searchresultcount != ''">
                <xsl:value-of select="/document/context/session/searchresultcount"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(/document/context/object/children/object)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="totalpages">
      <xsl:choose>
        <xsl:when test="$onepage &gt; 0">
          <xsl:number value="1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number value="ceiling($objectitems_count div $pagerowlimit)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:template match="/document/context/object">
      <html>
        <xsl:call-template name="head_default"/>
        <body>
          <xsl:call-template name="header">
            <xsl:with-param name="createwidget">true</xsl:with-param>
            <xsl:with-param name="parent_id">
              <xsl:value-of select="/document/object_types/object_type[name='VLibraryItem']/@id" />
            </xsl:with-param>
          </xsl:call-template>

          <div id="vlbody">
            <h1 id="vlchildrenlisttitle">
              <xsl:value-of select="$objectname"/>
              <span style="font-size: small">
                <xsl:call-template name="items_page_info"/>
              </span>
            </h1>
            <xsl:copy-of select="$objectdescription"/>
            <xsl:call-template name="search_switch"/>
            <xsl:call-template name="chronicle_switch" />
            <xsl:call-template name="childrenlist"/>

            <xsl:if test="$totalpages &gt; 1">
              <xsl:variable name="pagenav.params">
                <xsl:choose>
                  <xsl:when test="$subject">
                    <xsl:value-of select="concat('?subject=1;subject_id=',$subjectID,';m=',$m)"/>
                  </xsl:when>
                  <xsl:when test="$author">
                    <xsl:value-of select="concat('?author=1;author_id=',$author_id,';m=',$m)"/>
                  </xsl:when>
                  <xsl:when test="$keyword">
                    <xsl:value-of select="concat('?keyword=1;keyword_id=',$keyword_id,';m=',$m)"/>
                  </xsl:when>
                  <xsl:when test="$publication">
                    <xsl:value-of select="concat('?publication=1;publication_id=',$publication_id,';m=',$m)"/>
                  </xsl:when>
                  <xsl:when test="$filter">
                      <xsl:call-template name="filterparams"/>
                  </xsl:when>
                  <xsl:when test="/document/context/session/searchresultcount != ''">
                    <xsl:value-of select="concat('?vls=',$vls,';vlsearch=1;start_here=1;m=',$m)"/>
                  </xsl:when>
                </xsl:choose>
                <xsl:if test="$pagerowlimit != $searchresultrowlimit">
                  <xsl:value-of select="concat(';pagerowlimit=',$pagerowlimit)"/>
                </xsl:if>
              </xsl:variable>

              <xsl:call-template name="pagenav">
                <xsl:with-param name="totalitems" select="$objectitems_count"/>
                <xsl:with-param name="itemsperpage" select="$pagerowlimit"/>
                <xsl:with-param name="currentpage" select="$page"/>
                <xsl:with-param name="url"
                                select="concat($xims_box
                                        ,$goxims_content
                                        ,$absolute_path
                                        ,$pagenav.params)"/>
              </xsl:call-template>
            </xsl:if>
          </div>

          <table align="center" width="98.7%" class="footer">
            <xsl:call-template name="footer"/>
          </table>
          <xsl:call-template name="jquery-listitems-bg">
            <xsl:with-param name="pick" select="'div.vlchildrenlistitem'"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:template>

<xsl:template name="cttobject.content_length">
    <xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>
</xsl:template>

<xsl:template name="items_page_info">
  (<xsl:value-of select="$objectitems_count"/>
  <xsl:text> </xsl:text>
  <xsl:call-template name="decide_plural"/>

  <xsl:if test="$totalpages &gt; 1">
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
                    <xsl:sort select="concat( last_modification_timestamp/year
                                             ,last_modification_timestamp/month
                                             ,last_modification_timestamp/day
                                             ,last_modification_timestamp/hour
                                             ,last_modification_timestamp/minute
                                             ,last_modification_timestamp/second)"
                              order="descending"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="children/object" mode="divlist">
                  <xsl:sort select="exslt:node-set( concat( last_modification_timestamp/year
                                                           ,last_modification_timestamp/month
                                                           ,last_modification_timestamp/day
                                                           ,last_modification_timestamp/hour
                                                           ,last_modification_timestamp/minute
                                                           ,last_modification_timestamp/second
                                                    )
                                    ) [$sb='date']
                                  | exslt:node-set( translate( title
                                                              ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                                                              ,'abcdefghijklmnopqrstuvwxyz'
                                                    )
                                    ) [$sb!='date']"
                            order="{$xsl.order}"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>

<xsl:template match="children/object" mode="divlist">
    <div class="vlchildrenlistitem" name="vlchildrenlistitem">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="authorgroup"/>
        <xsl:call-template name="last_modified"/>
        <xsl:call-template name="size"/>
        <span id="vlstatus_options">
            <xsl:call-template name="status"/>
            <xsl:if test="$m='e'">
                <xsl:call-template name="cttobject.options"/>
            </xsl:if>
        </span>
        <xsl:call-template name="urllink_status"/>
        <xsl:call-template name="meta"/>
        <xsl:apply-templates select="abstract"/>
    </div>
</xsl:template>


<xsl:template match="title">
    <xsl:variable name="dataformat" select="../data_format_id"/>
    <xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
    <xsl:variable name="dfname" select="$df/name"/>

    <xsl:variable name="location" select="../location"/>
    <xsl:variable name="hlsstring" select="concat('?hls=',$vls)"/>

    <div class="vltitle">
        <xsl:call-template name="cttobject.dataformat">
            <xsl:with-param name="dfname" select="$dfname"/>
        </xsl:call-template>
        &#xa0;
        <a  title="{$location}"
            href="{$xims_box}{$goxims_content}{$absolute_path}/{$location}{$hlsstring}">
            <xsl:apply-templates/>
        </a>
    </div>
</xsl:template>

<xsl:template name="cttobject.dataformat">
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>

    <img src="{$ximsroot}images/icons/list_{$dfname}.gif"
        border="0"
        alt="{$dfname}"
        title="{$dfname}"
    />
</xsl:template>

<xsl:template match="authorgroup">
    <xsl:variable name="author_count" select="count(author/lastname)"/>
    <xsl:if test="$author_count &gt; 0">
        <div class="vlauthorgroup">
            <strong>
                <xsl:if test="$author_count = 1">
                    <xsl:value-of select="$i18n_vlib/l/author"/>
                </xsl:if>
                <xsl:if test="$author_count &gt; 1">
                    <xsl:value-of select="$i18n_vlib/l/authors"/>
                </xsl:if>
                <xsl:text>: </xsl:text>
            </strong>
            <xsl:apply-templates select="author"/>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="author">
  <xsl:call-template name="property_link">
    <xsl:with-param name="mo" select="'author'"/>
  </xsl:call-template>
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

<xsl:template name="filterparams">
    <xsl:text>?filter=1</xsl:text>
    <xsl:for-each select="exslt:node-set($filterparams)/*">
        <xsl:variable name="paramvalue" select="dyn:evaluate(concat('$',@name))"/>
        <xsl:if test="$paramvalue"><xsl:value-of select="concat(';',@name,'=',$paramvalue)"/></xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template name="urllink_status">
    <xsl:if test="status != ''">
        <div class="vlurllinkstatus">
            <strong>
                <xsl:value-of select="$i18n_vlib/l/link_status"/>:
            </strong>
            <xsl:value-of select="status"/>
            &#xa0;
            <strong>
                <xsl:value-of select="$i18n_vlib/l/last_checked"/>:
            </strong>
            <xsl:apply-templates select="status_checked_timestamp" mode="datetime"/>
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
    <xsl:if test="number(content_length) &gt; 0">
        <span class="vlsize">
            <strong>, <xsl:value-of select="$i18n/l/Size"/>:</strong>
            <xsl:call-template name="cttobject.content_length"/>
            kb
        </span>
    </xsl:if>
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

<xsl:template name="meta">
  <xsl:if test="count(meta/date_from_timestamp/*) &gt; 0 or count(meta/date_to_timestamp/*) &gt; 0">
    <div class="vlmeta">
        <xsl:if test="meta/date_from_timestamp">
          <strong><xsl:value-of select="$i18n_vlib/l/chronicle_from"/>:</strong>&#xa0;
          <xsl:apply-templates select="meta/date_from_timestamp" mode="datetime"/>
        </xsl:if>
        &#xa0;
        <xsl:if test="meta/date_to_timestamp"><strong>
        <xsl:value-of select="$i18n_vlib/l/chronicle_to"/>:</strong>&#xa0;
        <xsl:apply-templates select="meta/date_to_timestamp" mode="datetime"/>
      </xsl:if>
    </div>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
