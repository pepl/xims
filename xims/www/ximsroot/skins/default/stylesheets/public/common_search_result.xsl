<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_search_result.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>
  <xsl:import href="../common_search_result.xsl"/>

  <xsl:output method="xml" 
              encoding="utf-8"
              media-type="text/html"
              doctype-system="about:legacy-compat"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              indent="no"/>
  
  <xsl:param name="sp"/>



  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head_default"/>
      <body>
        <xsl:comment>UdmComment</xsl:comment>
        <xsl:call-template name="header"/>
        <div id="leftcontent">
          <xsl:call-template name="stdlinks"/>
          <xsl:call-template name="departmentlinks"/>
          <xsl:call-template name="documentlinks"/>
        </div>
        <div id="centercontent">
          <xsl:comment>/UdmComment</xsl:comment>

          <xsl:call-template name="error_msg"/>
          <xsl:call-template name="searchform"/>

          <xsl:choose>
            <xsl:when test="/document/context/session/searchresultcount > 0">

              <div id="searchresults">
                <xsl:apply-templates select="/document/objectlist/object">
                  <xsl:sort select="concat(last_modification_timestamp/year
                                   ,last_modification_timestamp/month
                                   ,last_modification_timestamp/day
                                   ,last_modification_timestamp/hour
                                   ,last_modification_timestamp/minute)"
                            order="descending"/>
                </xsl:apply-templates>

              </div>

              <xsl:if test="$totalpages &gt; 1">
                <table style="margin-left:5px; margin-right:10px; margin-top: 10px; margin-bottom: 10px; width: 99%; padding: 3px; border: thin solid #C1C1C1; background: #F9F9F9 font-size: small;" border="0" cellpadding="0" cellspacing="0">
                  <tr>
                    <td>
                      <xsl:call-template name="pagenav">
                        <xsl:with-param name="totalitems" select="/document/context/session/searchresultcount"/>
                        <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
                        <xsl:with-param name="currentpage" select="$page"/>
                        <xsl:with-param name="url"
                                        select="concat($xims_box,$gopublic_content,$absolute_path,'?s=',$s,';search=1;p=1;sp',$sp)"/>
                      </xsl:call-template>
                    </td>
                  </tr>
                </table>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <div><strong><xsl:value-of select="$i18n/l/No_results"/>.</strong></div>
            </xsl:otherwise>
          </xsl:choose>

          <div id="footer">
            <span class="left">
              <xsl:call-template name="copyfooter"/>
            </span>
            <span class="right">
              <xsl:call-template name="powerdbyfooter"/>
            </span>
          </div>
        </div>
      </body>
      <xsl:call-template name="script_bottom"/>
    </html>
  </xsl:template>

  <xsl:template name="head_default">
    <head>
      <xsl:call-template name="meta"/>
      <title><xsl:value-of select="$i18n/l/Search_for"/> '<xsl:value-of select="$s"/>'</title>
      <xsl:call-template name="css"/>
    </head>
  </xsl:template>

  <xsl:template name="error_msg">
    <xsl:if test="/document/context/session/error_msg != ''">
      <p>
        <xsl:value-of select="/document/context/session/error_msg"/>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template name="searchform">
    <xsl:variable name="searchin">
      <xsl:choose>
        <xsl:when test="$sp != ''">
          '<xsl:value-of select="concat('/',substring-after(substring-after($sp,'/'),'/'))"/>'
        </xsl:when>
        <xsl:when test="$absolute_path_nosite != ''">
          '<xsl:value-of select="$absolute_path_nosite"/>'
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="Search" select="$i18n/l/Search"/>

    <table id="searchform" width="100%">
      <tr>
        <td>
          <form method="post" name="quicksearch" action="{$xims_box}{$goxims_content}{$absolute_path}">
            <xsl:value-of select="$i18n/l/Search_for"/><xsl:text> </xsl:text>
            <input class="inputtext" type="text" name="s" size="17" maxlength="200">
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
            <input class="inputsubmit" type="submit" name="search" title="Go" value="Go" />
            <input type="hidden" name="p" value="1"/>
            <input type="hidden" name="sp" value="{$sp}"/>
            <!--<xsl:if test="$searchin != ''"> (<xsl:value-of select="concat($i18n/l/in, $searchin)"/>)</xsl:if>-->
          </form>
        </td>
        <td align="right">
          <xsl:call-template name="searchresultinfo"/>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template name="searchresultinfo">
    <xsl:variable name="searchresultcount" select="/document/context/session/searchresultcount"/>
    <xsl:if test="$searchresultcount &gt; 0">
      <xsl:value-of select="$i18n/l/Results"/><xsl:text> </xsl:text>
      <xsl:value-of select="$page * $searchresultrowlimit - $searchresultrowlimit + 1"/>
      -
      <xsl:choose>
        <xsl:when test="$searchresultcount &gt;= ($page * $searchresultrowlimit)">
          <xsl:value-of select="$page * $searchresultrowlimit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$searchresultcount"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text><xsl:value-of select="$i18n/l/of"/><xsl:text> </xsl:text><xsl:value-of select="$searchresultcount"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="objectlist/object">
    <xsl:param name="dataformat" 
               select="data_format_id"/>
    <xsl:param name="dfname" 
               select="/document/data_formats/data_format[@id=$dataformat]/name"/>
    <xsl:param name="dfmime" 
               select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/>   
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>

    <xsl:variable name="publish_gopublic">
      <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
    </xsl:variable>
    
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="$dfname='URL'">
          <xsl:value-of select="location"/>
        </xsl:when>
        <xsl:when test="$publish_gopublic = 1">
          <xsl:value-of select="concat($gopublic_content,location_path)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($publishingroot,'/',substring-after(substring-after(location_path,'/'),'/'))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="searchresultitem">
      <div class="statustitle">
        <xsl:if test="marked_new= '1'">
          <img src="{$skimages}{$currentuilanguage}/status_markednew.png"
               border="0"
               width="26"
               height="19"
               title="{$i18n/l/Object_marked_new}"
               alt="{$i18n/l/New}"
               />
        </xsl:if>
        <!-- score -->
        <!--<xsl:value-of select="score_1__s"/>-->
        <xsl:call-template name="cttobject.dataformat"/>
        <span class="title">
          <a href="{$href}">
            <xsl:value-of select="title" />
          </a>
        </span>
      </div>
      <div class="location_path">
        <xsl:value-of select="$href"/>
      </div>
      <div class="meta">
        <xsl:value-of select="$i18n/l/Last_modified"/>: <xsl:apply-templates select="last_modification_timestamp" mode="ISO8601-MinNoT"/>
        <xsl:if test="$dfmime !='application/x-container'
                      and $dfname!='URL'
                      and $dfname!='SymbolicLink' ">
          <xsl:text>, </xsl:text><xsl:value-of select="format-number(content_length div 1024,'#####0.00')"/>kB
        </xsl:if>
      </div>
      <div class="abstract">
        <xsl:value-of select="abstract"/>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>

