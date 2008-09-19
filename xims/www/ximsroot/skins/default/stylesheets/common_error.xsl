<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2008 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/">
<html>
  <head>
      <title><xsl:value-of select="$i18n/l/Error"/>: <xsl:value-of select="/document/context/session/error_msg"/></title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
  </head>
  <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
    <xsl:call-template name="header">
        <xsl:with-param name="noncontent">true</xsl:with-param>
    </xsl:call-template>
    <p class="error_msg">
        <strong><xsl:value-of select="$i18n/l/Error"/>:</strong><br/>
        <xsl:value-of select="/document/context/session/error_msg"/>
    </p>
      <xsl:if test="/document/context/session/verbose_msg != ''">
        <div class="error_details">
            <p><strong><xsl:value-of select="$i18n/l/Error_details"/>:</strong></p>
            <pre>
                <xsl:value-of select="/document/context/session/verbose_msg" />
            </pre>
        </div>
      </xsl:if>
    <p>
        <a href="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/Back"/></a>
    </p>
  </body>
</html>
</xsl:template>
</xsl:stylesheet>
