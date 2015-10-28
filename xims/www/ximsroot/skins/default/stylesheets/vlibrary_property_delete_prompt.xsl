<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_delete_confirm.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="common.xsl"/>
  <xsl:import href="common_header.xsl"/>
  <!--<xsl:param name="id"/>-->
  <xsl:param name="property_id"/>
  <xsl:param name="property"/>
  <xsl:param name="display_name"/>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head_default">
        <xsl:with-param name="mode">delete</xsl:with-param>
      </xsl:call-template>
      <body>
        <xsl:call-template name="header">
	<!--<xsl:with-param name="noncontent">true</xsl:with-param>-->
	</xsl:call-template>
	<div id="content-container">
	  <form action="{$xims_box}{$goxims_content}{$absolute_path}?property_delete=1&amp;property_id={$property_id}&amp;property={$property}" method="post">
            <xsl:call-template name="input-token"/>
	    <h1 class="bluebg"><xsl:value-of select="$i18n/l/DeleteConfirm"/></h1>
	    <p><xsl:value-of select="$i18n/l/AboutDeletion1"/> '<xsl:value-of select="$display_name"/><!--<xsl:value-of select="title"/>-->' <xsl:value-of select="$i18n/l/AboutDeletion2"/></p>
	    <p><xsl:value-of select="$i18n/l/ClickCancelConf"/></p>
	    <div id="confirm-buttons">
	    <input type="hidden" name="property_id" value="{$property_id}"/>
	    <input type="hidden" name="property" value="{$property}"/>
	     <!--<input type="submit" name="author_delete" id="author_delete" value="Bestätigen" class="control" 
	            onclick="document.objectdeletion.submit; window.opener.document.location.reload();"
	            -->
	      <button name="property_delete" type="submit">
	        <xsl:value-of select="$i18n/l/Confirm"/>
	      </button>
      <!--<input name="id" type="hidden" value="{$id}"/>-->
	      &#160;
	      <button type="button" name="default" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
	    </div>
	   </form>
	  </div>
	<xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
