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
<xsl:param name="sort-by">id</xsl:param>
<xsl:param name="order-by">ascending</xsl:param>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="$i18n/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>/<xsl:value-of select="$i18n/l/Roles"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

<xsl:variable name="order-by-opposite">
  <xsl:choose>
    <xsl:when test="$order-by='ascending'">descending</xsl:when>
    <xsl:otherwise>ascending</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="userlist">
        <table width="99%" cellpadding="0" cellspacing="0" border="0">
          <!-- begin app sort order by nav -->
          <tr background="{$skimages}generic_tablebg_1x20.png">
            <td background="{$skimages}generic_tablebg_1x20.png" width="20">&#160;</td>
            <td background="{$skimages}generic_tablebg_1x20.png">
              <xsl:choose>
                <xsl:when test="$sort-by='id'">
                  <a href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by-opposite}">ID</a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{$xims_box}{$goxims_users}?sort-by=id;order-by={$order-by}">ID</a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td background="{$skimages}generic_tablebg_1x20.png">
              <xsl:choose>
                <xsl:when test="$sort-by='name'">
                  <a href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by-opposite}"><xsl:value-of select="$i18n/l/Username"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{$xims_box}{$goxims_users}?sort-by=name;order-by={$order-by}"><xsl:value-of select="$i18n/l/Username"/></a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td background="{$skimages}generic_tablebg_1x20.png">
              <xsl:choose>
                <xsl:when test="$sort-by='lastname'">
                  <a href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by-opposite}"><xsl:value-of select="$i18n/l/Lastname"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{$xims_box}{$goxims_users}?sort-by=lastname;order-by={$order-by}"><xsl:value-of select="$i18n/l/Lastname"/></a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td background="{$skimages}generic_tablebg_1x20.png">
              <xsl:choose>
                <xsl:when test="$sort-by='system_privs_mask'">
                  <a href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by-opposite}"><xsl:value-of select="$i18n/l/System_privileges"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{$xims_box}{$goxims_users}?sort-by=system_privs_mask;order-by={$order-by}"><xsl:value-of select="$i18n/l/System_privileges"/></a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td background="{$skimages}generic_tablebg_1x20.png">
              <xsl:choose>
                <xsl:when test="$sort-by='admin'">
                  <a href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by-opposite}"><xsl:value-of select="$i18n/l/Administrator"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{$xims_box}{$goxims_users}?sort-by=admin;order-by={$order-by}"><xsl:value-of select="$i18n/l/Administrator"/></a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td background="{$skimages}generic_tablebg_1x20.png">
              <xsl:choose>
                <xsl:when test="$sort-by='enabled'">
                  <a href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by-opposite}"><xsl:value-of select="$i18n/l/Account_status"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{$xims_box}{$goxims_users}?sort-by=enabled;order-by={$order-by}"><xsl:value-of select="$i18n/l/Account_status"/></a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td background="{$skimages}generic_tablebg_1x20.png" width="250">
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
  <tr>
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
       <xsl:value-of select="$i18n/l/Enabled"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$i18n/l/Disabled"/>
     </xsl:otherwise>
   </xsl:choose>
  </td>
</xsl:template>

</xsl:stylesheet>
