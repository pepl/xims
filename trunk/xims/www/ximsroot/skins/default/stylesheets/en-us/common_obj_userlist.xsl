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
<xsl:output method="html" encoding="ISO-8859-1"/>
<xsl:param name="sort-by">id</xsl:param>
<xsl:param name="order-by">ascending</xsl:param>
<xsl:param name="usertype">0</xsl:param>
<xsl:param name="userquery"/>
<xsl:param name="usertype">role</xsl:param>
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
                Managing User/Role Access for Object '<xsl:value-of select="object/title"/>' - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript">0</script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
        <xsl:call-template name="header"/>

        <table width="100%" cellpadding="2" cellspacing="0" border="0">
        <tr>
          <td class="bluebg" align="center">
            Managing User/Role Access for Object: <xsl:value-of select="$absolute_path"/>
          </td>
          </tr>
          <tr bgcolor="#eeeeee">
          <td align="center">
          <!-- filter widget table -->
              <table cellpadding="0" cellspacing="0" border="0">
              <form name="userfilter" style="margin: 0">
              <tr>
                <td colspan="4" align="center">
                    <xsl:choose>
                        <xsl:when test="$userquery = ''">
                            Currently showing existing grants.
                        </xsl:when>
                        <xsl:otherwise>
                            Click <a href="{$goxims_content}{$absolute_path}?obj_acllist=1">
                                      here
                                  </a>
                            to show already existing grants.
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
              </tr>
              <tr>
                <td>
                  To look for roles or users to give new grants to, use the following input-field:
                </td>
                <td>
                  <input name="userquery" type="text" value="{$userquery}"/>
                  <select name="usertype">
                    <option value="role">
                      <xsl:if test="$usertype='role'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                      </xsl:if>
                      Roles
                    </option>
                    <option value="user">
                      <xsl:if test="$usertype='user'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                      </xsl:if>
                      Users
                    </option>
                  </select>
                  <input name="id" type="hidden" value="{$id}"/>
                  <input name="obj_acllist" type="hidden" value="1"/>
                  <input name="sort-by" type="hidden" value="{$sort-by}"/>
                  <input name="order-by" type="hidden" value="{$order-by}"/>
                </td>
                <td>&#160;</td>
                <td>
                  <input type="submit"
                         class="control"
                         value="Lookup"
                  />
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript:openDocWindow('grantuserlookup')" class="doclink">(?)</a>
                </td>
              </tr>
              </form>
              </table>
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
                <td width="20" background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">&#160;</td>
                <td background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">
                  <xsl:choose>
                    <xsl:when test="$sort-by='id'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=id;',
                                                       'order-by=', $order-by-opposite, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        ID
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=id;',
                                                       'order-by=', $order-by, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        ID
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">
                  <xsl:choose>
                    <xsl:when test="$sort-by='name'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=name;',
                                                       'order-by=', $order-by-opposite, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        Username
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=name;',
                                                       'order-by=', $order-by, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        Username
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">
                  <xsl:choose>
                    <xsl:when test="$sort-by='fullname'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=fullname;',
                                                       'order-by=', $order-by-opposite, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        Full Name
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=fullname;',
                                                       'order-by=', $order-by, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        Full Name
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">
                  <xsl:choose>
                    <xsl:when test="$sort-by='enabled'">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=enabled;',
                                                       'order-by=', $order-by-opposite, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        Account Status
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($goxims_content,
                                                       $absolute_path,
                                                       '?',
                                                       'obj_acllist=1;',
                                                       'sort-by=enabled;',
                                                       'order-by=', $order-by, ';',
                                                       'userquery=', $userquery, ';',
                                                       'usertype=', $usertype
                                                      )"/>
                        </xsl:attribute>
                        Account Status
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png" width="250" align="right">
                  <img src="{$ximsroot}images/options.png" width="180" height="21" alt="options"/>
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
                <tr><td align="center"><p class="messagewarning">No users or roles found. Please type in a valid user or role name in the lookup field!</p></td></tr>
            </xsl:otherwise>
          </xsl:choose>
        </table>

        </td>
        </tr>
        </table>
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
   <table width="100" cellpadding="0" cellspacing="2" border="0">
   <tr>
      <td>
         <xsl:choose>
           <xsl:when test="$userquery != ''">
             <a>
               <xsl:attribute name="href">
                 <xsl:value-of select="concat($goxims_content,'?obj_acllist=1;userid=',@id,';newgrant=1;id=',/document/context/object/@id)"/>
               </xsl:attribute>
               Grant Access
             </a>
           </xsl:when>
           <xsl:otherwise>
             <a>
               <xsl:attribute name="href">
                 <xsl:value-of select="concat($goxims_content,'?obj_acllist=1;userid=',@id,';id=',/document/context/object/@id)"/>
               </xsl:attribute>
               Manage Access
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
       <xsl:text>enabled</xsl:text>
     </xsl:when>
     <xsl:otherwise>
       <xsl:text>disabled</xsl:text>
     </xsl:otherwise>
   </xsl:choose>
  </td>
</xsl:template>


</xsl:stylesheet>

