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
<xsl:import href="common.xsl"/>
<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
<xsl:param name="name"/>
<xsl:param name="lastname"/>
<xsl:param name="middlename"/>
<xsl:param name="firstname"/>
<xsl:param name="email"/>
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
            <style type="text/css">span.cboxitem { width:180px;}</style>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
        <form name="userAdd" action="{$xims_box}{$goxims_users}" method="POST">
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
                <td><input size="30" maxlength="30" name="name" type="text" value="{$name}"/></td>
              </tr>
              <tr>
                <td>
                    <span>Password:</span>
                </td>
                <td><input size="30" maxlength="32" name="password1" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <span>Confirm Password:</span>
                </td>
                <td><input size="30" maxlength="32" name="password2" type="password" value=""/></td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    <span class="compulsory">Last Name:</span>
                </td>
                <td><input size="30" maxlength="30" name="lastname" type="text" value="{$lastname}"/></td>
              </tr>
              <tr>
                <td>
                    Middle Name:
                </td>
                <td><input size="30" maxlength="30" name="middlename" type="text" value="{$middlename}"/></td>
              </tr>
              <tr>
                <td>
                    First Name:
                </td>
                <td><input size="30" maxlength="30" name="firstname" type="text" value="{$firstname}"/></td>
              </tr>
              <tr>
                <td>
                    e-Mail:
                </td>
                <td><input size="30" maxlength="80" name="email" type="text" value="{$email}"/></td>
              </tr>
              <tr>
                <td>
                    Privileges Mask:
                </td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    User self-management:
                </td>
                <td>
                  <!-- begin user self management sys privs table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CHANGE_PASSWORD">
                                    <xsl:if test="( floor(system_privs_mask div 1) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Change Password
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_GRANT_ROLE">
                                    <xsl:if test="( floor(system_privs_mask div 2) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Grant Role
                            </span>
                        </td>
                    </tr>
                  </table>
                  <!-- end user self management sys privs table -->
                </td>
              </tr>
              <tr>
                <td valign="top">
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    Helpdesk related:
                </td>
                <td>
                  <!-- begin helpdesk management sys privs table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_RESET_PASSWORD">
                                    <xsl:if test="( floor(system_privs_mask div 4096) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Reset Password
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_SET_STATUS">
                                    <xsl:if test="( floor(system_privs_mask div 8192) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Set Status
                            </span>
                        </td>
                      </tr>
                      <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CREATE_ROLE">
                                    <xsl:if test="( floor(system_privs_mask div 16384) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Create Role
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_DELETE_ROLE">
                                    <xsl:if test="( floor(system_privs_mask div 32768) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Delete Role
                            </span>
                        </td>
                      </tr>
                      <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CHANGE_ROLE_FULLNAME">
                                    <xsl:if test="( floor(system_privs_mask div 65536) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Change Role Fullname
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CHANGE_USER_FULLNAME">
                                    <xsl:if test="( floor(system_privs_mask div 131072) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Change User Fullname
                            </span>
                        </td>
                      </tr>
                      <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CHANGE_ROLE_NAME">
                                    <xsl:if test="( floor(system_privs_mask div 262144) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Change Role Name
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CHANGE_USER_NAME">
                                    <xsl:if test="( floor(system_privs_mask div 524288) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Change User Name
                            </span>
                        </td>
                      </tr>
                      <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CREATE_USER">
                                    <xsl:if test="( floor(system_privs_mask div 1048576) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Create User
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_DELETE_USER">
                                    <xsl:if test="( floor(system_privs_mask div 2097152) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Delete User
                            </span>
                        </td>
                      </tr>
                    </table>
                    <!-- end helpdesk management sys privs table -->
                </td>
              </tr>
              <tr>
                <td>
                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                    System management:
                </td>
                <td>
                  <!-- begin system management sys privs table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_CHANGE_SYSPRIVS_MASK">
                                    <xsl:if test="( floor(system_privs_mask div 268435456) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Change Sysprivs Mask
                            </span>
                        </td>
                        <td>
                           <span class="cboxitem">
                                <input type="checkbox" name="system_privs_SET_ADMIN_EQU">
                                    <xsl:if test="( floor(system_privs_mask div 536870912) mod 2) &gt; 0">
                                      <xsl:attribute name="checked" select="checked"/>
                                    </xsl:if>
                                </input>
                                Set Admin EQU
                            </span>
                        </td>
                    </tr>
                  </table>
                  <!-- end system management sys privs table -->
                </td>
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

