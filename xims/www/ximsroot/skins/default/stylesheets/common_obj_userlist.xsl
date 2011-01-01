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

  <xsl:param name="sort-by">id</xsl:param>
  <xsl:param name="order-by">ascending</xsl:param>
  <xsl:param name="userquery"/>
  <xsl:param name="usertype">user</xsl:param>
  <xsl:param name="id"/>

<xsl:variable name="order-by-opposite">
  <xsl:choose>
    <xsl:when test="$order-by='ascending'">descending</xsl:when>
    <xsl:otherwise>ascending</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="/document">
    <xsl:apply-templates select="context"/>
</xsl:template>

<xsl:template match="/document/context">
    <html>
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="object/title"/>' - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>
        <body>
        <xsl:call-template name="header"/>

        <table width="100%" cellpadding="2" cellspacing="0" border="0">
        <tr>
          <td class="bluebg" align="center">
            <xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="$absolute_path"/>'
          </td>
          </tr>
          <tr bgcolor="#eeeeee">
          <td align="center">
          <!-- filter widget table -->
          <form name="userfilter" style="margin: 0" action="">
              <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td colspan="4" align="center">
                    <xsl:choose>
                        <xsl:when test="$userquery = ''">
                            <xsl:value-of select="$i18n/l/Currently_showing_privs"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$i18n/l/Click"/>
                            <xsl:text>&#160;</xsl:text>
                            <a href="{$goxims_content}{$absolute_path}?obj_acllist=1">
                                <xsl:value-of select="$i18n/l/here"/>
                            </a>
                            <xsl:text>&#160;</xsl:text>
                            <xsl:value-of select="$i18n/l/to_show_existing_privs"/>.
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
              </tr>
              <tr>
                <td>
                    <xsl:value-of select="$i18n/l/Privgrant_usr_lookup_mask"/>:
                </td>
                <td>
                  <input name="userquery" type="text" value="{$userquery}"/>
                  <select name="usertype">
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
                </td>
                <td>&#160;</td>
                <td>
                  <input type="submit"
                         class="control"
                         value="{$i18n/l/lookup}"
                  />
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript:openDocWindow('grantuserlookup')" class="doclink">(?)</a>
                </td>
              </tr>              
              </table>
              </form>
          <!-- end filter widget table -->
          </td>
        </tr>
        <tr>
        <td align="center">

        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <xsl:choose>
            <xsl:when test="granteelist/user or /document/userlist/user">
              <!-- we got users or roles -->

              <!-- begin app sort order by nav -->
              <tr>
                <td width="20">&#160;</td>
                <td>
                  <xsl:choose>
                    <xsl:when test="$sort-by='id'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=id',
                                                       ';order-by=', $order-by-opposite,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        ID
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=id',
                                                       ';order-by=', $order-by,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        ID
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:choose>
                    <xsl:when test="$sort-by='name'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=name',
                                                       ';order-by=', $order-by-opposite,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i18n/l/Username"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=name',
                                                       ';order-by=', $order-by,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i18n/l/Username"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:choose>
                    <xsl:when test="$sort-by='fullname'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=fullname',
                                                       ';order-by=', $order-by-opposite,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i18n/l/Name"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=fullname',
                                                       ';order-by=', $order-by,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i18n/l/Name"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:choose>
                    <xsl:when test="$sort-by='enabled'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=enabled',
                                                       ';order-by=', $order-by-opposite,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i18n/l/Account_status"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?obj_acllist=1;sort-by=enabled',
                                                       ';order-by=', $order-by,
                                                       ';userquery=', $userquery,
                                                       ';usertype=', $usertype
                                                      )"/>
                          <xsl:call-template name="rbacknav_qs"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i18n/l/Account_status"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td width="250" align="right">
                    <img src="{$sklangimages}options.png"
                            width="189"
                            height="20"
                            alt="Options"
                            title="Options"
                            />
                </td>
              </tr>

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

            </xsl:when>
            <xsl:otherwise>
                <!-- we got no users or roles -->
                <tr><td align="center"><p class="messagewarning"><xsl:value-of select="$i18n/l/No_user_found"/></p></td></tr>
            </xsl:otherwise>
          </xsl:choose>
        </table>

        </td>
        </tr>
        </table>
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

   <td>&#160;</td>
   <td><xsl:value-of select="@id"/></td>
   <xsl:apply-templates select="name"/>
   <td><xsl:call-template name="userfullname"/></td>
   <xsl:apply-templates select="enabled"/>

   <!-- begin options bar -->
   <td align="right">
   <table width="150" cellpadding="0" cellspacing="2" border="0">
   <tr>
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
   </tr>
   </table>
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

