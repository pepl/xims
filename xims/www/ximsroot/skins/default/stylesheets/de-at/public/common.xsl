<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../common.xsl"/>
<xsl:import href="default_header.xsl"/>
<xsl:import href="../../../../../stylesheets/config.xsl"/>
<xsl:import href="../../../../../stylesheets/anondiscussionforum_common.xsl"/>

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
    <meta name="DC.Publisher" content="Foo Inc."/>
    <meta name="DC.Contributor">
        <xsl:attribute name="content"><xsl:call-template name="modifierfullname"/></xsl:attribute>
    </meta>
    <meta name="DC.Date.Created" scheme="W3CDTF">
        <xsl:attribute name="content"><xsl:apply-templates select="creation_timestamp" mode="datetime"/></xsl:attribute>
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
          © 2000 - 2012 Example Org. - All rights reserved <br /><a href="http://www.foo.bar/">Help</a> | <a href="mailto:webmaster@doesnot.exist">Mail to the webmaster</a>
    </p>
</xsl:template>

<xsl:template match="/document/context/object/parents/object">
   <xsl:param name="no_navigation_at_all">false</xsl:param>
   <xsl:variable name="thispath"><xsl:value-of select="$parent_path_nosite"/></xsl:variable>

   <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
   </xsl:variable>

   <xsl:if test="/document/object_types/object_type[@id=$objecttype]/name!='AnonDiscussionForumContrib'">
   <xsl:choose>
        <xsl:when test="$no_navigation_at_all='true'">
            / <xsl:value-of select="location"/>
        </xsl:when>
        <xsl:otherwise>
            <!-- / <a class="nodeco" href="{$goxims_content}{$thispath}/{location}"><xsl:value-of select="location"/></a> -->
            / <a class="nodeco" href="http://xims.uibk.ac.at{$thispath}/{location}"><xsl:value-of select="location"/></a>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="path2topics">
    <!-- and /document/context/object/parents/object[@document_id != 1] -->
    <xsl:for-each select="/document/context/object/parents/object[object_type_id != /document/object_types/object_type[name='AnonDiscussionForumContrib']/@id]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
