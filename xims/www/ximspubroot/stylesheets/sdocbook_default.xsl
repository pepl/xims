<?xml version="1.0" encoding="UTF-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml"
>

<xsl:import href="include/default_header.xsl"/>
<xsl:import href="include/common.xsl"/>

<xsl:output method="html" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

<xsl:param name="section" select="'0'"/>
<xsl:param name="section-view" select="'false'"/>

<xsl:template match="/">
<html>
    <head>
        <title><xsl:value-of select="article/rdf:RDF/rdf:Description/dc:title/text()"/></title>
        <xsl:call-template name="meta">
          <xsl:with-param name="context_node" select="article"/>
        </xsl:call-template>
        <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css" />
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css" />
    </head>
    <body>
    <xsl:comment>UdmComment</xsl:comment>
    <xsl:call-template name="header"/>
    <div id="leftcontent">
        <xsl:call-template name="stdlinks"/>
        <xsl:call-template name="departmentlinks">
            <xsl:with-param name="context" select="article"/>
        </xsl:call-template>
    </div>
    <div id="centercontent">
        <xsl:comment>/UdmComment</xsl:comment>
            [<a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="$section-view='true'">
                            <xsl:value-of select="concat(request.uri, '?section-view=false')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(request.uri, '?section-view=true')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                Toggle Multi-page View
            </a>
            ]
            <xsl:choose>
                <xsl:when test="$section > 0 and $section-view='true'">
                    <xsl:apply-templates select="article" mode="section-view"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="article"/>
                </xsl:otherwise>
            </xsl:choose>
        <xsl:comment>/UdmComment</xsl:comment>
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
</html>
</xsl:template>

    <xsl:template match="article">
        <h1><xsl:value-of select="/article/title | /article/articleinfo/title"/></h1>

        <!-- begin frontmatter -->
        <p>By:
            <xsl:for-each select="articleinfo/authorgroup/author | articleinfo/author">
                <a href="mailto:{authorblurb/para/email}">
                    <xsl:value-of select="firstname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="surname"/>
                </a>
                <xsl:if test="affiliation/orgname/text()"> (<xsl:value-of select="affiliation/orgname/text()"/>)</xsl:if>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </p>
        <xsl:apply-templates select="articleinfo/abstract/*"/>
        <!-- end frontmatter -->

        <!-- begin toc -->
        <div class="toc">
            <a name="toc"><h2>Contents</h2></a>
            <xsl:apply-templates select="(section)" mode="toc"/>
        </div>
        <!-- end toc -->

        <!-- begin main content -->

        <xsl:if test="$section-view='false'">
            <div class="main-content">
                <xsl:apply-templates select="section" />
            </div>
        </xsl:if>

        <!-- begin footer -->
        <xsl:call-template name="sdbkfooter"/>
        <!-- end footer -->

    </xsl:template>

    <xsl:template match="article" mode="section-view">
        <h1 class="section-title1"><xsl:value-of select="/article/title | /article/articleinfo/title"/></h1>

        <!-- begin toc -->
        <div class="toc">
            <span class="toc-item">
                <a name="toc"><a href="{$request.uri}?section-view=true;">Table of Contents</a></a>
            </span>
            <xsl:apply-templates select="./section[position()=$section]" mode="toc"/>
        </div>
        <!-- end toc -->

        <!-- begin main content -->
        <div class="main-content">
            <xsl:apply-templates select="./section[position()=$section]"/>
        </div>
        <!-- end main content -->

        <!-- begin footer -->
        <xsl:call-template name="sdbkfooter"/>
        <!-- end footer -->
    </xsl:template>

    <xsl:template match="section">
        <div class="section">
            <xsl:attribute name="id">
                <xsl:choose>
                    <xsl:when test="@label">
                        <xsl:value-of select="@label"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="translate(title, ' -)(?:&#xA;', '')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <xsl:element name="h{number( count(ancestor-or-self::section) + 1)}">
                <a name="{translate(title, ' -)(?:&#xA;', '')}">
                    <xsl:value-of select="title"/>
                </a>
            </xsl:element>

            <xsl:apply-templates/>

            <xsl:if test=" count(parent::section) = 0">
                <p>
                    [
                    <a href="#toc">
                        top
                    </a>
                    ]
                </p>
            </xsl:if>

        </div>
    </xsl:template>

    <xsl:template match="section"  mode="toc">
        <div class="toc-item" id="{generate-id()}">
            <xsl:choose>
                <xsl:when test="$section-view='true'">
                    <xsl:choose>
                        <xsl:when test="count(ancestor-or-self::section) = 1">
                            <xsl:variable name="page-number" select="count(preceding-sibling::section) + 1"/>

                            <!-- begin TOC page (section 0) for multi-page mode -->
                            <xsl:if test="$section-view='true' and $section = 0">

                                <!-- <a href="{$request.uri}?section-view=true;section={count(preceding-sibling::section) +1}"> -->
                                <a href="{$request.uri}?section-view=true;section={$page-number};">
                                    <xsl:value-of select="title"/>
                                </a>
                            </xsl:if>
                            <!-- end TOC page (section 0) for multi-page mode -->

                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="page-number" select="count(ancestor::section[count(ancestor-or-self::section) = 1]/preceding-sibling::section) + 1"/>
                            <a href="{$request.uri}?section-view=true;section={$page-number};#{translate(title, ' -)(?:&#xA;', '')}">
                                <xsl:value-of select="title"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <a href="#{translate(title, ' -)(?:&#xA;', '')}">
                        <xsl:value-of select="title"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="section" mode="toc"/>
        </div>
    </xsl:template>


    <!-- begin named XSL templates -->

    <!-- begin footer template -->
    <xsl:template name="sdbkfooter">
        <xsl:if test="$section-view='true'">
            <div class="footer-nav">
                <!-- it sucks that we have to use a table here but CSS is still a "future technology" i guess :-( -->
                <table width="100%" border="0" cellpadding="2" cellspacing="0">
                    <tr valign="top">
                        <td>
                            <xsl:choose>
                                <xsl:when test="$section > 0">Prev:
                                    <a href="{$request.uri}?section={$section -1};section-view=true">
                                        <xsl:choose>
                                            <xsl:when test="/article/section[$section -1]">
                                                <xsl:value-of select="/article/section[$section -1]/title"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>Table of Contents</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td align="right">
                            <xsl:choose>
                                <xsl:when test="/article/section[$section +1]">
                                Next: <a href="{$request.uri}?section={$section +1};section-view=true;">
                                        <xsl:value-of select="/article/section[$section +1]/title"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    &#160;
                                </xsl:otherwise>
                            </xsl:choose>
                        </td></tr>
                </table>
            </div>
        </xsl:if>
        <div class="legal">
            <xsl:choose>
                <xsl:when test="/article/articleinfo/legalnotice">
                    <xsl:apply-templates select="/article/articleinfo/legalnotice/*"/>
                </xsl:when>
                <xsl:otherwise>
                    <p/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- end footer template -->

    <!-- end named XSL templates -->

    <!-- begin core sdocbook elements -->
    <xsl:template match="para">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="itemizedlist">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="orderedlist">
        <ol>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>

    <xsl:template match="listitem">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="ulink">
        <a href="{@url}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="xref|link">
        <a href="#{@linkend}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- seems correct for sdocbook -->
    <xsl:template match="email">
      <a href="mailto:{.}">
            <xsl:value-of select="."/>
      </a>
    </xsl:template>

    <xsl:template match="programlisting">
        <div class="programlisting">
            <pre>
                <xsl:apply-templates/>
            </pre>
        </div>
    </xsl:template>

    <xsl:template match="filename | userinput | computeroutput | literal">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>

    <xsl:template match="literallayout">
        <pre>
            <xsl:apply-templates/>
        </pre>
    </xsl:template>

    <xsl:template match="emphasis">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="blockquote">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>

    <xsl:template match="inlinemediaobject">
        <span class="mediaobject">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="mediaobject">
        <div class="mediaobject">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="imageobject">
        <img src="{imagedata/@fileref}"/>
    </xsl:template>

    <xsl:template match="caption">
        <div class="{name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="note|important|warning|caution|tip">
        <div class="{name(.)}">
            <h3 class="title">
                <a>
                    <xsl:attribute name="name">
                        <xsl:call-template name="object.id"/>
                    </xsl:attribute>
                </a>
                <xsl:value-of select="concat(translate(substring(name(.),1,1),'niwct','NIWCT'),substring(name(.),2,string-length(name(.)-1)))"/>
            </h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!--the following is a slightly adapted excerpt of Norman Walsh's table.xsl -->

    <xsl:template match="table">
        <xsl:apply-templates select="tgroup"/>
    </xsl:template>

    <xsl:template match="tgroup">
        <table>
        <xsl:if test="../@pgwide=1">
            <xsl:attribute name="width">100%</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="border">0</xsl:attribute>

        <xsl:apply-templates select="thead"/>
        <xsl:apply-templates select="tbody"/>
        <xsl:apply-templates select="tfoot"/>

        <xsl:if test=".//footnote">
            <tbody class="footnotes">
                <tr>
                    <td colspan="{@cols}">
                        <xsl:apply-templates select=".//footnote"
                                             mode="table.footnote.mode"/>
                    </td>
                </tr>
            </tbody>
        </xsl:if>
        </table>
    </xsl:template>

    <xsl:template match="colspec"></xsl:template>

    <xsl:template match="spanspec"></xsl:template>

    <xsl:template match="thead|tfoot">
        <xsl:element name="{name(.)}">
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tbody">
        <tbody>
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>

    <xsl:template match="row">
        <tr>
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="thead/row/entry">
        <xsl:call-template name="process.cell">
            <xsl:with-param name="cellgi">th</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="tbody/row/entry">
        <xsl:call-template name="process.cell">
            <xsl:with-param name="cellgi">td</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="tfoot/row/entry">
        <xsl:call-template name="process.cell">
            <xsl:with-param name="cellgi">th</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="process.cell">
        <xsl:param name="cellgi">td</xsl:param>
        <xsl:variable name="empty.cell" select="count(node()) = 0"/>
        <xsl:variable name="entry.colnum">
            <xsl:call-template name="entry.colnum"/>
        </xsl:variable>

        <xsl:if test="$entry.colnum != ''">
            <xsl:variable name="prev.entry" select="preceding-sibling::*[1]"/>
            <xsl:variable name="prev.ending.colnum">
                <xsl:choose>
                    <xsl:when test="$prev.entry">
                        <xsl:call-template name="entry.ending.colnum">
                            <xsl:with-param name="entry" select="$prev.entry"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

        </xsl:if>

        <xsl:element name="{$cellgi}">
            <xsl:if test="@morerows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@morerows+1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@namest">
                <xsl:attribute name="colspan">
                    <xsl:call-template name="calculate.colspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="class">orange</xsl:attribute>
            <xsl:choose>
                <xsl:when test="$empty.cell">
                    <xsl:text>&#160;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template name="entry.colnum">
        <xsl:param name="entry" select="."/>

        <xsl:choose>
            <xsl:when test="$entry/@colname">
                <xsl:variable name="colname" select="$entry/@colname"/>
                <xsl:variable name="colspec"
                              select="$entry/ancestor::tgroup/colspec[@colname=$colname]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entry/@namest">
                <xsl:variable name="namest" select="$entry/@namest"/>
                <xsl:variable name="colspec"
                              select="$entry/ancestor::tgroup/colspec[@colname=$namest]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($entry/preceding-sibling::*) = 0">1</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="pcol">
                    <xsl:call-template name="entry.ending.colnum">
                        <xsl:with-param name="entry"
                                        select="$entry/preceding-sibling::*[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$pcol + 1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="entry.ending.colnum">
        <xsl:param name="entry" select="."/>

        <xsl:choose>
            <xsl:when test="$entry/@colname">
                <xsl:variable name="colname" select="$entry/@colname"/>
                <xsl:variable name="colspec"
                              select="$entry/ancestor::tgroup/colspec[@colname=$colname]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entry/@nameend">
                <xsl:variable name="nameend" select="$entry/@nameend"/>
                <xsl:variable name="colspec"
                              select="$entry/ancestor::tgroup/colspec[@colname=$nameend]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($entry/preceding-sibling::*) = 0">1</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="pcol">
                    <xsl:call-template name="entry.ending.colnum">
                        <xsl:with-param name="entry"
                                        select="$entry/preceding-sibling::*[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$pcol + 1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="colspec.colnum">
        <xsl:param name="colspec" select="."/>
        <xsl:choose>
            <xsl:when test="$colspec/@colnum">
                <xsl:value-of select="$colspec/@colnum"/>
            </xsl:when>
            <xsl:when test="$colspec/preceding-sibling::colspec">
                <xsl:variable name="prec.colspec.colnum">
                    <xsl:call-template name="colspec.colnum">
                        <xsl:with-param name="colspec"
                                        select="$colspec/preceding-sibling::colspec[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$prec.colspec.colnum + 1"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="calculate.colspan">
        <xsl:param name="entry" select="."/>
        <xsl:variable name="namest" select="$entry/@namest"/>
        <xsl:variable name="nameend" select="$entry/@nameend"/>

        <xsl:variable name="scol">
            <xsl:call-template name="colspec.colnum">
                <xsl:with-param name="colspec"
                                select="$entry/ancestor::tgroup/colspec[@colname=$namest]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ecol">
            <xsl:call-template name="colspec.colnum">
                <xsl:with-param name="colspec"
                                select="$entry/ancestor::tgroup/colspec[@colname=$nameend]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$ecol - $scol + 1"/>
    </xsl:template>

    <!--table.xsl end-->

    <!--the "css forwarder" template
    These are the sdocbook elements
    for which there is no reasonable
    HTML counterpart structure but to
    which a designer may want to add some
    visual distiction via CSS -->

    <xsl:template match="authorinitials">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!--the "vanilla" template
    these are the sdocbook elements
    for which there is no reasonable
    HTML counterpart or straightforward
    meaningful visual format -->

    <xsl:template match="honorific">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="title"></xsl:template>
    <!-- end core sdocbook elements -->

    <!-- this is from footnote.xsl -->

    <xsl:template match="footnote">
        <xsl:variable name="name">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#ftn.</xsl:text>
            <xsl:call-template name="object.id"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="ancestor::table|ancestor::informaltable">
                <sup>
                    <xsl:text>[</xsl:text>
                    <a name="{$name}" href="{$href}">
                        <xsl:apply-templates select="." mode="footnote.number"/>
                    </a>
                    <xsl:text>]</xsl:text>
                </sup>
            </xsl:when>
            <xsl:otherwise>
                <sup>
                    <xsl:text>[</xsl:text>
                    <a name="{$name}" href="{$href}">
                        <xsl:apply-templates select="." mode="footnote.number"/>
                    </a>
                    <xsl:text>]</xsl:text>
                </sup>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="footnoteref">
        <xsl:variable name="targets" select="id(@linkend)"/>
        <xsl:variable name="footnote" select="$targets[1]"/>
        <xsl:variable name="href">
            <xsl:text>#ftn.</xsl:text>
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="$footnote"/>
            </xsl:call-template>
        </xsl:variable>
        <sup>
            <xsl:text>[</xsl:text>
            <a href="{$href}">
                <xsl:apply-templates select="$footnote" mode="footnote.number"/>
            </a>
            <xsl:text>]</xsl:text>
        </sup>
    </xsl:template>

    <xsl:template match="footnote" mode="footnote.number">
        <xsl:choose>
            <xsl:when test="ancestor::table|ancestor::informaltable">
                <xsl:number level="any" from="table|informaltable" format="a"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" format="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==================================================================== -->

    <xsl:template match="footnote/para[1]">
        <!-- this only works if the first thing in a footnote is a para, -->
        <!-- which is ok, because it usually is. -->
        <xsl:variable name="name">
            <xsl:text>ftn.</xsl:text>
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="ancestor::footnote"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#</xsl:text>
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="ancestor::footnote"/>
            </xsl:call-template>
        </xsl:variable>
        <p>
            <sup>
                <xsl:text>[</xsl:text>
                <a name="{$name}" href="{$href}">
                    <xsl:apply-templates select="ancestor::footnote"
                                         mode="footnote.number"/>
                </a>
                <xsl:text>] </xsl:text>
            </sup>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- ==================================================================== -->

    <xsl:template name="process.footnotes">
        <xsl:variable name="footnotes" select=".//footnote"/>
        <xsl:variable name="table.footnotes"
                      select=".//table//footnote|.//informaltable//footnote"/>

        <!-- Only bother to do this if there's at least one non-table footnote -->
        <xsl:if test="count($footnotes)>count($table.footnotes)">
            <div class="footnotes">
                <br/>
                <xsl:apply-templates select="$footnotes" mode="process.footnote.mode"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="process.chunk.footnotes">
        <!-- nop -->
    </xsl:template>

    <xsl:template match="footnote" mode="process.footnote.mode">
        <div class="{name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="informaltable//footnote|table//footnote"
                  mode="process.footnote.mode">
    </xsl:template>

    <xsl:template match="footnote" mode="table.footnote.mode">
        <div class="{name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- this was from footnote.xsl -->

    <!-- this was from common.xsl -->

    <xsl:template name="object.id">
        <xsl:param name="object" select="."/>
        <xsl:choose>
            <xsl:when test="$object/@id">
                <xsl:value-of select="$object/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($object)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- this was from common.xsl -->

</xsl:stylesheet>
