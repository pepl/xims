<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="absolute_path"><xsl:call-template name="pathinfoinit"/></xsl:variable>
<xsl:variable name="parent_path"><xsl:call-template name="pathinfoparent" /></xsl:variable>

<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6|i|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|
        dl|dt|dd|li|ol|ul|
        a|
        img|map|area|
        caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|
        button|fieldset|form|label|legend|input|option|optgroup|select|textarea|
        applet|object|param">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
</xsl:template>

<xsl:template name="meta">
    <xsl:variable name="dataformat">
        <xsl:value-of select="/document/context/object/data_format"/>
    </xsl:variable>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
    <link rel="schema.DC" href="http://purl.org/DC/elements/1.0/"/>
    <meta name="DC.Title" content="{title}"/>
    <meta name="DC.Creator">
        <xsl:attribute name="content"><xsl:call-template name="ownerfullname"/></xsl:attribute>
    </meta>
    <meta name="DC.Subject" content="{keywords}"/>
    <meta name="DC.Description" content="{abstract}"/>
    <meta name="DC.Publisher" content="Universität Innsbruck"/>
    <meta name="DC.Contributor">
        <xsl:attribute name="content"><xsl:call-template name="modifierfullname"/></xsl:attribute>
    </meta>
    <meta name="DC.Date.Created" scheme="W3CDTF">
        <xsl:attribute name="content"><xsl:apply-templates select="creation_time" mode="datetime"/></xsl:attribute>
    </meta>
    <meta name="DC.Date.Modified" scheme="W3CDTF">
        <xsl:attribute name="content"><xsl:apply-templates select="last_modification_timestamp" mode="datetime"/></xsl:attribute>
    </meta>
    <meta name="DC.Format" content="{/document/data_formats/data_format[@id=$dataformat]/name}"/>
    <!-- still to come -->
    <meta name="DC.Language" content=""/>
</xsl:template>

<xsl:template name="modifierfullname">
    <xsl:value-of select="last_modified_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="last_modified_by_lastname"/>
</xsl:template>

<xsl:template name="ownerfullname">
    <xsl:value-of select="owned_by_firstname"/><xsl:text> </xsl:text><xsl:value-of select="owned_by_lastname"/>
</xsl:template>

<xsl:template name="pathinfo">
   <xsl:param name="string" select="$request.uri" />
   <xsl:param name="pattern" select="'/'" />
   <xsl:choose>
      <xsl:when test="contains($string, $pattern)">
         <xsl:if test="not(starts-with($string, $pattern))">
            <xsl:call-template name="pathinfo">
               <xsl:with-param name="string" select="substring-before($string, $pattern)" />
               <xsl:with-param name="pattern" select="$pattern" />
            </xsl:call-template>
         </xsl:if>
         <xsl:call-template name="pathinfo">
            <xsl:with-param name="string" select="substring-after($string, $pattern)" />
            <xsl:with-param name="pattern" select="$pattern" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="contains($request.uri, concat($string,'/'))">
                 / <a class="nodeco" href="{concat(substring-before($request.uri, concat($string,'/')),$string,'/')}"><xsl:value-of select="$string" /></a>
            </xsl:when>
            <xsl:otherwise>
                 / <a class="nodeco" href="{$request.uri}"><xsl:value-of select="$string" /></a>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="search">
     <form class="qsearch" action="http://www2.uibk.ac.at/suche/" method="POST" name="quicksearch">
        <table cellpadding="0" cellspacing="0" border="0" width="128" >
        <tr>
            <td>
                  <input class="qsfield" type="text" name="search" size="6" value="[Schnellsuche]" onfocus="document.quicksearch.search.value=&apos;&apos;"/>
            </td>
            <td>
                  <input class="qsbutton" type="image" name="submit" src="/images/icons/search_go.gif" border="0"/>
            </td>
        </tr>
        </table>
      </form>
</xsl:template>

<xsl:template name="stdlinks">
    <p class="stdlinks">
        <a href="http://xims.info/">The Xims Project</a><br />
        <a href="http://www.axkit.org/">Apache AxKit</a><br />
        <!--<a href="{$request.uri}?style=print">-->print view<!--</a>--><br />
        <!--><a href="{$request.uri}?style=textonly">-->text only<!--</a>--><br />
   </p>
</xsl:template>

<xsl:template name="deptlinks">
</xsl:template>

<xsl:template match="link">
    <a href="{@url}"><xsl:value-of select="text()"/></a><br/>
</xsl:template>

<xsl:template name="metafooter">
    <p class="metafooter">
        Document Owner: <xsl:call-template name="ownerfullname"/><br />
        Last modified on <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/> by <xsl:call-template name="modifierfullname"/>
    </p>
</xsl:template>

<xsl:template name="copyfooter">
    <p class="copy">
          © 2000 - 2012 Example Org. - All rights reserved <br /><a href="http://www.foo.bar/">Help</a> | <a href="mailto:webmaster@doesnot.exist">Mail the webmaster</a>
    </p>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_time|locked_time" mode="datetime">
    <xsl:value-of select="./day"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./month"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./year"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./hour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
</xsl:template>

<xsl:template name="pathinfoinit">
    <xsl:for-each select="/document/context/object/parents/object">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="pathinfoparent">
    <xsl:for-each select="/document/context/object/parents/object[position() != last()]">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="parentpath">
    <xsl:for-each select="preceding-sibling::object"><xsl:text>/</xsl:text><xsl:value-of select="location"/></xsl:for-each>
</xsl:template>

<xsl:template name="parentpath_nosite">
    <xsl:for-each select="preceding-sibling::object[@parent_id != 1]"><xsl:text>/</xsl:text><xsl:value-of select="location"/></xsl:for-each>
</xsl:template>

<xsl:template match="/document/context/object/parents/object">
   <xsl:param name="no_navigation_at_all">false</xsl:param>
   <xsl:variable name="thispath"><xsl:call-template name="parentpath_nosite"/></xsl:variable>

   <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
   </xsl:variable>

   <xsl:if test="$objecttype != 16">
   <xsl:choose>
        <xsl:when test="$no_navigation_at_all='true'">
                / <xsl:value-of select="location"/>
        </xsl:when>
        <xsl:otherwise>
            <!-- / <a class="nodeco" href="{$goxims_content}{$thispath}/{location}"><xsl:value-of select="location"/></a> -->
            / <a class="nodeco" href="http://www2.uibk.ac.at{$thispath}/{location}"><xsl:value-of select="location"/></a>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
