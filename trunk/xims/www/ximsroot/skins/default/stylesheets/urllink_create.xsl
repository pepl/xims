<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="common-head">
        <xsl:with-param name="mode" 
                        select="'create'"/>
        <xsl:with-param name="calendar" 
                        select="true()"/>
      </xsl:call-template>
      <body onLoad="document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
          <xsl:call-template name="table-create"/>
          <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" 
                name="eform" 
                method="POST" 
                style="margin-top:0px;">
            <input type="hidden" 
                   name="objtype" 
                   value="{$objtype}"/>
            <table border="0" 
                   width="98%">
              <xsl:call-template name="tr-location-create">
                <xsl:with-param name="testlocation" select="false()"/>
              </xsl:call-template>
              <xsl:call-template name="tr-title-create"/>
              <xsl:call-template name="tr-keywords-create"/>
              <xsl:call-template name="tr-abstract-create"/>
              <xsl:call-template name="tr-valid_from"/>
              <xsl:call-template name="tr-valid_to"/>
              <xsl:call-template name="markednew"/>
              <xsl:call-template name="grantowneronly"/>
            </table>
            <xsl:call-template name="saveaction"/>
          </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>