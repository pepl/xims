<?xml version="1.0" encoding="utf-8"?>
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

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="common-head">
        <xsl:with-param name="mode" 
                        select="'create'"/>
        <xsl:with-param name="calendar" 
                        select="true()"/>
      </xsl:call-template>
      <body onload="document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
          <xsl:call-template name="table-create"/>
          <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" 
                name="eform" 
                method="post" 
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
  
  <xsl:template name="tr-location-create">
    <xsl:param name="testlocation" select="true()"/>
    <tr>
      <td valign="top">
        <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
        <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
      </td>
      <td>
        <input tabindex="10" 
               type="text" 
               name="name" 
               size="40" 
               class="text"
               onfocus="this.className='text focused'"
               onblur="this.className='text';">
          <xsl:if test="$testlocation">
            <xsl:attribute name="onchange">return testlocation();</xsl:attribute>
          </xsl:if>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        <!-- location-testing AJAX code -->
        <xsl:if test="$testlocation">
          <xsl:call-template name="testlocationjs">
            <xsl:with-param name="event" select="'create'"/>
          </xsl:call-template>
        </xsl:if>        
        <xsl:text>&#160;</xsl:text>
            <a href=" javascript:genericWindow('{$xims_box}{$goxims_content}?id={/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;sbfield=eform.name;urllink=1')" id="buttonBrTarget">
                <xsl:value-of select="$i18n/l/browse_target"/>
            </a>
      </td>
      <td align="right" valign="top">
        <xsl:call-template name="marked_mandatory"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
