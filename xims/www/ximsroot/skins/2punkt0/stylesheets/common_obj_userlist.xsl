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

  <xsl:param name="sort-by">id</xsl:param>
  <xsl:param name="order-by">ascending</xsl:param>
  <xsl:param name="userquery"/>
  <xsl:param name="usertype">user</xsl:param>
  <xsl:param name="id"/>
  <xsl:param name="tooltip"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context"/>
</xsl:template>

<xsl:template match="/document/context">
<xsl:choose>
<xsl:when test="$tooltip= ''">
    <html>
          <xsl:call-template name="head_default">
				<xsl:with-param name="mode">mg-acl</xsl:with-param>
      </xsl:call-template>

        <body>
        <xsl:call-template name="header">
        </xsl:call-template>
        
        <div id="content-container">
          <h1 class="bluebg">
            <xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="$absolute_path"/>'</h1>

		<p>
                    <xsl:choose>
                        <xsl:when test="$userquery = ''">
                            <xsl:value-of select="$i18n/l/Currently_showing_privs"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="{$goxims_content}{$absolute_path}?obj_acllist=1">
                                <xsl:value-of select="$i18n/l/Show_existing_privs"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                 </p>
				 <!-- filter widget  -->
              <form name="userfilter" action="">
                 <p>
                    <xsl:value-of select="$i18n/l/Privgrant_usr_lookup_mask"/>:
											<br/>
									<label for="userquery" class=""><xsl:value-of select="$i18n/l/Name"/>&#160;<xsl:value-of select="$i18n/l/of"/>&#160;<xsl:value-of select="$i18n/l/User"/>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;<xsl:value-of select="$i18n/l/Role"/>&#160;</label>&#160;
                  <input name="userquery" type="text" value="{$userquery}" id="userquery"/>&#160;&#160;
                  <label for="usertype" class=""><xsl:value-of select="$i18n/l/Usertype"/></label>&#160;
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
                  <button type="submit" ><xsl:value-of select="$i18n/l/lookup"/></button>
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript:openDocWindow('grantuserlookup')" class="doclink">(?)</a>
              </p>
              </form>
          <!-- end filter widget  -->
			<p> </p>	
        <table  class="obj-table acl-table">
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
                <th id="th-options-acl">
                    <xsl:value-of select="$i18n/l/Options"/>
                </th>
              </tr>
              </thead>
	
							<tbody>
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
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:when>
<xsl:otherwise>
	        <table  class="obj-table">
          <xsl:choose>
            <xsl:when test="granteelist/user or /document/userlist/user">
              <!-- we got users or roles -->

              <!-- begin app sort order by nav -->
              <thead>
              <tr>				
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
                <th id="th-options-acl">
                    <xsl:value-of select="$i18n/l/Options"/>
                </th>
              </tr>
              </thead>
	
			<tbody>
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
              </xsl:choose>
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
</xsl:otherwise>
</xsl:choose>


</xsl:template>

<xsl:template match="/document/context/granteelist/user|/document/userlist/user">
  <tr class="objrow">
  
   <!-- user/role bgcolor -->
   <!--<xsl:if test="object_type='role'">-->
  <!-- user is role if objecttype = 1 -->
   <!--<xsl:if test="object_type='1'">
     <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
   </xsl:if>-->

 <xsl:if test="$tooltip= ''">
   <td><xsl:value-of select="@id"/></td>
 </xsl:if>
   <xsl:apply-templates select="name"/>

<xsl:if test="$tooltip= ''">
   <td><xsl:call-template name="userfullname"/></td>
   <xsl:apply-templates select="enabled"/>
</xsl:if>
   <!-- begin options bar -->
<td>
	<form action="{$xims_box}{$goxims_content}" method="get">

<div>
<xsl:attribute name="id">buttonset_<xsl:value-of select="@id"/>_<xsl:value-of select="/document/context/object/@id"/></xsl:attribute>
	</div>
<script type="text/javascript">
	$(document).ready(function() {
		if($('#buttonset_<xsl:value-of select="@id"/>_<xsl:value-of select="/document/context/object/@id"/>').html() == ''){
			$.get('http://testlx1.uibk.ac.at<xsl:value-of select="concat($goxims_content,'?obj_acllight=1;userid=',@id,';id=',/document/context/object/@id)"/>',
				function(data){
					$('#buttonset_<xsl:value-of select="@id"/>_<xsl:value-of select="/document/context/object/@id"/>').html(data)
					$('#buttonset_<xsl:value-of select="@id"/>_<xsl:value-of select="/document/context/object/@id"/>').buttonset();
			});
		}		
	});
	</script>	
	 <xsl:if test="$tooltip= ''">
	<button class="button" name="obj_aclgrant" type="submit"><xsl:value-of select="$i18n/l/save"/></button>
	<input name="userid" type="hidden" >
		<xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
	</input>
	<input name="id" type="hidden" value="{/document/context/object/@id}"/>
	<xsl:call-template name="rbacknav"/>
	&#160;
	<button class="button" name="obj_aclrevoke" type="submit"><xsl:value-of select="$i18n/l/Revoke_grants"/></button>
	</xsl:if>
	</form>
</td>
   <!-- end options bar -->
  </tr>
</xsl:template>

<xsl:template match="lastname|name">
   <td><xsl:value-of select="."/></td>
</xsl:template>

<xsl:template match="enabled">
  <td class="ctt_accstatus">
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

