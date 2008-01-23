<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  
  <xsl:import href="vlibraryitem_common.xsl"/>
  <xsl:import href="document_common.xsl"/>



  <xsl:template name="tr_set-body-edit">
    <xsl:call-template name="tr-body-edit">
      <xsl:with-param name="with_origbody" select="'yes'"/>
    </xsl:call-template>
    <tr>
      <td colspan="3">
        <xsl:call-template name="testbodysxml"/>
        <xsl:call-template name="prettyprint"/>
        <script type="text/javascript">
          <!-- set checked attribute for trytobalance-input-element according to cookie -->
          selTryToBalance(document.eform.trytobalance , readCookie('xims_trytobalancewell'));
        </script>
      </td>
    </tr>
  </xsl:template>
  

  <xsl:template name="head">
    <xsl:call-template name="common-head">
      <xsl:with-param name="mode">edit</xsl:with-param>
      <xsl:with-param name="calendar" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="/document/context/object">
    
    <html>
      <head>
        <xsl:call-template name="head"/>
      </head>
      <body>
        <script src="{$ximsroot}scripts/vlibrary_default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
          <xsl:call-template name="table-edit"/>
          <form action="{$xims_box}{$goxims_content}?id={@id}" 
                name="eform" 
                method="POST">
            <table border="0" width="98%">
              <xsl:call-template name="tr-locationtitle-edit_doc"/>
              <xsl:call-template name="tr-subtitle"/>
              <xsl:call-template name="tr-abstract-edit"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'keyword'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'subject'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'author'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'publication'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-chronicle_from"/>
              <xsl:call-template name="tr-chronicle_to"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr_set-body-edit"/>    
              <xsl:call-template name="markednew"/>
              <xsl:call-template name="expandrefs"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-publisher"/>
              <xsl:call-template name="tr-mediatype"/>
              <xsl:call-template name="tr-coverage"/>
              <xsl:call-template name="tr-audience"/>
              <xsl:call-template name="tr-legalnotice"/>
              <xsl:call-template name="tr-bibliosource"/>
            </table>
            <xsl:call-template name="saveedit"/>
          </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
