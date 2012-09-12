<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="dyn">

  <xsl:import href="common.xsl"/>
  
  <xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
  <xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title>
          <xsl:value-of select="$i18n_vlib/l/keyword"/>
        </title>
        <xsl:call-template name="css"/>
        <xsl:call-template name="script_head"/>
      </head>
      <body  style="width:auto;">
        <div id="content-container">
          <form action="" name="eform" method="get" id="create-edit-form">
            <input type="hidden" name="id" id="id" value="{@id}"/>
            <xsl:apply-templates select="/document/context/object/children"/>
          </form>
        </div>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>
  

  <xsl:template match="children/object">
        <h1><xsl:value-of select="$i18n_vlib/l/keyword"/></h1>
        <div>
			<div class="label-std">
            <label for="vlkeyword_name">
             <xsl:value-of select="$i18n/l/Name"/>
            </label>
          </div>
            <input readonly="readonly" type="text" id="vlkeyword_name" name="vlkeyword_name" size="40" value="{name}" />
        </div>
        <div>
			<div class="label-std">
            <label for="vlkeyword_description">
              <xsl:value-of select="$i18n_vlib/l/description"/>
            </label>
          </div>
            <textarea readonly="readonly" id="vlkeyword_description" cols="38" rows="10">
							<xsl:apply-templates select="description"/>
						</textarea>
          </div> 
        <br/>
    <p>
      <button type="submit" onclick="window.opener.refresh('keyword');self.close();return false;" class="button" accesskey="S">OK, <xsl:value-of select="$i18n/l/close_window"/></button>
      &#160;
      <!-- The simple solution history.go(-1) would lead to a stale -->
      <!-- second entry, if we wanted tho fix a freshly created keyword. -->
      <button type="submit" onclick="location.replace('{$xims_box}{$goxims_content}' + '?id={/document/context/object/@id}' + ';property_edit=1;property=keyword;property_id={@id}'); return false;" class="button" accesskey="B"><xsl:value-of select="$i18n/l/Back"/></button> </p>

  </xsl:template>
</xsl:stylesheet>
