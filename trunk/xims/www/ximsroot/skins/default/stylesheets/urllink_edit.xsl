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
                        select="'edit'"/>
        <xsl:with-param name="calendar" 
                        select="true()"/>
      </xsl:call-template>
      <body>
        <div class="edit">
          <xsl:call-template name="table-edit"/>
          <form action="{$xims_box}{$goxims_content}?id={@id}" 
                name="eform" 
                method="post">
            <table border="0" 
                   width="98%">
              <xsl:call-template name="tr-locationtitle-edit_urllink"/>
              <xsl:call-template name="tr-keywords-edit"/>
              <xsl:call-template name="tr-abstract-edit"/>
              <xsl:call-template name="tr-valid_from"/>
              <xsl:call-template name="tr-valid_to"/>
              <xsl:call-template name="markednew"/>
            </table>
            <xsl:call-template name="saveedit"/>
          </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="tr-locationtitle-edit_urllink">
    <tr>
      <td valign="top">
        <img src="{$ximsroot}images/spacer_white.gif" 
             alt="*"/>
        <span class="compulsory">
          <xsl:value-of select="$i18n/l/Location"/>
        </span>
      </td>
      <td>
        <input tabindex="10" 
               type="text" 
               class="text"
               onfocus="this.className='text focused'"
               onblur="this.className='text';"
               name="name" 
               size="40">
          <xsl:choose>
            <xsl:when test="string-length(symname_to_doc_id) > 0 ">
              <xsl:attribute name="value">
                <xsl:value-of select="symname_to_doc_id"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="value">
                <xsl:value-of select="location"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
            <a href=" javascript:genericWindow('{$xims_box}{$goxims_content}?id={/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;sbfield=eform.name;urllink=1')" id="buttonBrTarget">
                <xsl:value-of select="$i18n/l/browse_target"/>
            </a>
      </td>
      <td align="right" 
          valign="top">
        <xsl:call-template name="marked_mandatory"/>
      </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
  </xsl:template>
  
</xsl:stylesheet>
