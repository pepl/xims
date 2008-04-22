<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="sdocbookxml_default.xsl"/>
  <xsl:import href="vlibrary_common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head_default"/>
      <base href="{$xims_box}{$goxims_content}{$absolute_path}/"/>
      <body onLoad="stringHighlight(getParamValue('hls'))">
        <xsl:call-template name="header"/>
        <xsl:call-template name="toggle_hls"/>
        <table align="center" 
               width="98.7%" 
               style="border: 1px solid; margin-top: 0px; padding: 0.5px">
          <tr>
            <td bgcolor="#ffffff">
              <span id="body">
                <xsl:call-template name="div-vlitemmeta"/>
                <h1><xsl:value-of select="title"/></h1>
                <xsl:choose>
                  <xsl:when test="$section > 0 and $section-view='true'">
                    <xsl:apply-templates select="$docbookroot" 
                                         mode="section-view"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="$docbookroot"/>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
            </td><!-- end #ffffff -->
          </tr>
        </table>
        <table align="center" 
               width="98.7%" 
               class="footer">
          <xsl:call-template name="user-metadata"/>
          <xsl:call-template name="footer"/>
        </table>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="keywordset">
    <strong>Keywords:</strong> 
    <xsl:apply-templates select="keyword"/>
  </xsl:template>


  <xsl:template match="subjectset">
    <strong>Subjects:</strong> 
    <xsl:apply-templates select="subject"/>
  </xsl:template>


  <xsl:template match="publicationset">
    <strong>Published in:</strong> 
    <xsl:apply-templates select="publication[name != '']"/>
  </xsl:template>


  <xsl:template match="keyword">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?keyword=1;keyword_id={id}">
      <xsl:value-of select="name"/>
    </a>
    <xsl:if test="position()!=last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="subject">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?subject=1;subject_id={id}">
      <xsl:value-of select="name"/>
    </a>
    <xsl:if test="position()!=last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="authorgroup">
    <strong>Authors:</strong> 
    <xsl:apply-templates select="author"/>
  </xsl:template>


  <xsl:template match="author">
    <xsl:call-template name="author_link"/>
    <xsl:if test="position()!=last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template name="author_link">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?author=1;author_id={id}">
      <xsl:value-of select="firstname"/>
      <xsl:text> </xsl:text>
      <xsl:if test="middlename">
        <xsl:value-of select="middlename"/>
        <xsl:text> </xsl:text>
      </xsl:if>
    <xsl:value-of select="lastname"/></a>
  </xsl:template>


  <xsl:template match="publication">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?publication=1;publication_id={id}"><xsl:value-of select="name"/><xsl:text> (</xsl:text><xsl:value-of select="volume"/>)</a>
    <xsl:if test="isbn != ''">
      ISBN: <xsl:value-of select="isbn"/>
    </xsl:if>
    <xsl:if test="issn != ''">
      ISSN: <xsl:value-of select="issn"/>
    </xsl:if>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
  </xsl:template>


  <xsl:template match="ulink">
    <a href="{@url}"><xsl:value-of select="text()"/></a>
  </xsl:template>


  <xsl:template name="div-vlitemmeta">
    <div id="vlitemmeta">
      <ul>
        <xsl:if test="meta/subtitle != ''">
          <li><strong>Subtitle:</strong> <xsl:value-of select="meta/subtitle"/></li>
        </xsl:if>
        <xsl:if test="abstract != ''">
          <li><strong>Abstract:</strong> <span><xsl:value-of select="abstract"/></span></li>
        </xsl:if>
        <xsl:if test="count(authorgroup/author) &gt; 0">
          <li><xsl:apply-templates select="authorgroup"/></li>
        </xsl:if>
        <xsl:if test="count(subjectset/subject) &gt; 0">
          <li><xsl:apply-templates select="subjectset"/></li>
        </xsl:if>
        <xsl:if test="count(keywordset/keyword) &gt; 0">
          <li><xsl:apply-templates select="keywordset"/></li>
        </xsl:if>
        <xsl:if test="count(publication/publication) &gt; 0">
          <li><xsl:apply-templates select="publicationset"/></li>
        </xsl:if> 
        <xsl:if test="meta/mediatype != ''">
          <li><strong>Mediatype:</strong> <xsl:apply-templates select="meta/mediatype"/></li>
        </xsl:if>
        <xsl:if test="meta/legalnotice != ''">
          <li><strong>Legalnotice:</strong> <xsl:apply-templates select="meta/legalnotice"/></li>
        </xsl:if>
        <xsl:if test="meta/bibliosource != ''">
          <li><strong>Releaseinfo:</strong> <xsl:apply-templates select="meta/bibliosource"/></li>
        </xsl:if>
        <xsl:if test="meta/coverage != ''">
          <li><strong>Coverage:</strong> <xsl:value-of select="meta/coverage"/></li>
        </xsl:if>
        <xsl:if test="meta/publisher != ''">
          <li><strong>Publisher:</strong> <xsl:value-of select="meta/publisher"/></li>
        </xsl:if>
        <xsl:if test="meta/audience != ''">
          <li><strong>Audience:</strong> <xsl:value-of select="meta/audience"/></li>
        </xsl:if>
        <xsl:if test="meta/dc_date != ''">
          <li><strong>DC.Date:</strong> <xsl:apply-templates select="meta/dc_date"  mode="date"/></li>
        </xsl:if>
        <xsl:if test="count(meta/date_from_timestamp/*) &gt; 0">
          <li><strong>Chronicle from:</strong> <xsl:apply-templates select="meta/date_from_timestamp"  mode="datetime"/></li>
        </xsl:if>
        <xsl:if test="count(meta/date_to_timestamp/*) &gt; 0">
          <li><strong>Chronicle to:</strong> <xsl:apply-templates select="meta/date_to_timestamp"  mode="datetime"/></li>
        </xsl:if>
      </ul>
    </div>
  </xsl:template>


</xsl:stylesheet>
