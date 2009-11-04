<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_obj_userlist.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">


  <xsl:import href="common.xsl"/>
  <xsl:import href="common_header.xsl"/>

  <xsl:param name="sort-by">id</xsl:param>
  <xsl:param name="order-by">ascending</xsl:param>
  <xsl:param name="userquery"/>
  <xsl:param name="usertype">user</xsl:param>
  <xsl:param name="id"/>

<!--<xsl:variable name="order-by-opposite">
  <xsl:choose>
    <xsl:when test="$order-by='ascending'">descending</xsl:when>
    <xsl:otherwise>ascending</xsl:otherwise>
  </xsl:choose>
</xsl:variable>-->

<xsl:template match="/document">
    <xsl:apply-templates select="context"/>
</xsl:template>

<xsl:template match="/document/context">
    <html>
          <xsl:call-template name="head_default">
				<xsl:with-param name="mode">mg-acl</xsl:with-param>
      </xsl:call-template>

        <body>
        <xsl:call-template name="header">
					<!--<xsl:with-param name="nopath">true</xsl:with-param>-->
        </xsl:call-template>
        
        <div id="table-container">
          <h1 class="bluebg">
            <xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="$absolute_path"/>'</h1>

          <!-- filter widget table -->
              <form name="userfilter">
								<p>
                    <xsl:choose>
                        <xsl:when test="$userquery = ''">
                            <xsl:value-of select="$i18n/l/Currently_showing_privs"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--<xsl:value-of select="$i18n/l/Click"/>
                            <xsl:text>&#160;</xsl:text>
                            <a href="{$goxims_content}{$absolute_path}?obj_acllist=1">
                                <xsl:value-of select="$i18n/l/here"/>
                            </a>
                            <xsl:text>&#160;</xsl:text>
                            <xsl:value-of select="$i18n/l/to_show_existing_privs"/>.-->
                            <a href="{$goxims_content}{$absolute_path}?obj_acllist=1">
                                <xsl:value-of select="$i18n/l/Show_existing_privs"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                 </p>
                 <p>
                    <xsl:value-of select="$i18n/l/Privgrant_usr_lookup_mask"/>:
											<br/>
									<label for="userquery" class="hidden"><xsl:value-of select="$i18n/l/Name"/>&#160;<xsl:value-of select="$i18n/l/of"/>&#160;<xsl:value-of select="$i18n/l/User"/>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;<xsl:value-of select="$i18n/l/Role"/>&#160;</label>
                  <input name="userquery" type="text" value="{$userquery}" id="userquery"/>
                  <label for="usertype" class="hidden"><xsl:value-of select="$i18n/l/Usertype"/></label>
                  <select name="usertype" id="usertype">
                    <option value="role">
                      <xsl:if test="$usertype='role'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$i18n/l/Roles"/>
                    </option>
                    <option value="user">
                      <xsl:if test="$usertype='user'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$i18n/l/Users"/>
                    </option>
                  </select>
                  <input name="id" type="hidden" value="{$id}"/>
                  <input name="obj_acllist" type="hidden" value="1"/>
                  <input name="sort-by" type="hidden" value="{$sort-by}"/>
                  <input name="order-by" type="hidden" value="{$order-by}"/>
                  <xsl:call-template name="rbacknav"/>
									&#160;
                  <input type="submit"
                         class="ui-state-default ui-corner-all fg-button"
                         value="{$i18n/l/lookup}"
                  />
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript:openDocWindow('grantuserlookup')" class="doclink">(?)</a>
              </p>
              </form>
          <!-- end filter widget table -->
				<!--</div>
				
				<div id="table-container">-->
        <table  id="obj-table">
          <xsl:choose>
            <xsl:when test="granteelist/user or /document/userlist/user">
              <!-- we got users or roles -->

              <!-- begin app sort order by nav -->
              <thead>
              <tr>
                <th id="th-id" class="sorting">
                  <xsl:choose>
                    <xsl:when test="$sort-by='id'">
											<xsl:choose>
												<xsl:when test="$order-by='ascending'">
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=id',
                                                       ';order-by= descending', 
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-n"/>
                        <xsl:value-of select="$i18n/l/ID"/>
                      </a>
                      </xsl:when>
                      <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=id',
                                                       ';order-by=ascending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-s"/>
                        <xsl:value-of select="$i18n/l/ID"/>
                      </a>
                      </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=id',
                                                       ';order-by=ascending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-2-n-s"/>
                        <xsl:value-of select="$i18n/l/ID"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
                
                <th id="th-role" class="sorting">
                  <xsl:choose>
                    <xsl:when test="$sort-by='name'">
                    <xsl:choose>
												<xsl:when test="$order-by='ascending'">						
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=name',
                                                       ';order-by=descending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-n"/>
                        <xsl:value-of select="$i18n/l/Username"/>
                      </a>
                      </xsl:when>
                      <xsl:otherwise>
												<a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=name',
                                                       ';order-by=ascending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-s"/>
                        <xsl:value-of select="$i18n/l/Username"/>
                      </a>                      
                      </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=name',
                                                       ';order-by=ascending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-2-n-s"/>
                        <xsl:value-of select="$i18n/l/Username"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
                
                <th id="th-name" class="sorting">
                  <xsl:choose>
                    <xsl:when test="$sort-by='fullname'">
											<xsl:choose>
												<xsl:when test="$order-by='ascending'">
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=fullname',
                                                       ';order-by=descending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-n"/>
                        <xsl:value-of select="$i18n/l/Name"/>
                      </a>
                      </xsl:when>
                      <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=fullname',
                                                       ';order-by=ascending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-s"/>
                        <xsl:value-of select="$i18n/l/Name"/>
                      </a>
                      </xsl:otherwise>
											</xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=fullname',
                                                       ';order-by=ascending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-2-n-s"/>
                        <xsl:value-of select="$i18n/l/Name"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
                
                <th id="th-accstat" class="sorting">
                  <xsl:choose>
                    <xsl:when test="$sort-by='enabled'">
                    <xsl:choose>
											<xsl:when test="$order-by='ascending'">
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=enabled',
                                                       ';order-by=descending',
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-n"/>
                        <xsl:value-of select="$i18n/l/Account_status"/>
                      </a>                   
                      </xsl:when>
                      <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=enabled',
                                                       ';order-by=ascending', 
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-1-s"/>
                        <xsl:value-of select="$i18n/l/Account_status"/>
                      </a>
                      </xsl:otherwise>
										</xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <a class="th-icon-right">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=enabled',
                                                       ';order-by=ascending', 
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <span class="ui-icon ui-icon-triangle-2-n-s"/>
                        <xsl:value-of select="$i18n/l/Account_status"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
                
                <th id="th-options">
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
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
                        <xsl:sort select="@id"
                                  order="ascending"
                                  data-type="number"/>
                        <xsl:apply-templates select="."/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
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
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
                        <xsl:sort select="name"
                                  order="ascending"/>
                        <xsl:apply-templates select="."/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
                        <xsl:sort select="name"
                                  order="descending"/>
                        <xsl:apply-templates select="."/>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="$sort-by='fullname'">
                  <xsl:choose>
                    <xsl:when test="$order-by='ascending'">
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
                        <xsl:sort select="lastname"
                                  order="ascending"/>
                        <xsl:apply-templates select="."/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
                        <xsl:sort select="lastname"
                                  order="descending"/>
                        <xsl:apply-templates select="."/>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="$sort-by='enabled'">
                  <xsl:choose>
                    <xsl:when test="$order-by='ascending'">
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
                        <xsl:sort select="enabled"
                                  order="ascending"/>
                        <xsl:apply-templates select="."/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="granteelist/user|/document/userlist/user">
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
            </xsl:when>
            <xsl:otherwise>
            <tbody>
                <!-- we got no users or roles -->
                <tr><td align="center"><p class="messagewarning"><xsl:value-of select="$i18n/l/No_user_found"/></p></td></tr>
														
						</tbody>
            </xsl:otherwise>
          </xsl:choose>
          
        </table>
        </div>
				<!--</div>-->
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>

