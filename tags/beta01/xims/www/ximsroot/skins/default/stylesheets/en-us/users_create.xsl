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
<xsl:param name="name"/>
<xsl:param name="lastname"/>
<xsl:param name="middlename"/>
<xsl:param name="firstname"/>
<xsl:param name="system_privs_mask"/>
<xsl:param name="admin">false</xsl:param>
<xsl:param name="enabled">true</xsl:param>
<xsl:param name="object_type">user</xsl:param>

<xsl:template match="/document">
    <html>
        <head>
            <title>
                Creating New System User - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
        <form name="userAdd" action="{$xims_box}{$goxims_users}" method="POST">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">
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
                <td align="center" class="bluebg" colspan="2">Creating User</td>
              </tr>
              <tr>
                <td colspan="2">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt=" with *"/></span> are mandatory!</td>
              </tr>

              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Username:</span>
                </td>
                <td><input name="name" type="text" value="{$name}"/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Password:</span>
                </td>
                <td><input name="password1" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Confirm Password:</span>
                </td>
                <td><input name="password2" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Last Name:</span>
                </td>
                <td><input name="lastname" type="text" value="{$lastname}"/></td>
              </tr>
              <tr>
                <td>
                    Middle Name:
                </td>
                <td><input name="middlename" type="text" value="{$middlename}"/></td>
              </tr>
              <tr>
                <td>
                    First Name:
                </td>
                <td><input name="firstname" type="text" value="{$firstname}"/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Privileges Mask:</span>
                </td>
                <td><input name="system_privs_mask" type="text" value="{$system_privs_mask}"/></td>
              </tr>
              <tr>
                <td>Account is an Abstract Role:</td>
                <td>
                    <input name="object_type" type="radio" value="role">
                      <xsl:if test="$object_type = 'role'">
                        <xsl:attribute name="checked" select="checked"/>
                      </xsl:if>
                    </input>Yes
                    <input name="object_type" type="radio" value="user">
                      <xsl:if test="$object_type != 'role'">
                        <xsl:attribute name="checked" select="checked"/>
                      </xsl:if>
                    </input>No
                </td>
              </tr>
              <tr>
                <td>User is Administrator:</td>
                <td>
                    <input name="admin" type="radio" value="true">
                      <xsl:if test="$admin = 'true'">
                        <xsl:attribute name="checked" select="checked"/>
                      </xsl:if>
                    </input>Yes
                    <input name="admin" type="radio" value="false">
                      <xsl:if test="$admin != 'true'">
                        <xsl:attribute name="checked" select="checked"/>
                      </xsl:if>
                    </input>No
                </td>
              </tr>
              <tr>
                <td>Account is Enabled:</td>
                <td>
                    <input name="enabled" type="radio" value="true">
                      <xsl:if test="$enabled = 'true'">
                        <xsl:attribute name="checked" select="checked"/>
                      </xsl:if>
                    </input>Yes
                    <input name="enabled" type="radio" value="false">
                      <xsl:if test="$enabled != 'true'">
                        <xsl:attribute name="checked" select="checked"/>
                      </xsl:if>
                    </input>No
                </td>
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
                        <input class="control" name="create_update" type="submit" value="Save"/>
                      </td>
                      <td>
                        <input class="control" name="cancel" type="submit" value="Cancel"/>
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

