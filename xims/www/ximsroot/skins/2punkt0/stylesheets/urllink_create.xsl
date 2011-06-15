<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: urllink_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="create_common.xsl"/>
	
	<xsl:param name="testlocation">false</xsl:param>
	<xsl:param name="search-location">true</xsl:param>
	
		<xsl:template name="create-content">
		<xsl:call-template name="form-locationtitle-create"/>

			<xsl:call-template name="form-marknew-pubonsave"/>

			<xsl:call-template name="form-metadata"/>
			
			<xsl:call-template name="form-grant"/>
	</xsl:template>

	<xsl:template name="form-location-create">
		<xsl:param name="testlocation" select="true()"/>
		<div>
			<div class="label-std">
				<label for="input-location">
					<xsl:value-of select="$i18n/l/Location"/>
				</label>&#160;*
			</div>
			<input type="text" name="name" size="60" class="text" id="input-location"></input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Location')" class="doclink">
				<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Location"/>
				</xsl:attribute>(?)</a>
				<xsl:text>&#160;</xsl:text>
            <a href=" javascript:createDialog('{$xims_box}{$goxims_content}?id={/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;sbfield=eform.name;urllink=1','default-dialog','{$i18n/l/browse_target}')" class="button" id="buttonBrTarget">
                <xsl:value-of select="$i18n/l/browse_target"/>
            </a>
		</div>	
		</xsl:template>
		
		<xsl:template name="form-metadata">
  <div class="form-div block">
		<h2>Meta Data</h2>
		<xsl:call-template name="form-keywords"/>
		<xsl:call-template name="form-abstract"/>
			<xsl:call-template name="form-valid_from"/>
			<xsl:call-template name="form-valid_to"/>
  </div>
  </xsl:template>
	</xsl:stylesheet>