</xsl:template>

<xsl:template match="/document/context/granteelist/user|/document/userlist/user">
  <tr>
   <!-- user/role bgcolor -->
   <xsl:if test="object_type='role'">
     <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
   </xsl:if>

   <td><xsl:value-of select="@id"/></td>
   <xsl:apply-templates select="name"/>
   <td><xsl:call-template name="userfullname"/></td>
   <xsl:apply-templates select="enabled"/>

   <!-- begin options bar -->
   <td>
         <xsl:choose>
           <xsl:when test="$userquery != ''">
             <a>
               <xsl:attribute name="href">
                 <xsl:value-of select="concat($goxims_content,'?obj_acllist=1;userid=',@id,';newgrant=1;id=',/document/context/object/@id)"/>
                 <xsl:call-template name="rbacknav_qs"/>
               </xsl:attribute>
               <xsl:value-of select="$i18n/l/Grant_newprivs"/>
             </a>
           </xsl:when>
           <xsl:otherwise>
             <a>
               <xsl:attribute name="href">
                 <xsl:value-of select="concat($goxims_content,'?obj_acllist=1;userid=',@id,';id=',/document/context/object/@id)"/>
                 <xsl:call-template name="rbacknav_qs"/>
               </xsl:attribute>
               <xsl:value-of select="$i18n/l/Manage_privs"/>
             </a>
           </xsl:otherwise>
         </xsl:choose>
   </td>
   <!-- end options bar -->
  </tr>
</xsl:template>

<xsl:template match="lastname|name">
   <td><xsl:value-of select="."/></td>
</xsl:template>

<xsl:template match="enabled">
  <td>
   <xsl:choose>
     <xsl:when test="text()='1'">
       <xsl:value-of select="$i18n/l/enabled"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$i18n/l/disabled"/>
     </xsl:otherwise>
   </xsl:choose>
  </td>
</xsl:template>

</xsl:stylesheet>
