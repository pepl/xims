<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_passwd.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>
<xsl:output method="xml" 
            encoding="utf-8"
            media-type="text/html" 
            doctype-system="about:legacy-compat" 
            omit-xml-declaration="yes"
            indent="no"/>

<xsl:template match="/document">
    <html>
        <head>
            <title>
                Changing Password - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

       <!-- begin main content -->
        <form name="userEdit" action="{$xims_box}{$goxims}/user" method="post">
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
                  Updating password for user '<xsl:value-of select="/document/context/session/user/name"/>'
                </td>
              </tr>

              <tr>
                <td colspan="2">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt=" with *"/></span> are mandatory!</td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Old system password:</span>
                </td>
                <td><input name="password" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">New system password:</span>
                </td>
                <td><input name="password1" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Confirm new password:</span>
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
                        <input name="passwd_update" type="submit" value="Save" class="control"/>
                      </td>
                      <td>
                        <input name="cancel" type="submit" value="Cancel" class="control"/>
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
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

