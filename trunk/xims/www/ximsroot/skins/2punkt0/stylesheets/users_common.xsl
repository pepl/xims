<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_common.xsl 2246 2009-08-06 11:52:16Z haensel $
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

<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:variable name="order-by-opposite">
  <xsl:choose>
    <xsl:when test="$order-by='ascending'">descending</xsl:when>
    <xsl:otherwise>ascending</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="userlist">
    <table>
    <thead>
      <!-- begin app sort order by nav -->
      <tr>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='id'">
              <a href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by-opposite};userquery={$userquery}">ID</a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by};userquery={$userquery}">ID</a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='name'">
              <a href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n/l/Username"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Username"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='lastname'">
              <a href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Lastname"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Lastname"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='system_privs_mask'">
              <a href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/System_privileges"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/System_privileges"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='admin'">
              <a href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Administrator"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Administrator"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='enabled'">
              <a href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n/l/Account_status"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Account_status"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:value-of select="$i18n/l/Options"/>
        </th>
      </tr>
      </thead>
      <tbody>
						

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

</tbody>
    </table>
</xsl:template>

<xsl:template match="user">
  <tr>
   <!-- user/role bgcolor -->
   <xsl:if test="object_type='1'">
     <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
   </xsl:if>

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
            <div>
                <form name="userfilter">
                <p>
                    <a href="{$xims_box}{$goxims_users}?create=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
											<xsl:value-of select="$i18n_users/l/Create_account"/>
									</a>&#160;
									</p>
									<p>
									<xsl:value-of select="$i18n/l/or"/>&#160;
									</p>
									<p><xsl:value-of select="$i18n_users/l/update_existing_account"/>:
									<br/>
									<label for="input-account">Account </label>
                    <input name="userquery" type="text" id="input-account">
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="$userquery != ''"><xsl:value-of select="$userquery"/></xsl:when>
                                <xsl:otherwise>*</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </input>&#160;
                    <input type="submit" class="ui-state-default ui-corner-all fg-button" value="{$i18n/l/lookup}"/>
                    </p>
                </form>
            </div>
</xsl:template>

<xsl:template name="system_privileges">
<br/>
      <p><xsl:value-of select="$i18n_users/l/System_privileges"/>:</p>

<table id="table-syspriv">
		<tr>
			<th><xsl:value-of select="$i18n_users/l/User_self-management"/>:</th>
			<td>
<span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_PASSWORD" id="cb-acc-cp" class="checkbox">
                          <xsl:if test="system_privileges/change_password = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cp"><xsl:value-of select="$i18n_users/l/Change_Password"/></label>
                  </span>
<!--</td><td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_GRANT_ROLE" id="cb-acc-gr" class="checkbox">
                          <xsl:if test="system_privileges/grant_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-gr"><xsl:value-of select="$i18n_users/l/Grant_Role"/></label>
                  </span>			
			</td>
		</tr>

    <tr>
      <th>
          <xsl:value-of select="$i18n_users/l/Helpdesk_related"/>:
      </th>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_RESET_PASSWORD" id="cb-acc-rp" class="checkbox">
                          <xsl:if test="system_privileges/reset_password = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-rp"><xsl:value-of select="$i18n_users/l/Reset_Password"/></label>
                  </span>
<!--              </td>
              <td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_SET_STATUS" id="cb-acc-ss" class="checkbox">
                          <xsl:if test="system_privileges/set_status = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-ss"><xsl:value-of select="$i18n_users/l/Set_Status"/></label>
                  </span>
<!--              </td>
              <td>-->
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CREATE_ROLE" id="cb-acc-cr" class="checkbox">
                          <xsl:if test="system_privileges/create_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cr"><xsl:value-of select="$i18n_users/l/Create_Role"/></label>
                  </span>
<!--              </td>
              <td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_DELETE_ROLE" id="cb-acc-dr" class="checkbox">
                          <xsl:if test="system_privileges/delete_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-dr"><xsl:value-of select="$i18n_users/l/Delete_Role"/></label>
                  </span>
<!--              </td>
              <td>-->
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_ROLE_FULLNAME" id="cb-acc-crf" class="checkbox">
                          <xsl:if test="system_privileges/change_role_fullname = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-crf"><xsl:value-of select="$i18n_users/l/Change_Role_Fullname"/></label>
                  </span>
<!--              </td>
              <td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_USER_FULLNAME" id="cb-acc-cuf" class="checkbox">
                          <xsl:if test="system_privileges/change_user_fullname = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cuf"><xsl:value-of select="$i18n_users/l/Change_User_Fullname"/></label>
                  </span>
<!--              </td>
              <td>-->
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_ROLE_NAME" id="cb-acc-crn" class="checkbox">
                          <xsl:if test="system_privileges/change_role_name = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-crn"><xsl:value-of select="$i18n_users/l/Change_Rolename"/></label>
                  </span>
<!--              </td>
              <td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_USER_NAME" id="cb-acc-cun" class="checkbox">
                          <xsl:if test="system_privileges/change_user_name = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cun"><xsl:value-of select="$i18n_users/l/Change_Username"/></label>
                  </span>
<!--              </td>
              <td>-->
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CREATE_USER" id="cb-acc-cu" class="checkbox">
                          <xsl:if test="system_privileges/create_user = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cu"><xsl:value-of select="$i18n_users/l/Create_User"/></label>
                  </span>
