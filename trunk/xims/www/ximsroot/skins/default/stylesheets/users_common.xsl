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

<xsl:param name="name"/>
<xsl:param name="sort-by">id</xsl:param>
<xsl:param name="order-by">ascending</xsl:param>
<xsl:param name="userquery"/>

<xsl:param name="lastname"/>
<xsl:param name="admin">false</xsl:param>
<xsl:param name="enabled">true</xsl:param>
<xsl:param name="object_type">user</xsl:param>

<xsl:variable name="i18n_users" select="document(concat($currentuilanguage,'/i18n_users.xml'))"/>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <xsl:call-template name="script_head"/>
    </head>
</xsl:template>

<xsl:variable name="order-by-opposite">
  <xsl:choose>
    <xsl:when test="$order-by='ascending'">descending</xsl:when>
    <xsl:otherwise>ascending</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="userlist">
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
      <!-- begin app sort order by nav -->
      <tr style="background:url('{$skimages}generic_tablebg_1x20.png');">
        <td width="20">&#160;</td>
        <td>
          <xsl:choose>
            <xsl:when test="$sort-by='id'">
              <a href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by-opposite};userquery={$userquery}">ID</a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by};userquery={$userquery}">ID</a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$sort-by='name'">
              <a href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n/l/Username"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Username"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$sort-by='lastname'">
              <a href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Lastname"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Lastname"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$sort-by='system_privs_mask'">
              <a href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/System_privileges"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/System_privileges"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$sort-by='admin'">
              <a href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Administrator"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Administrator"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$sort-by='enabled'">
              <a href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n/l/Account_status"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Account_status"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td width="500">
          <xsl:value-of select="$i18n/l/Options"/>
        </td>
      </tr>

      <!-- this *truly* bites -->
      <xsl:choose>
        <xsl:when test="$sort-by='id'">
          <xsl:choose>
            <xsl:when test="$order-by='ascending'">
              <xsl:for-each select="user">
                <xsl:sort select="@id"
                          order="ascending"
                          data-type="number"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="user">
                <xsl:sort select="@id"
                          order="descending"
                          data-type="number"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$sort-by='name'">
          <xsl:choose>
            <xsl:when test="$order-by='ascending'">
              <xsl:for-each select="user">
                <xsl:sort select="name"
                          order="ascending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="user">
                <xsl:sort select="name"
                          order="descending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$sort-by='lastname'">
          <xsl:choose>
            <xsl:when test="$order-by='ascending'">
              <xsl:for-each select="user">
                <xsl:sort select="lastname"
                          order="ascending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="user">
                <xsl:sort select="lastname"
                          order="descending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$sort-by='system_privs_mask'">
          <xsl:choose>
            <xsl:when test="$order-by='ascending'">
              <xsl:for-each select="user">
                <xsl:sort select="system_privs_mask"
                          order="ascending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="user">
                <xsl:sort select="system_privs_mask"
                          order="descending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$sort-by='admin'">
          <xsl:choose>
            <xsl:when test="$order-by='ascending'">
              <xsl:for-each select="user">
                <xsl:sort select="admin"
                          order="ascending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="user">
                <xsl:sort select="admin"
                          order="descending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$sort-by='enabled'">
          <xsl:choose>
            <xsl:when test="$order-by='ascending'">
              <xsl:for-each select="user">
                <xsl:sort select="enabled"
                          order="ascending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="user">
                <xsl:sort select="enabled"
                          order="descending"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
      <!-- end sort madness -->

    </table>
</xsl:template>

<xsl:template match="user">
  <tr class="objrow">
   <!-- user/role bgcolor -->
   <xsl:if test="object_type='1'">
     <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
   </xsl:if>

   <td>&#160;</td>
   <td><xsl:value-of select="@id"/></td>
   <!-- sometimes turning tree-shaped data into tabular is yucky -->
   <xsl:apply-templates select="name"/>
   <xsl:apply-templates select="lastname"/>
   <xsl:apply-templates select="system_privs_mask"/>
   <xsl:apply-templates select="admin"/>
   <xsl:apply-templates select="enabled"/>

   <xsl:call-template name="options"/>

  </tr>
</xsl:template>

<xsl:template match="lastname|name|system_privs_mask">
   <td><xsl:value-of select="."/></td>
</xsl:template>

