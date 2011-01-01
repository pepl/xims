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

<xsl:variable name="object_type_id">
    <xsl:value-of select="/document/context/object/object_type_id"/>
</xsl:variable>
<xsl:variable name="parent_id">
    <xsl:value-of select="/document/context/object/@parent_id"/>
</xsl:variable>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                <xsl:value-of select="title" /> - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
           <tr style="background:url('{$skimages}generic_tablebg_1x20.png');">
            <td>&#160;</td>
          </tr>
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table width="200" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg"><xsl:value-of select="$i18n/l/Privs_updated"/></td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td><xsl:call-template name="message"/></td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td align="center">
                  <table cellpadding="0" cellspacing="0" border="0">
                  <tr align="center">
                   <td>
                    <form name="userConfirm" action="{$xims_box}{$goxims_content}" method="get">
                        <input class="control" name="obj_acllist" type="submit" value="{$i18n/l/Choose_another_user}"/>
                        <input name="id" type="hidden" value="{@id}"/>
                        <xsl:call-template name="rbacknav"/>
                    </form>
                   </td>
                   <td>
                    &#160;
                   </td>
                   <td>
                       <xsl:call-template name="exitredirectform"/>
                   </td>
                  </tr>
                  </table>
                </td>
              </tr>
            </table>
            <!-- end widget table -->
            <br />

            </td>
          </tr>
        </table>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