<!--              </td>
              <td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_DELETE_USER" id="cb-acc-du" class="checkbox">
                          <xsl:if test="system_privileges/delete_user = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-du"><xsl:value-of select="$i18n_users/l/Delete_User"/></label>
                  </span>
<!--              </td>
            <td>-->
            <br/>
              <span class="cboxitem">
                <input type="checkbox" name="system_privs_CHANGE_DAV_OTPRIVS_MASK" id="cb-acc-cdo" class="checkbox">
                  <xsl:if test="system_privileges/change_dav_otprivs_mask = 1">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                </input>
                <label for="cb-acc-cdo"><xsl:value-of select="$i18n_users/l/Change_DAV_OTPrivs_Mask"/></label>
              </span>
            </td>
          </tr>
          
    <tr>
      <th>
          <xsl:value-of select="$i18n_users/l/System_management"/>:
      </th>
              <td>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_SYSPRIVS_MASK" id="cb-acc-csp" class="checkbox">
                          <xsl:if test="system_privileges/change_sysprivs_mask = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-csp"><xsl:value-of select="$i18n_users/l/Change_Sysprivs_Mask"/></label>
                  </span>
<!--              </td>
              <td>-->
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_SET_ADMIN_EQU" id="cb-acc-sae" class="checkbox">
                          <xsl:if test="system_privileges/set_admin_equ = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-sae"><xsl:value-of select="$i18n_users/l/Set_Admin_EQU"/></label>
                  </span>
              </td>
          </tr>
        </table>

</xsl:template>
 
<xsl:template name="usermeta">
<p>
<div class="input-label-acc"><label for="acc-lastname"><xsl:value-of select="$i18n_users/l/Lastname"/>*:</label></div><input size="30" maxlength="30" name="lastname" type="text" value="{lastname}" id="acc-lastname"/>
</p><p>
<div class="input-label-acc"><label for="acc-middlename"><xsl:value-of select="$i18n_users/l/Middlename"/>:</label></div><input size="30" maxlength="30" name="middlename" type="text" value="{middlename}" id="acc-middlename"/>
</p><p>
<div class="input-label-acc"><label for="acc-firstname"><xsl:value-of select="$i18n_users/l/Firstname"/>:</label></div><input size="30" maxlength="30" name="firstname" type="text" value="{firstname}" id="acc-firstname"/>
</p><p>
<div class="input-label-acc"><label for="acc-email"><xsl:value-of select="$i18n/l/Email"/>:</label></div><input size="30" maxlength="80" name="email" type="text" value="{email}" id="acc-email"/>
</p><p>
<div class="input-label-acc"><label for="acc-url">URL:</label></div><input size="30" maxlength="80" name="url" type="text" value="{url}" id="acc-url"/>
</p>
</xsl:template>

<xsl:template name="user_isadmin">
    <fieldset>
    <legend>
      <div class="input-label-acc"><xsl:value-of select="$i18n_users/l/User_is_Administrator"/>:</div></legend>
          <input name="admin" type="radio" value="true" class="radio-button" id="acc-isadmin-true">
            <xsl:if test="admin = '1'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <label for="acc-isadmin-true"><xsl:value-of select="$i18n/l/Yes"/></label>
          <input name="admin" type="radio" value="false" class="radio-button" id="acc-isadmin-false">
            <xsl:if test="admin != '1' or (not(admin) and $admin = 'false')">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
           <label for="acc-isadmin-false"><xsl:value-of select="$i18n/l/No"/></label>
    </fieldset>
</xsl:template>

<xsl:template name="account_enabled">
    <fieldset>
    <legend>
      <div class="input-label-acc"><xsl:value-of select="$i18n_users/l/Account_is_Enabled"/>:</div></legend>
          <input name="enabled" type="radio" value="true" class="radio-button" id="acc-isact-true">
            <xsl:if test="enabled = '1' or $enabled = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <label for="acc-isact-true"><xsl:value-of select="$i18n/l/Yes"/></label>
          <input name="enabled" type="radio" value="false" class="radio-button" id="acc-isact-false">
            <xsl:if test="enabled != '1'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <label for="acc-isact-false"><xsl:value-of select="$i18n/l/No"/></label>
    </fieldset>
</xsl:template>

<xsl:template name="exitform">
    <xsl:param name="action"/>
    <xsl:param name="save">Save</xsl:param>

                    <input name="{$action}" type="submit" class="ui-state-default ui-corner-all fg-button">
												<xsl:attribute name="value"><xsl:value-of select="$i18n/l/save"/></xsl:attribute> 
                    </input>
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
&#160;
                    <input class="ui-state-default ui-corner-all fg-button" name="c" type="submit" onclick="javascript:history.go(-1)">
											<xsl:attribute name="value"><xsl:value-of select="$i18n/l/cancel"/></xsl:attribute>                    
                    </input>

</xsl:template>

<xsl:template name="doneform">
    <input name="sort-by" type="hidden" value="{$sort-by}"/>
    <input name="order-by" type="hidden" value="{$order-by}"/>
    <input name="userquery" type="hidden" value="{$userquery}"/>
    <input class="control" name="c" type="submit" value="Done"/>
</xsl:template>

<xsl:template name="title-userpage">
<xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/> - XIMS
</xsl:template>


</xsl:stylesheet>