<xsl:template match="admin">
  <td>
   <xsl:choose>
     <xsl:when test="text()='1'">
       <xsl:value-of select="$i18n/l/Yes"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$i18n/l/No"/>
     </xsl:otherwise>
   </xsl:choose>
  </td>
</xsl:template>

<xsl:template match="enabled">
  <td>
   <xsl:choose>
     <xsl:when test="text()='1'">
       <xsl:value-of select="$i18n_users/l/Enabled"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$i18n_users/l/Disabled"/>
     </xsl:otherwise>
   </xsl:choose>
  </td>
</xsl:template>

<xsl:template name="create_manage_accounts">
    <tr bgcolor="#eeeeee">
        <td align="center">
            <div>
                <form name="userfilter" style="margin: 0" action="">
                    <a href="{$xims_box}{$goxims_users}?create=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Create_account"/></a>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;<xsl:value-of select="$i18n_users/l/update_existing_account"/>:
                    <input name="userquery" type="text">
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="$userquery != ''"><xsl:value-of select="$userquery"/></xsl:when>
                                <xsl:otherwise>*</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </input>
                    <input type="submit"
                     class="control"
                     value="{$i18n/l/lookup}"/>
                </form>
            </div>
        </td>
    </tr>
</xsl:template>

<xsl:template name="system_privileges">
    <tr>
      <td><xsl:value-of select="$i18n_users/l/System_privileges"/>:</td>
    </tr>
    <tr>
      <td>
          <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
          <xsl:value-of select="$i18n_users/l/User_self-management"/>:
      </td>
      <td>
        <!-- begin user self management sys privs table -->
        <table cellpadding="2" cellspacing="0" border="0">
          <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_PASSWORD">
                          <xsl:if test="system_privileges/change_password = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Change_Password"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_GRANT_ROLE">
                          <xsl:if test="system_privileges/grant_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Grant_Role"/>
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
          <xsl:value-of select="$i18n_users/l/Helpdesk_related"/>:
      </td>
      <td>
        <!-- begin helpdesk management sys privs table -->
        <table cellpadding="2" cellspacing="0" border="0">
          <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_RESET_PASSWORD">
                          <xsl:if test="system_privileges/reset_password = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Reset_Password"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_SET_STATUS">
                          <xsl:if test="system_privileges/set_status = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Set_Status"/>
                  </span>
              </td>
            </tr>
            <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CREATE_ROLE">
                          <xsl:if test="system_privileges/create_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Create_Role"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_DELETE_ROLE">
                          <xsl:if test="system_privileges/delete_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Delete_Role"/>
                  </span>
              </td>
            </tr>
            <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_ROLE_FULLNAME">
                          <xsl:if test="system_privileges/change_role_fullname = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Change_Role_Fullname"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_USER_FULLNAME">
                          <xsl:if test="system_privileges/change_user_fullname = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Change_User_Fullname"/>
                  </span>
              </td>
            </tr>
            <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_ROLE_NAME">
                          <xsl:if test="system_privileges/change_role_name = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Change_Rolename"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_USER_NAME">
                          <xsl:if test="system_privileges/change_user_name = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Change_Username"/>
                  </span>
              </td>
            </tr>
            <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CREATE_USER">
                          <xsl:if test="system_privileges/create_user = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Create_User"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_DELETE_USER">
                          <xsl:if test="system_privileges/delete_user = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Delete_User"/>
                  </span>
              </td>
            </tr>
          <tr>
            <td colspan="2">
              <span class="cboxitem">
                <input type="checkbox" name="system_privs_CHANGE_DAV_OTPRIVS_MASK">
                  <xsl:if test="system_privileges/change_dav_otprivs_mask = 1">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                </input>
                <xsl:value-of select="$i18n_users/l/Change_DAV_OTPrivs_Mask"/>
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
          <xsl:value-of select="$i18n_users/l/System_management"/>:
      </td>
      <td>
        <!-- begin system management sys privs table -->
        <table cellpadding="2" cellspacing="0" border="0">
          <tr>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_SYSPRIVS_MASK">
                          <xsl:if test="system_privileges/change_sysprivs_mask = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Change_Sysprivs_Mask"/>
                  </span>
              </td>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_SET_ADMIN_EQU">
                          <xsl:if test="system_privileges/set_admin_equ = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <xsl:value-of select="$i18n_users/l/Set_Admin_EQU"/>
                  </span>
              </td>
          </tr>
        </table>
        <!-- end system management sys privs table -->
      </td>
    </tr>
