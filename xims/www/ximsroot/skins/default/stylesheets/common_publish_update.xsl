<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<!-- $Id$ -->

<xsl:variable name="object_type_id">
    <xsl:value-of select="/document/context/object/object_type_id"/>
</xsl:variable>
<xsl:variable name="parent_id">
    <xsl:value-of select="/document/context/object/@parent_id"/>
</xsl:variable>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Publishing_success"/> - <xsl:value-of select="title" /> - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table width="200" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg"><xsl:value-of select="$i18n/l/Publishing_success"/></td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                  <td><xsl:call-template name="message"/></td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td align="center">
                       <xsl:call-template name="exitredirectform"/>
                </td>
              </tr>
            </table>
            <!-- end widget table -->
            <br />

            </td>
          </tr>
        </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

