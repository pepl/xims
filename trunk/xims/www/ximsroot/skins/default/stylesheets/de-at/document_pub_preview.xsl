<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_pub_preview.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../../../../stylesheets/config.xsl"/>
<xsl:import href="public/common.xsl"/>
<xsl:param name="request.uri"/>

<xsl:output method="html" encoding="utf-8"/>

<xsl:template match="/document/context/object">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
    <head>
          <xsl:call-template name="meta"/>
          <title><xsl:value-of select="title"/></title>
          <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
          <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>

    <body margintop="0" marginleft="0" marginwidth="0" marginheight="0">
          <table border="0" cellpadding="0" cellspacing="0" width="790">
               <xsl:call-template name="header">
                    <xsl:with-param name="no_navigation_at_all">true</xsl:with-param>
               </xsl:call-template>

              <tr>
                  <td class="links">
                    <!-- Begin Search -->
                    <!--<xsl:call-template name="search"/>-->
                    <!-- End Search -->

                    <!-- Begin Standard Links -->
                    <!--<xsl:call-template name="stdlinks"/>-->
                    <!-- End Standard Links -->

                    <!-- Begin Department Links -->
                    <xsl:call-template name="deptlinks"/>
                    <!-- End Department Links -->

                    <!-- Begin Document Links -->
                    <xsl:call-template name="documentlinks"/>
                    <!-- End Document Links -->
                </td>
                <td class="content" >

                      <!-- Begin content -->
                      <xsl:apply-templates select="body"/><br />
                      <!-- End content -->
                      <!-- Begin footer -->
                       <div class="footer">
                            <xsl:call-template name="metafooter"/>
                       </div>
                 </td>
                 <td />
             </tr>
             <tr>
                 <td valign="top" align="right" colspan="2">
                     <xsl:call-template name="powerdbyfooter"/>
                 </td>
             </tr>
                      <!-- End footer -->
        </table>

</body>
</html>
</xsl:template>

<xsl:template name="search">
        <form class="qsearch">
        <table cellpadding="0" cellspacing="0" border="0" width="128" >
            <tr>
                <td>
                      <input class="qsfield" type="text" name="search" size="6" value="[Schnellsuche]"/>
                </td>
                <td>
                      <img src="/images/icons/search_go.gif" width="24" height="11" border="0" alt="" />
                </td>
             </tr>
            </table>
    </form>
</xsl:template>

<xsl:template name="deptlinks">
        <p class="deptlinks" style="color:#123853; text-decoration:underline;">
        Foo<br />
        Bar<br />
        Bogo<br />
        </p>

</xsl:template>

<xsl:template name="documentlinks">
    <xsl:if test="children/object/title != ''">
        <p class="documentlinks" style="color:#123853; text-decoration:underline;">
        <xsl:for-each select="children/object/title">
            <xsl:value-of select="."/><br />
        </xsl:for-each>
        </p>
    </xsl:if>
</xsl:template>

<xsl:template match="a">
    <span class="pseudolink"><xsl:value-of select="text()"/></span>
</xsl:template>

<xsl:template name="header">
    <tr>
        <td bgcolor="#123853" colspan="2">
            <span style="color:#ffffff; font-size:14pt;">
                The eXtensible Information Management System
            </span>
        </td>
        <td bgcolor="#123853" align="right"><xsl:text>&#160;</xsl:text></td>
    </tr>
    <tr>
        <td class="pathinfo" colspan="2">
            <xsl:call-template name="pathinfo"/>
        </td>
        <td class="pathinfo" align="right">
            <span class="pseudolink">[textonly]</span>
        </td>
    </tr>
</xsl:template>

<xsl:template name="copyfooter">
    <p class="copy">
          © 2000 - 2012 Example Org. - All rights reserved<br />
          <span class="pseudolink">Help</span> | <span class="pseudolink">Mail to webmaster</span>
   </p>
</xsl:template>

<xsl:template name="powerdbyfooter">
</xsl:template>

</xsl:stylesheet>
