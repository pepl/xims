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
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document">
    <html>
        <head>
            <title>
                Passwort ändern - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">wahr</xsl:with-param>
        </xsl:call-template>

       <!-- begin main content -->
        <form name="userEdit" action="{$xims_box}{$goxims}/user" method="POST">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr background="{$skimages}generic_tablebg_1x20.png">
            <td>&#160;</td>
          </tr>
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table cellpadding="2" cellspacing="0" border="0">
            <tr>
              <td colspan="2">
                <xsl:call-template name="message"/>
              </td>
            </tr>
            <tr><td><br/></td></tr>
              <tr>
                <td align="center" class="bluebg" colspan="2">
                  Passwort für User '<xsl:value-of select="/document/context/session/user/name"/>' updaten
                </td>
              </tr>

              <tr>
                <td colspan="2"><span style="color:maroon">Markierte<img src="{$ximsroot}images/spacer_white.gif" alt="mit *"/></span> Felder sind obligatorisch!</td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Altes System Passwort:</span>
                </td>
                <td><input name="password" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Neues System Passwort:</span>
                </td>
                <td><input name="password1" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Passwort bestätigen:</span>
                </td>
                <td><input name="password2" type="password" value=""/></td>
              </tr>
              <tr>
                <td colspan="2" align="center">
                  &#160;
                </td>
              </tr>
              <tr>
                <td colspan="2" align="center">

                  <!-- begin buttons table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr align="center">
                      <td>
                        <input name="passwd_update" type="submit" value="Speichern" class="control"/>
                      </td>
                      <td>
                        <input name="cancel" type="submit" value="Abbrechen" class="control"/>
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

