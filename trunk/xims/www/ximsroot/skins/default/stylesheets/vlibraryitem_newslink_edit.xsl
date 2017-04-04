<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="newsitem_common.xsl"/>
  <xsl:import href="vlibraryitem_urllink_edit.xsl"/>

  <xsl:template name="edit-content">
	<xsl:call-template name="tr-locationtitle-edit_urllink"/>
	<xsl:call-template name="form-marknew-pubonsave"/>

    <xsl:call-template name="expandrefs"/>

    <xsl:call-template name="form-leadimage-edit"/>
    
	<xsl:call-template name="form-metadata"/>
	
    <div class="form-div block">
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'keyword'"/>
                <xsl:with-param name="objid" select="@id"/>
	  </xsl:call-template>
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'subject'"/>
                <xsl:with-param name="objid" select="@id"/>
	  </xsl:call-template>
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'author'"/>
                <xsl:with-param name="objid" select="@id"/>
	  </xsl:call-template>
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'publication'"/>
                <xsl:with-param name="objid" select="@id"/>
	  </xsl:call-template>
	</div>
      
	<xsl:call-template name="form-obj-specific"/>
  </xsl:template>

  <xsl:template name="form-metadata">
    <div class="form-div block">
	  <h2><xsl:value-of select="$i18n/l/Metadata"/></h2>
	  <xsl:call-template name="form-valid_from"/>
	  <xsl:call-template name="form-valid_to"/>
    </div>
  </xsl:template>
  
</xsl:stylesheet>
