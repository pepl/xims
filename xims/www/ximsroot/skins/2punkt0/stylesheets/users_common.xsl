<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
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
<!--
<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
-->
<xsl:variable name="order-by-opposite">
  <xsl:choose>
    <xsl:when test="$order-by='ascending'">descending</xsl:when>
    <xsl:otherwise>ascending</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="userlist">
	<table class="obj-table acl-table">
		<thead>
		<!-- begin app sort order by nav -->
		<tr>
		<th>
			<xsl:choose>
				<xsl:when test="$sort-by='id'">
					<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by-opposite};userquery={$userquery}">ID
						<xsl:choose>
						<xsl:when test="$order-by = 'ascending'"><span class="ui-icon ui-icon-triangle-1-n"/></xsl:when>
						<xsl:otherwise><span class="ui-icon ui-icon-triangle-1-s"/></xsl:otherwise>
						</xsl:choose>
					</a>
            </xsl:when>
            <xsl:otherwise>
              <a  class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by};userquery={$userquery}">ID
			  <span class="ui-icon ui-icon-triangle-2-n-s"/>
			  </a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='name'">
              <a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n/l/Username"/>
				<xsl:choose>
						<xsl:when test="$order-by = 'ascending'"><span class="ui-icon ui-icon-triangle-1-n"/></xsl:when>
						<xsl:otherwise><span class="ui-icon ui-icon-triangle-1-s"/></xsl:otherwise>
				</xsl:choose>
			  </a>
			</xsl:when>
			<xsl:otherwise>
				<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Username"/>
					<span class="ui-icon ui-icon-triangle-2-n-s"/>
				</a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='lastname'">
              <a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Lastname"/>
				<xsl:choose>
					<xsl:when test="$order-by = 'ascending'"><span class="ui-icon ui-icon-triangle-1-n"/></xsl:when>
					<xsl:otherwise><span class="ui-icon ui-icon-triangle-1-s"/></xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:when>
			<xsl:otherwise>
			<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Lastname"/>
				<span class="ui-icon ui-icon-triangle-2-n-s"/>
			</a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='system_privs_mask'">
				<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/System_privileges"/>
				<xsl:choose>
					<xsl:when test="$order-by = 'ascending'"><span class="ui-icon ui-icon-triangle-1-n"/></xsl:when>
					<xsl:otherwise><span class="ui-icon ui-icon-triangle-1-s"/></xsl:otherwise>
				</xsl:choose>
				</a>
            </xsl:when>
            <xsl:otherwise>
				<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/System_privileges"/>
					<span class="ui-icon ui-icon-triangle-2-n-s"/>
				</a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='admin'">
				<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Administrator"/>
				<xsl:choose>
					<xsl:when test="$order-by = 'ascending'"><span class="ui-icon ui-icon-triangle-1-n"/></xsl:when>
					<xsl:otherwise><span class="ui-icon ui-icon-triangle-1-s"/></xsl:otherwise>
				</xsl:choose>
				</a>
            </xsl:when>
            <xsl:otherwise>
				<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n_users/l/Administrator"/>
					<span class="ui-icon ui-icon-triangle-2-n-s"/>
				</a>
            </xsl:otherwise>
          </xsl:choose>
        </th>
        <th>
          <xsl:choose>
            <xsl:when test="$sort-by='enabled'">
				<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by-opposite};userquery={$userquery}"><xsl:value-of select="$i18n/l/Account_status"/>
				<xsl:choose>
					<xsl:when test="$order-by = 'ascending'"><span class="ui-icon ui-icon-triangle-1-n"/></xsl:when>
					<xsl:otherwise><span class="ui-icon ui-icon-triangle-1-s"/></xsl:otherwise>
				</xsl:choose>
				</a>
            </xsl:when>
	            <xsl:otherwise>
					<a class="th-icon-right" href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/Account_status"/>
						<span class="ui-icon ui-icon-triangle-2-n-s"/>
					</a>
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
  <tr class="objrow">
   <!-- user/role bgcolor -->
   <!--<xsl:if test="object_type='1'">
     <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
   </xsl:if>-->

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
                <form name="userfilter" action="">
                <p>
                    <a class="button" href="{$xims_box}{$goxims_users}?create=1;sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
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
                    <button type="submit" class="button"><xsl:value-of select="$i18n/l/lookup"/></button>
                    </p>
                </form>
            </div>
</xsl:template>

<xsl:template name="system_privileges">
      <p><xsl:value-of select="$i18n_users/l/System_privileges"/>:</p>

<table id="table-syspriv">
		<tr>
			<th width="180"><xsl:value-of select="$i18n_users/l/User_self-management"/>:</th>
			<td>