</xsl:template>
 

<xsl:template name="usermeta">
    <tr>
        <td>
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory">
                <xsl:value-of select="$i18n_users/l/Lastname"/>:
            </span>
        </td>
        <td>
            <input size="30" maxlength="30" name="lastname" type="text" value="{lastname}"/>
        </td>
    </tr>
    <tr>
      <td><xsl:value-of select="$i18n_users/l/Middlename"/>:</td>
      <td><input size="30" maxlength="30" name="middlename" type="text" value="{middlename}"/></td>
    </tr>
    <tr>
      <td><xsl:value-of select="$i18n_users/l/Firstname"/>:</td>
      <td><input size="30" maxlength="30" name="firstname" type="text" value="{firstname}"/></td>
    </tr>
    <tr>
      <td><xsl:value-of select="$i18n/l/Email"/>:</td>
      <td><input size="30" maxlength="80" name="email" type="text" value="{email}"/></td>
    </tr>
    <tr>
      <td>URL:</td>
      <td><input size="30" maxlength="80" name="url" type="text" value="{url}"/></td>
    </tr>
</xsl:template>

<xsl:template name="profile_type">
    <tr>
      <td><xsl:value-of select="$i18n/l/Profile_type"/>:</td>
      <td>
		<input type="radio" id="profiletype_std" class="radio-button" name="profile_type" value="standard">
		<xsl:if test="profile_type = 'standard'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
		</input> <label for="profiletype_std"><xsl:value-of select="$i18n/l/Standard"/></label> 
		<input type="radio" id="profiletype_prof" class="radio-button" name="profile_type" value="professional">
		<xsl:if test="profile_type = 'professional'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
		</input> <label for="profiletype_std"><xsl:value-of select="$i18n/l/Professional"/></label> 
		<input type="radio" id="profiletype_exp" class="radio-button" name="profile_type" value="expert">
		<xsl:if test="profile_type = 'expert'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
		</input> <label for="profiletype_std"><xsl:value-of select="$i18n/l/Expert"/></label> 
      </td>
    </tr>
</xsl:template>

<xsl:template name="user_isadmin">
    <tr>
      <td><xsl:value-of select="$i18n_users/l/User_is_Administrator"/>:</td>
      <td>
          <input name="admin" type="radio" value="true">
            <xsl:if test="admin = '1'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input><xsl:value-of select="$i18n/l/Yes"/>
          <input name="admin" type="radio" value="false">
            <xsl:if test="admin != '1' or (not(admin) and $admin = 'false')">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input><xsl:value-of select="$i18n/l/No"/>
      </td>
    </tr>
</xsl:template>

<xsl:template name="account_enabled">
    <tr>
      <td><xsl:value-of select="$i18n_users/l/Account_is_Enabled"/>:</td>
      <td>
          <input name="enabled" type="radio" value="true">
            <xsl:if test="enabled = '1' or $enabled = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input><xsl:value-of select="$i18n/l/Yes"/>
          <input name="enabled" type="radio" value="false">
            <xsl:if test="enabled != '1'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input><xsl:value-of select="$i18n/l/No"/>
      </td>
    </tr>
</xsl:template>

<xsl:template name="exitform">
    <xsl:param name="action"/>
    <xsl:param name="save">Save</xsl:param>
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
                    <input name="{$action}" type="submit" value="{$save}" class="control"/>
                    <xsl:choose>
                        <xsl:when test="@id != ''">
                            <input name="id" type="hidden" value="{@id}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$name != ''">
                                <input name="name" type="hidden" value="{$name}"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <input name="sort-by" type="hidden" value="{$sort-by}"/>
                    <input name="order-by" type="hidden" value="{$order-by}"/>
                    <input name="userquery" type="hidden" value="{$userquery}"/>
                </td>
                <td>
                    <input class="control" name="c" type="submit" value="Cancel" onclick="javascript:history.go(-1)"/>
                </td>
            </tr>
        </table>
        <!-- end buttons table -->

        </td>
    </tr>
</xsl:template>

<xsl:template name="doneform">
    <input name="sort-by" type="hidden" value="{$sort-by}"/>
    <input name="order-by" type="hidden" value="{$order-by}"/>
    <input name="userquery" type="hidden" value="{$userquery}"/>
    <input class="control" name="c" type="submit" value="Done"/>
</xsl:template>

</xsl:stylesheet>

