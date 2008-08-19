<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

    <xsl:import href="common.xsl"/>
  <xsl:import href="container_common.xsl"/>
    
  <xsl:output method="xml"
              omit-xml-declaration="yes"
              encoding="iso-8859-1"
              media-type="text/html"
              indent="no"/>

  <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
  </xsl:template>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title><xsl:value-of select="$title"/> - Portal - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
      </head>
      <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="createwidget">true</xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="childrentable"/>
        
        <table align="center" width="98.7%" class="footer">
          <xsl:call-template name="footer"/>
        </table>
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>