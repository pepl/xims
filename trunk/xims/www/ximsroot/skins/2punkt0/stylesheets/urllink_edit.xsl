<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: urllink_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <!--<xsl:call-template name="common-head">
        <xsl:with-param name="mode" 
                        select="'edit'"/>
        <xsl:with-param name="calendar" 
                        select="true()"/>
      </xsl:call-template>-->
      <xsl:call-template name="head_default">
					<xsl:with-param name="calendar">true</xsl:with-param>
      </xsl:call-template>
      <body>
        <xsl:call-template name="header"/>
        <div class="edit">
            <div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-edit"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
          <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST" id="create-edit-form">
            
              <xsl:call-template name="tr-location-edit_urllink"/>
              <xsl:call-template name="tr-title-edit"/>
              <xsl:call-template name="tr-keywords-edit"/>
              <xsl:call-template name="tr-abstract-edit"/>
              <xsl:call-template name="tr-valid_from"/>
              <xsl:call-template name="tr-valid_to"/>
              <xsl:call-template name="markednew"/>
            
            <xsl:call-template name="saveedit"/>
          </form>
        </div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
				</div>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="tr-location-edit_urllink">
    <div id="tr-location">
    <div id="label-location"><label for="input-location">
				<span class="compulsory">
          <xsl:value-of select="$i18n/l/Location"/>
        </span>    
    </label></div> 
        <input type="text" class="text" name="name" size="60" id="input-location">
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
       <!-- <xsl:call-template name="marked_mandatory"/>-->
      </div>
  </xsl:template>

	<xsl:template name="title">
		<xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
</xsl:template>
  
</xsl:stylesheet>
