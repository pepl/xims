<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>
<xsl:param name="id"/>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                <xsl:value-of select="title" /> - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <form name="recurseRemove" action="{$xims_box}{$goxims_content}{$absolute_path}" method="post" style="margin-top: 0px; margin-left: 5px;">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table width="300" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg">Warning - Child Objects Found!</td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td>
                    <p>
                        <xsl:value-of select="/document/context/session/warning_msg"/>
                        that will also be removed.
                    </p>
                    <p>
                        Click 'Confirm' to continue, or 'Cancel' to return to abort this action.
                    </p>
                </td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td align="center">

                  <!-- begin buttons table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr align="center">
                      <td>
                        <input name="submit" type="submit" value="Confirm" class="control"/>
                        <input name="id" type="hidden" value="{$id}"/>
                        <input type="hidden" name="forcetrash" value="1"/>
                        <input type="hidden" name="trashcan" value="1"/>
                        <xsl:call-template name="rbacknav"/>
                      </td>
                      <td>
                        <input name="default" type="button" value="Cancel" onclick="javascript:history.go(-2)"  class="control"/>
                      </td>
                    </tr>
                  </table>
                  <!-- end buttons table -->

                </td>
              </tr>
            </table>
            <!-- end widget table -->
        <br />

            </td>
          </tr>
        </table>
        </form>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