<span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_PASSWORD" id="cb-acc-cp" class="checkbox">
                          <xsl:if test="system_privileges/change_password = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cp"><xsl:value-of select="$i18n_users/l/Change_Password"/></label>
                  </span>
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
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_SET_STATUS" id="cb-acc-ss" class="checkbox">
                          <xsl:if test="system_privileges/set_status = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-ss"><xsl:value-of select="$i18n_users/l/Set_Status"/></label>
                  </span>
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CREATE_ROLE" id="cb-acc-cr" class="checkbox">
                          <xsl:if test="system_privileges/create_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cr"><xsl:value-of select="$i18n_users/l/Create_Role"/></label>
                  </span>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_DELETE_ROLE" id="cb-acc-dr" class="checkbox">
                          <xsl:if test="system_privileges/delete_role = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-dr"><xsl:value-of select="$i18n_users/l/Delete_Role"/></label>
                  </span>
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_ROLE_FULLNAME" id="cb-acc-crf" class="checkbox">
                          <xsl:if test="system_privileges/change_role_fullname = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-crf"><xsl:value-of select="$i18n_users/l/Change_Role_Fullname"/></label>
                  </span>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_USER_FULLNAME" id="cb-acc-cuf" class="checkbox">
                          <xsl:if test="system_privileges/change_user_fullname = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cuf"><xsl:value-of select="$i18n_users/l/Change_User_Fullname"/></label>
                  </span>
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_ROLE_NAME" id="cb-acc-crn" class="checkbox">
                          <xsl:if test="system_privileges/change_role_name = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-crn"><xsl:value-of select="$i18n_users/l/Change_Rolename"/></label>
                  </span>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CHANGE_USER_NAME" id="cb-acc-cun" class="checkbox">
                          <xsl:if test="system_privileges/change_user_name = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cun"><xsl:value-of select="$i18n_users/l/Change_Username"/></label>
                  </span>
              <br/>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_CREATE_USER" id="cb-acc-cu" class="checkbox">
                          <xsl:if test="system_privileges/create_user = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-cu"><xsl:value-of select="$i18n_users/l/Create_User"/></label>
                  </span>
                 <span class="cboxitem">
                      <input type="checkbox" name="system_privs_DELETE_USER" id="cb-acc-du" class="checkbox">
                          <xsl:if test="system_privileges/delete_user = 1">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                          </xsl:if>
                      </input>
                      <label for="cb-acc-du"><xsl:value-of select="$i18n_users/l/Delete_User"/></label>
                  </span>
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
	<div class="form-div">
		<div>
			<div class="label-med"><label for="acc-lastname"><xsl:value-of select="$i18n_users/l/Lastname"/>*:</label></div>
			<input size="30" maxlength="30" name="lastname" type="text" value="{lastname}" id="acc-lastname"/>
		</div>
		<div>
			<div class="label-med"><label for="acc-middlename"><xsl:value-of select="$i18n_users/l/Middlename"/>:</label></div>
			<input size="30" maxlength="30" name="middlename" type="text" value="{middlename}" id="acc-middlename"/>
		</div>
		<div>
			<div class="label-med"><label for="acc-firstname"><xsl:value-of select="$i18n_users/l/Firstname"/>:</label></div>
			<input size="30" maxlength="30" name="firstname" type="text" value="{firstname}" id="acc-firstname"/>
		</div>
		<div>
			<div class="label-med"><label for="acc-email"><!--<xsl:value-of select="$i18n/l/Email"/>-->Email:</label></div>
			<input size="30" maxlength="80" name="email" type="text" value="{email}" id="acc-email"/>
		</div>
		<div>
			<div class="label-med"><label for="acc-url">URL:</label></div>
			<input size="30" maxlength="80" name="url" type="text" value="{url}" id="acc-url"/>
		</div>
	</div>
</xsl:template>

<xsl:template name="user_isadmin">
	<div>
	<fieldset>
      <legend class="label-med"><xsl:value-of select="$i18n_users/l/User_is_Administrator"/>:</legend>
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
	</div>
</xsl:template>

<xsl:template name="account_enabled">
	<div>
	<fieldset>
		<legend class="label-med"><xsl:value-of select="$i18n_users/l/Account_is_Enabled"/>:</legend><!--</div>-->
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
	</div>
</xsl:template>

<xsl:template name="exitform">
    <xsl:param name="action"/>
    <xsl:param name="save"><xsl:value-of select="$i18n/l/save"/></xsl:param>
			<!--<button name="{$action}" type="submit" class="button"><xsl:value-of select="$i18n/l/save"/></button>-->
			<button name="{$action}" type="submit" class="button"><xsl:value-of select="$save"/></button>
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
			<button class="button" name="c" type="submit" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>

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

