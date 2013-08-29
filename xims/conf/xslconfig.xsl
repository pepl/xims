<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: config.xsl 2793 2011-12-27 10:55:50Z susannetober $

This stylesheet is used to generate www/ximsroot/stylesheets/config.xsl from conf/ximsconfig.xml. 

-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xslt="xsl-output"
                xmlns="http://www.w3.org/1999/xhtml">


  <xsl:output indent="yes"/>

  <xsl:param name="XIMS_HOME">/usr/local/xims</xsl:param>

  <xsl:namespace-alias stylesheet-prefix="xslt"
                       result-prefix="xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Config/General"/>
  </xsl:template>

  <xsl:template match="Config/General">
    <xslt:stylesheet version="1.0">

      <xsl:comment>This file will be regenerated from conf/ximsconfig.xml on
      every server startup. Transformation rules are in
      conf/xslconfig.xsl.</xsl:comment>
      <xslt:variable name="xims_home" select="'{$XIMS_HOME}'"/>

      <xslt:variable name="editoroptions">
        <xsl:apply-templates select="XHTMLEditorOptions/*" mode="copy"/>
      </xslt:variable>
      <xslt:variable name="codeeditoroptions">
        <xsl:apply-templates select="CodeEditorOptions/*" mode="copy"/>
      </xslt:variable>

      <xslt:variable name="big_image_threshold" select="{BigImageLimit}"/> <!-- 70KiB -->
      <xslt:variable name="searchresultrowlimit" select="{SearchResultRowLimit}"/>
      
      <xslt:variable name="goxims"><xsl:value-of select="concat('/',goxims)"/></xslt:variable>
      <xslt:variable name="contentinterface"><xsl:value-of select="concat('/',ContentInterface)"/></xslt:variable>
      <xslt:variable name="personalinterface"><xsl:value-of select="concat('/',PersonalInterface)"/></xslt:variable>
      <xslt:variable name="usermanagementinterface"><xsl:value-of select="concat('/',UserManagementInterface)"/></xslt:variable>
      <xslt:variable name="goxims_content">
        <xslt:choose>
          <xslt:when test="/document/context/session/public_user = '1'"><xsl:value-of select="concat('/',gopublic,'/',ContentInterface)"/></xslt:when>
          <xslt:otherwise><xsl:value-of select="concat('/',goxims,'/',ContentInterface)"/></xslt:otherwise>
        </xslt:choose>
      </xslt:variable>
      <xslt:variable name="gopublic_content"><xsl:value-of select="concat('/',gopublic,'/',ContentInterface)"/></xslt:variable>
      <xslt:variable name="goxims_users"><xsl:value-of select="concat('/',goxims,'/users')"/></xslt:variable>
      <xslt:variable name="xims_box"><xslt:value-of select="/document/context/session/serverurl"/></xslt:variable>
      <xslt:variable name="ximsroot"><xslt:value-of select="$xims_box"/><xsl:value-of select="concat('/',XIMSRoot,'/')"/></xslt:variable>
      <xslt:variable name="currentskin"><xslt:value-of select="/document/context/session/skin"/></xslt:variable>
      <xslt:variable name="defaultcss"><xsl:value-of select="DefaultCSS"/></xslt:variable>
      <xslt:variable name="resolvereltositeroots"><xsl:value-of select="ResolveRelToSiteRoots"/></xslt:variable>
      <xslt:variable name="supportmailaddress"><xsl:value-of select="SupportMailAddress"/></xslt:variable>
      <xslt:variable name="js-config">{ goxims:'<xsl:value-of select="concat('/',goxims)"/>',
  gobaxims:'<xsl:value-of select="concat('/',gobaxims)"/>',
  gopublic:'<xsl:value-of select="concat('/',gopublic)"/>',
  godav:'<xsl:value-of select="concat('/',godav)"/>',
  contentinterface:'<xsl:value-of select="concat('/',ContentInterface)"/>',
  personalinterface:'<xsl:value-of select="concat('/',PersonalInterface)"/>',
  usermanagementinterface:'<xsl:value-of select="concat('/',UserManagementInterface)"/>',
  ximsroot:'<xslt:value-of select="$xims_box"/><xsl:value-of select="concat('/',XIMSRoot,'/')"/>' }</xslt:variable>
    </xslt:stylesheet>
  </xsl:template>


  <xsl:template match="*" mode="copy">
    <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="copy"/>
    </xsl:element>
  </xsl:template>
 
</xsl:stylesheet>
